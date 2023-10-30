import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../main.dart';
import '../../model/model.dart';
import '../../model/service.dart';
import 'home_page.dart';

class ShowAllCategories extends StatefulWidget {
  const ShowAllCategories({Key? key}) : super(key: key);

  @override
  State<ShowAllCategories> createState() => _ShowAllCategoriesState();
}

class _ShowAllCategoriesState extends State<ShowAllCategories> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    workType();
    fetch_department();
    diamondType();
    fetchCities();
  }

  String? _selecteddepartment;
  String? _selecteddesignation;
  List? department = [];
  List? designation = [];

  List<String> cities = [];
  String? selectedCity = 'Bhavnagar';
  Future<void> fetchCities() async {
    final response =
        await http.get(Uri.parse('https://diamond-server.vercel.app/city'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['data'] != null && data['data'] is List) {
        setState(() {
          cities = List<String>.from(data['data'].map((city) =>
              city['cityName'] != null
                  ? city['cityName'].toString()
                  : '')); // Convert to string, handle null
          cities!.insert(0,  "All");
          selectedCity = cities[0];

        });
      } else {
        throw Exception('Invalid city data format');
      }
    } else {
      throw Exception(
          'Failed to load cities. Status code: ${response.statusCode}');
    }
  }

  List? diamondTypeList = [];
  List? workTypeList = [];
  List? bannerList = [];
  List? job_post_for_company = [];
  String? dropdownValue1;
  String? dropdownValue2;
  String selectedOption3 = 'Option 1';
  List<String> options = ['Option 1', 'Option 2', 'Option 3'];

  List<String> categories = [
    'Category 1',
    'Category 2',
    'Category 3',
    'Category 4',
    'Category 5',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * .35,
                    padding: const EdgeInsets.only(left: 5),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        hint: const Text("Department"),
                        value: _selecteddepartment,
                        onChanged: (newValue) {
                          setState(() {
                            _selecteddepartment = newValue!;
                            fetch_designation();
                            // fetch_designation();
                          });
                        },
                        items: department!.map((diamondTypeList) {
                          return DropdownMenuItem<String>(
                            value: diamondTypeList["departmentName"],
                            child: Text(AppLocalizations.of(context)!.translate(
                                    diamondTypeList["departmentName"]) ??
                                diamondTypeList["departmentName"]),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * .45,
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        hint: Text(AppLocalizations.of(context)!
                                .translate("Designation") ??
                            "Designation"),
                        value: _selecteddesignation,
                        onChanged: (newValue) {
                          setState(() {
                            _selecteddesignation = newValue!;
                            // fetch_designation();
                          });
                        },
                        items: designation!.map((workTypeList) {
                          return DropdownMenuItem<String>(
                            value: workTypeList["designationName"],
                            child: Text(AppLocalizations.of(context)!.translate(
                                    workTypeList["designationName"]) ??
                                workTypeList["designationName"]),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 5),
                    height: MediaQuery.of(context).size.height * .06,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        iconSize: 0.0,
                        value: selectedOption3,
                        onChanged: (newValue) {
                          setState(() {
                            selectedOption3 = newValue!;
                          });
                        },
                        items: options
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: value == "Option 1"
                                ? Image.asset("assets/male.png")
                                : value == "Option 2"
                                    ? Image.asset("assets/female.png")
                                    : Image.asset("assets/both.png"),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: DropdownButtonFormField<String>(
                value: selectedCity ?? "choose the city",
                items: cities.map((String city) {
                  return DropdownMenuItem<String>(
                      value: city, child: Text(city));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCity = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: "Select the city",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                ),
              ),
            ),
            StreamBuilder<List<JobPost>>(
                stream: employee_job_post_details().fetchJobPosts(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    print(snapshot.error);
                  }
                  List<JobPost> filterdata = snapshot.data!;

                  if(selectedCity == "All"){
                    filterdata = filterdata;
                  }
                  else if (selectedCity != null) {
                    filterdata = filterdata
                        .where((element) => element.cityName == selectedCity)
                        .toList();
                  }
                  if(_selecteddepartment == "All"){

                  filterdata = filterdata;
                  }
                  else if (_selecteddesignation == "All" && _selecteddepartment != "All") {
                  //  print("hello");
                    filterdata = filterdata
                        .where((element) =>
                            element.departmentName == _selecteddepartment)
                        .toList();
                  }
                  else{
                    filterdata = filterdata
                        .where((element) =>
                    element.departmentName == _selecteddepartment &&  element.designationName == _selecteddesignation)
                        .toList();
                  }

                  if (filterdata.length == 0) {
                    return Center(
                        child: Text(AppLocalizations.of(context)!
                                .translate("No job posts available") ??
                            "No Job Post Found"));
                  }
                  return SizedBox(
                    height: MediaQuery.of(context).size.height * .6,
                    child: ListView.builder(
                        itemCount: filterdata.length,
                        itemBuilder: (context, index) {

                          return Container(
                            height: 120,
                            padding: const EdgeInsets.all(10),
                            margin: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                const BoxShadow(
                                    color: Colors.grey, spreadRadius: 3),
                              ],
                            ),
                            child: InkWell(
                                onTap: () {
                                  employee_add_count(filterdata[index].id);
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => JobPosts(
                                                post: filterdata[index],
                                              )));
                                },
                                child: ListTile(
                                  //     contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  tileColor: Colors.grey[200],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  title: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          children: [
                                            Row(
                                              children: [
                                                SvgPicture.asset(
                                                  'assets/department.svg',
                                                  semanticsLabel:
                                                      'My SVG Image',
                                                  height: 20,
                                                  width: 20,
                                                ),
                                                SizedBox(width: 8),
                                                Text(
                                                    filterdata[index]
                                                        .departmentName,
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                              ],
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Row(
                                              children: [
                                                SvgPicture.asset(
                                                  'assets/designation.svg',
                                                  semanticsLabel:
                                                      'My SVG Image',
                                                  height: 20,
                                                  width: 20,
                                                ),
                                                SizedBox(width: 8),
                                                Text(
                                                    filterdata[index]
                                                        .designationName,
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        "${AppLocalizations.of(context)!.translate("Vacancy :") ?? "Vacancy :"}  ${filterdata[index].numberOfEmp}",
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(Icons.location_city,
                                              color: Colors.grey),
                                          SizedBox(width: 8),
                                          Text(
                                              "${filterdata[index].employeerName}",
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.grey)),
                                        ],
                                      ),
                                    ],
                                  ),
                                )),
                          );
                        }),
                  );
                })
          ],
        ),
      ),
    );
  }

  Future<void> diamondType() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString("token");
    final response = await http.get(
        Uri.parse("https://diamond-server.vercel.app/diamondtype/diamondtype"),
        headers: {
          'Authorization': 'Bearer $token',
        });
    try {
      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        setState(() {
          diamondTypeList = data["data"];
          //dropdownValue1 = diamondTypeList![0]["diamondType"];
          diamondTypeList!.insert(0, {"diamondType": "All"});
          dropdownValue1 = diamondTypeList![0]["diamondType"];
        });
      }
    } catch (e) {}
  }

  Future<void> workType() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString("token");
    final response = await http.get(
        Uri.parse("https://diamond-server.vercel.app/worktype/worktype"),
        headers: {
          'Authorization': 'Bearer $token',
        });
    try {
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        setState(() {
          workTypeList = data["data"];
          workTypeList!.insert(0, {"diamondWorkType": "All"});
          dropdownValue2 = workTypeList![0]["diamondWorkType"];
        });

      }
    } catch (e) {}
  }

  Future<void> fetch_department() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> data = json.decode(prefs.getString("user_details")!);

    final response = await http.get(Uri.parse(
        "https://diamond-server.vercel.app/department/department/${data["industry"]}"));
    try {
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        setState(() {
          department = data["data"];
          department!.insert(0, {"departmentName": "All"});
          _selecteddepartment = department![0]["departmentName"];
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
        'https://diamond-server.vercel.app/designation/$_selecteddepartment';
    var response = await http.get(Uri.parse(endpointUrl));

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      setState(() {
        designation = data["data"];
        designation = data["data"];
        designation!.insert(0, {"designationName": "All"});
        _selecteddesignation = designation![0]["designationName"];
      });
    } else {
      setState(() {
        designation = [];
      });
      //  designation = [];
    }
  }

  employee_add_count(var id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> data = json.decode(prefs.getString("user_details")!);
    var token = prefs.getString("token");
    var name = data["name"];
    var mobileNumber = data["mobileNumber"];
    //var datetime = DateTime.now();
    DateTime now = DateTime.now();
    var formattedDate = DateFormat('dd/MM/yyyy HH:mm a').format(now);


    //  print(id);
    try {
      var body = {
        'name': name.toString(),
        'phoneNumber': mobileNumber.toString(),
        'currentDateAndTime': formattedDate.toString()
      };
      //   print(body);
      var response = await http.post(
          Uri.parse(
              "https://diamond-server.vercel.app/viewjobs/employeeviewcount/${id}"),
          body: body,
          headers: {
            'Authorization': 'Bearer $token',
          });
      // print(response.body);
      //var data = json.decode(response.body);
      if (data["statusCode"] == 200) {
        // snackBar().display(context, "Job post updated Successfully", Colors.green);
      }
      //print(response.statusCode);
    } catch (e) {
      print(e);
    }
  }
}
