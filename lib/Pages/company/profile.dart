import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Widget/snackbar.dart';
import '../AnimatedDotsLoader.dart';

class ProfilePageCompany extends StatefulWidget {
  const ProfilePageCompany({super.key});

  @override
  State<ProfilePageCompany> createState() => _ProfilePageCompanyState();
}

class _ProfilePageCompanyState extends State<ProfilePageCompany> {
  bool _isImageSelected = false;
  bool _isUpdatingProfile = false;
  bool isLoading = false;

  final _formKey = GlobalKey<FormState>();
//  bool isLoading = false;
  bool _securepassword = true;
  List department = [];
  List designation = [];
  String? _selecteddepartment;
  String? _selecteddesignation;
  late String profileImgPath = '';
  File? _selectedImage;
  bool _isUploading = false;
  final picker = ImagePicker();
  var getProfileImgURL = '';

  // city api
  bool _isLoading = false;

  List<String> cities = [];
  late String selectedCity = 'Bhavnagar';
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  final TextEditingController _contactNoController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _gstController = TextEditingController();
  final TextEditingController _designationController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    getApiComapny().then((_) {
      setState(() {
        isLoading =
        false; // After the response is received, set isLoading to false
      });
    });
    fetchCities();
    //getApiComapny();
    fetch_department();
    fetch_designation();
    super.initState();
  }

  //profile Image
  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _selectedImage = File(pickedFile.path);
        _isImageSelected = true; // Set the flag to true when an image is picked

      } else {}
    });
  }

  Future<void> _uploadProfileImage() async {
    setState(() {
      _isUploading = true;
    });

    String url = 'https://www.sparrowgroups.com/CDN/image_upload.php/';

    var request = http.MultipartRequest('POST', Uri.parse(url));
    if (_selectedImage != null) {
      request.files.add(
          await http.MultipartFile.fromPath('b_video', _selectedImage!.path));
    }
    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        var responseData = await response.stream.toBytes();
        var responseString = utf8.decode(responseData);
        var jsonResponse = json.decode(responseString);
        profileImgPath = jsonResponse['iamge_path'];
       // print('$profileImgPath'); // Correct the key to "iamge_path"
        // Now you can set your image using the 'imagePath' variable
      } else {}
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Company Profile Page'),
      ),
      body: Stack(
        children: [
          AnimatedOpacity(
            opacity: isLoading ? 0.0 : 1.0,
            duration: Duration(milliseconds: 300),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      height: 50,
                    ),
                    getProfileImgURL.isEmpty ? CircleAvatar(
                      maxRadius: 60,
                      backgroundImage: AssetImage('assets/tree-736885_1280.jpg'),
                    ):
                    CircleAvatar(
                      maxRadius: 60,
                      backgroundImage: NetworkImage(getProfileImgURL),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    InkWell(
                        onTap: () {
                          getImage();
                        },
                        child: Text(
                          'Change Image',
                          style: TextStyle(
                              fontSize: 14,
                              color: Colors.blue,
                              fontWeight: FontWeight.w500),
                        )),
                    const SizedBox(
                      height: 40,
                    ),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'name_hint'.tr(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(color: Colors.black),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _addressController,
                      decoration: InputDecoration(
                        labelText: 'address_hint'.tr(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(color: Colors.black),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    DropdownButtonFormField<String>(
                      value: selectedCity,
                      items: cities.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            selectedCity = newValue;
                          });
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a city';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'Select a city',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(color: Colors.black),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _contactNoController,
                      keyboardType: TextInputType.number,
                      maxLength: 10,
                      decoration: InputDecoration(
                        labelText: 'contact_hint'.tr(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(color: Colors.black),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a contact number';
                        } else if (value.length < 10) {
                          return 'Please enter valid mobile number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _gstController,
                      inputFormatters: [LengthLimitingTextInputFormatter(15)],
                      decoration: InputDecoration(
                        labelText: 'gst_number_hint'.tr(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(color: Colors.black),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a Gst number';
                        } else if (value.length < 15) {
                          return 'Please valid Gst Number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                      ),
                      hint: const Text("select_department").tr(),
                      isExpanded: true,
                      isDense: true,
                      value: _selecteddepartment,
                      onChanged: (newValue) {
                        setState(() {
                          _selecteddepartment = newValue!;
                          fetch_designation();
                        });
                      },
                      items: department.map((department) {
                        return DropdownMenuItem<String>(
                          value: department["departmentName"],
                          child: Text(department["departmentName"]),
                        );
                      }).toList(),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        //labelText: 'Gender',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                      ),
                      value: _selecteddesignation,
                      hint: Text("${_selecteddesignation}").tr(),
                      onChanged: (newValue) {
                        setState(() {
                          _selecteddesignation = newValue!;
                        });
                      },
                      items: designation.map((designation) {
                        return DropdownMenuItem<String>(
                          value: designation["designationName"],
                          child: Text(designation["designationName"]),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    const SizedBox(height: 10),
                    if (_isUpdatingProfile)
                      Positioned.fill(
                        child: Center(
                          child: AnimatedDotsLoader(),
                        ),
                      ),
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * .06,
                        width:
                        double.infinity, // Increase the width of the button
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          onPressed: () async {
                            setState(() {
                              _isUpdatingProfile =
                              true; // Show CircularProgressIndicator
                            });
                            if (_isImageSelected) await _uploadProfileImage();
                            await _updatneCompayProfile();
                            setState(() {
                              _isUpdatingProfile =
                              false; // Hide CircularProgressIndicator
                            });
                          },
                          child: Text(
                            'Update',
                            style: TextStyle(fontSize: 18.0),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isLoading) Center(child: AnimatedDotsLoader())
        ],
      ),
    );
  }

  Future<void> fetchCities() async {
    final response = await http.get(
        Uri.parse('https://diamond-platform-12038fd67b59.herokuapp.com/city'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['data'] != null && data['data'] is List) {
        setState(() {
          cities = List<String>.from(data['data'].map((city) =>
          city['cityName'] != null
              ? city['cityName'].toString()
              : '')); // Convert to string, handle null
        });
      } else {
        throw Exception('Invalid city data format');
      }
    } else {
      throw Exception(
          'Failed to load cities. Status code: ${response.statusCode}');
    }
  }

  Future<void> fetch_department() async {
    final response = await http.get(Uri.parse(
        "https://diamond-platform-12038fd67b59.herokuapp.com/department/department"));
    try {
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        setState(() {
          department = data["data"];
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  fetch_designation() async {
    var endpointUrl =
        'https://diamond-platform-12038fd67b59.herokuapp.com/designation/$_selecteddepartment';
    var response = await http.get(Uri.parse(endpointUrl));

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      setState(() {
        designation = data["data"];
      });
    } else {
      setState(() {
        designation = [];
      });
      //  designation = [];
    }
  }

  //getcomplanyInfo
  Future<Map<String, dynamic>> getApiComapny() async {
    setState(() {
      isLoading = true; // Set loading state to true
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> data = json.decode(prefs.getString("user_details")!);
    var _id = data["_id"];
   // print(data);
    final url = Uri.parse(
      'https://diamond-platform-12038fd67b59.herokuapp.com/company/profile/$_id', // Replace with your API URL
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      print(data['data']);
      _nameController.text = data['data']['companyName'];

      _addressController.text = data['data']['adress'];
      selectedCity = data['data']['city'];
      _contactNoController.text = data['data']['mobileNumber'].toString();
      _gstController.text = data['data']['gstNumber'];
      _selecteddepartment = data['data']['department'];
      _selecteddesignation = data['data']['designation'];
      getProfileImgURL = data['data']['companyImage']??"";

      return data['data'];
    } else {
      throw Exception('Failed to load data');
    }
  }

  //update company profile
  Future<void> _updatneCompayProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString("token");
    var data1 = json.decode(prefs.getString("user_details")!);
    print("Data Are: ${json.encode(data1)}");
    var _id = data1["_id"];
    var _password = data1["password"];
    print("Passowrd :" + _password);
    final String apiUrl =
        'https://diamond-platform-12038fd67b59.herokuapp.com/company/${_id}';

    final Map<String, dynamic> data = {
      'companyName': _nameController.text,
      'adress': _addressController.text,
      'city': selectedCity,
      'mobileNumber': _contactNoController.text,
      'gstNumber': _gstController.text,
      'department': _selecteddepartment,
      'designation': _selecteddesignation,
      'password': _password,
      'companyImage': profileImgPath,
    };

    final response = await http.put(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      // Successful update, handle accordingly
      print('Profile updated successfully');
      // Parse the response body as JSON
      final Map<String, dynamic> responseData = json.decode(response.body);

      // Assuming there is a field named 'message' in the response
      final String message = responseData['message'];

      // Print the message or any other relevant data
      print('${response.body}');
      snackBar()
          .display(context, 'CompanyProfile Updated Sucessfully', Colors.blue);
    } else {
      // Handle errors here
      print('Failed to update profile');
    }
  }
}



