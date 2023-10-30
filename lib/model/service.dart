import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'model.dart';

class employee_display {
  Stream<List<EmployeeDetails>> fetchEmployee() async* {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var token = prefs.getString("token");
      //  print(token);
      var response = await http.get(
          Uri.parse("https://diamond-server.vercel.app/employee/alls"),
          headers: {
            'Authorization': 'Bearer $token',
          });
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List<dynamic> data = jsonData['data'];
        //  print(data);
        yield data
            .map((jobPostJson) => EmployeeDetails.fromJson(jobPostJson))
            .toList();
      } else {
        throw Exception("Employee data not load");
      }
    } catch (e) {
      yield <EmployeeDetails>[];
    }
  }
}

class employee_job_post_for_comapny {
  Stream<List<employee_job_post>> employee_view_job_post() async* {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString("token");
    Map<String, dynamic> data = json.decode(prefs.getString("user_details")!);
    var id = data["_id"];
    while (true) {
      //await Future.delayed(const Duration(seconds: 30)); // You can adjust the interval

      try {
        var response = await http.get(
          Uri.parse("https://diamond-server.vercel.app/findjob/findjob/all"),
        );

        if (response.statusCode == 200) {
          final jsonData = json.decode(response.body);
          final List<dynamic> data = jsonData['data'];
          //  print(data);
          yield data
              .map((jobPostJson) => employee_job_post.fromJson(jobPostJson))
              .toList();
        } else {
          throw Exception('Failed to load job posts');
        }
      } catch (e) {
        yield <employee_job_post>[]; // Yield an empty list in case of an error
      }
    }
  }
}

class JobPostService {
  Stream<List<JobPost>> fetchJobPosts() async* {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString("token");
    Map<String, dynamic> data = json.decode(prefs.getString("user_details")!);
    var id = data["_id"];
    while (true) {
      //await Future.delayed(const Duration(seconds: 30)); // You can adjust the interval

      try {
        var response = await http.get(
          Uri.parse(
              "https://diamond-server.vercel.app/jobpost/viewjobpost/$id"),
          headers: {
            'Authorization': 'Bearer $token',
          },
        );

        if (response.statusCode == 200) {
          final jsonData = json.decode(response.body);
          final List<dynamic> data = jsonData['data'];
          //  print(data);
          yield data
              .map((jobPostJson) => JobPost.fromJson(jobPostJson))
              .toList();
        } else {
          throw Exception('Failed to load job posts');
        }
      } catch (e) {
        yield <JobPost>[]; // Yield an empty list in case of an error
      }
    }
  }

  jobPostDelete(String _id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString("token").toString();
    //print(token);

    try {
      var response = await http.delete(
        Uri.parse(
            "https://diamond-server.vercel.app/jobpost/jobpost/remove/$_id"),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
    } catch (e) {}
  }
}

class CompanyProfileProvider with ChangeNotifier {
  CompanyProfile _companyProfile = CompanyProfile();

  CompanyProfile get companyProfile => _companyProfile;

  void updateCompanyProfile(CompanyProfile newProfile) {
    _companyProfile = newProfile;
    notifyListeners();
  }

  void updateImagePath(String newPath) {
    _companyProfile = _companyProfile.copyWith(profile: newPath);
    notifyListeners();
  }

  Future<void> fetchCompanyProfileFromApi() async {
    // ... Fetch data from the API and update _companyProfile

    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, dynamic>? data = json.decode(prefs.getString("user_details")!);
    var _id = data!["_id"];
    //print(_id);
    final url = Uri.parse(
      'https://diamond-server.vercel.app/company/profile/$_id', // Replace with your API URL
    );
    try {
      final response = await http.get(
        url,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final companyData = data['data'];
        //print(companyData);
        final fetchedProfile = CompanyProfile(
          // Initialize properties based on fetched data
          name: companyData['companyName'],
          gstNumber: companyData['gstNumber'],
          mobileNumber: companyData['mobileNumber'],
          address: companyData['adress'],
          selectedCity: companyData['city'],
          profile: companyData['companyImage'],
          // Add other properties here
        );

        _companyProfile = fetchedProfile;
        notifyListeners();
      } else {
        // Handle error
      }
    } catch (error) {
      // Handle error
    }

    notifyListeners();
  }

  Future<void> updateProfileInApi() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString("token");
    var data = json.decode(prefs.getString("user_details")!);
    var _id = data["_id"];
    final url = Uri.parse(
      'https://diamond-server.vercel.app/company/${_id}',
    );
    final headers = {
      'Authorization': 'Bearer $token',
    };
    final body = {
      'companyName': _companyProfile.name,
      'city': _companyProfile.selectedCity,
      'adress': _companyProfile.address,
      'mobileNumber': _companyProfile.mobileNumber,
      'gstNumber': _companyProfile.gstNumber,
      'department': _companyProfile.department,
      'designation': _companyProfile.designation,
      'companyImage': _companyProfile.profile
      // Include other properties
    };
    try {
      final response = await http.put(
        url,
        headers: headers,
        body: body,
      );
      if (response.statusCode == 200) {
        // Data updated successfully
      } else {
        // Handle error
      }
    } catch (error) {
      // Handle error
    }
  }
// Add methods to modify the profile as needed
}

class EmployeeProfileProvider with ChangeNotifier {
  EmployeeProfile _employeeProfile = EmployeeProfile();

  EmployeeProfile get employeeProfile => _employeeProfile;

  void updateEmployeeProfile(EmployeeProfile newProfile) {
    _employeeProfile = newProfile;
    notifyListeners();
  }

  void updateImagePath(String newPath) {
    _employeeProfile = _employeeProfile.copyWith(profile: newPath);
    notifyListeners();
  }

  Future<void> fetchEmployeeProfileFromApi() async {
    // ... Fetch data from the API and update _companyProfile

    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> data = json.decode(prefs.getString("user_details")!);
    var _id = data["_id"];
    //print(_id);
    final url = Uri.parse(
      'https://diamond-server.vercel.app/employee/profile/$_id', // Replace with your API URL
    );
    try {
      final response = await http.get(
        url,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final companyData = data['data'];
        //print(companyData);
        final fetchedProfile = EmployeeProfile(
            // Initialize properties based on fetched data
            name: companyData['name'],
            // gstNumber: companyData['gstNumber'],
            mobileNumber: companyData['mobileNumber'],
            address: companyData['adress'],
            selectedCity: companyData['city'],
            // profile: companyData['employeeImage'],
            department: companyData['department'],
            designation: companyData['designation']
            // Add other properties here
            );

        _employeeProfile = fetchedProfile;
        notifyListeners();
      } else {
        // Handle error
      }
    } catch (error) {
      // Handle error
    }

    notifyListeners();
  }

// Inside CompanyProfileProvider class
  Future<void> updateProfileInApi() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString("token");
    var data = json.decode(prefs.getString("user_details")!);
    var _id = data["_id"];
    final url = Uri.parse(
      'https://diamond-server.vercel.app/employee/${_id}',
    );
    final headers = {
      'Authorization': 'Bearer $token',
    };
    final body = {
      'name': _employeeProfile.name,
      'city': _employeeProfile.selectedCity,
      'adress': _employeeProfile.address,
      'mobileNumber': _employeeProfile.mobileNumber.toString(),
      //'gstNumber': _employeeProfile.gstNumber,
      'department': _employeeProfile.department,
      'designation': _employeeProfile.designation,
      //'companyImage':_employeeProfile.profile
      // Include other properties
    };
    try {
      final response = await http.put(
        url,
        headers: headers,
        body: body,
      );
      if (response.statusCode == 200) {
        // Data updated successfully
      } else {
        // Handle error
      }
    } catch (error) {
      // Handle error
    }
  }
// Add methods to modify the profile as needed
}

class BannerDataProvider with ChangeNotifier {
  List<BannerItem> _banners = [];
  int _currentSlide = 0; // Initialize with the first slide

  List<BannerItem> get banners => _banners;
  int get currentSlide => _currentSlide;

  Future<void> fetchBanners() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var isEmployee = prefs.getString("isEmployee");
    var response = await http.get(Uri.parse(
        "https://diamond-server.vercel.app/banner/banner/$isEmployee"));
    var data = json.decode(response.body);

    if (data["statusCode"] == 200) {
      try {
        _banners = (data["data"] as List)
            .map((bannerData) => BannerItem(
                id: bannerData['bannerId'],
                imageUrl: bannerData['bannerImage']))
            .toList();
      } catch (e) {}
    }

    notifyListeners();
  }
}

class CurrentSlideProvider with ChangeNotifier {
  int _currentSlide = 0;

  int get currentSlide => _currentSlide;

  void updateCurrentSlide(int index) {
    _currentSlide = index;
    notifyListeners();
  }
}

enum NetworkStatus { online, offline }

class NetworkService {
  StreamController<NetworkStatus> controller = StreamController();
  NetworkService() {
    Connectivity().onConnectivityChanged.listen((event) {
      controller.add(_networkStatus(event));
    });
  }
  NetworkStatus _networkStatus(ConnectivityResult connectivityResult) {
    return connectivityResult == ConnectivityResult.mobile ||
            connectivityResult == ConnectivityResult.wifi
        ? NetworkStatus.online
        : NetworkStatus.offline;
  }
}

class MyListTileState with ChangeNotifier {
  bool _isPersonInfo = false;
  bool _isContactInfo = false;

  bool get isPersonInfo => _isPersonInfo;
  bool get isContactInfo => _isContactInfo;

  void pressPersonInfo() {
    _isPersonInfo = !_isPersonInfo;
    notifyListeners();
  }

  void pressContactInfo() {
    _isContactInfo = !_isContactInfo;
    notifyListeners();
  }
}

class employee_job_post_details {
  Stream<List<JobPost>> fetchJobPosts() async* {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString("token");
    //  Map<String, dynamic> data = json.decode(prefs.getString("user_details")!);
    //var id = data["_id"];
    //await Future.delayed(const Duration(seconds: 30)); // You can adjust the interval
    try {
      var response = await http.get(
        Uri.parse("https://diamond-server.vercel.app/viewjobs/viewjobs"),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List<dynamic> data = jsonData['data'];
        //  print(data);
        yield data.map((jobPostJson) => JobPost.fromJson(jobPostJson)).toList();
      } else {
        throw Exception('Failed to load job posts');
      }
    } catch (e) {
      yield <JobPost>[]; // Yield an empty list in case of an error
    }
  }
}
