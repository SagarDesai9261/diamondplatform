import 'dart:convert';
import 'package:diamondplatform/main.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import '../../NotificationService.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:diamondplatform/Widget/banner_slider.dart';
import 'package:diamondplatform/Widget/snackbar.dart';

class Job_Post extends StatefulWidget {
  const Job_Post({Key? key}) : super(key: key);

  @override
  State<Job_Post> createState() => _Job_PostState();
}

class _Job_PostState extends State<Job_Post> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    diamondType();
    workType();
    fetch_department();
    fetch_designation();
  }

  final List<String> imageList = [
    'assets/tree-736885_1280.jpg',
    'assets/tree-736885_1280.jpg',
    'assets/tree-736885_1280.jpg',
    'assets/tree-736885_1280.jpg',
    // Add more image URLs as needed
  ];
  DateTime? createJobPostDate;
  DateTime? endJobPostDate;
  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      fieldHintText: isStartDate
          ? "Select Create JobPost Date"
          : "Select End JobPost Date",
      initialDate: isStartDate
          ? DateTime.now()
          : DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 20)),
    );

    if (picked != null &&
        picked != (isStartDate ? createJobPostDate : endJobPostDate)) {
      setState(() {
        if (isStartDate) {
          createJobPostDate = picked;
        } else {
          endJobPostDate = picked;
        }
      });
    }
  }

  List? diamondTypeList = [];
  List? workTypeList = [];
  String? dropdownValue1;
  String? dropdownValue2;
  String selectedOption1 = 'Option 1';
  String selectedOption2 = 'Option 1';
  String selectedOption3 = 'Option 1';
  int itemCount = 1;
  TextEditingController salary = TextEditingController();
  TextEditingController retail = TextEditingController();
  List? department = [];
  List? designation = [];
  String? _selecteddepartment;
  String? _selecteddesignation;

  List<String> options = ['Option 1', 'Option 2', 'Option 3'];
  bool requiretype = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            BannerSlider(),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * .8,
                  padding: const EdgeInsets.all(8.0),
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                    ),
                    hint: Text(AppLocalizations.of(context)!
                            .translate("Select Department") ??
                        "Select Department"),
                    isExpanded: true,
                    isDense: true,
                    value: _selecteddepartment,
                    onChanged: (newValue) {
                      setState(() {
                        _selecteddepartment = newValue!;
                        fetch_designation();
                      });
                    },
                    items: department!.map((department) {
                      return DropdownMenuItem<String>(
                        value: department["departmentName"],
                        child: Text(department["departmentName"]),
                      );
                    }).toList(),
                  ),
                ),
                Container(
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
                      items:
                          options.map<DropdownMenuItem<String>>((String value) {
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

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  //labelText: 'Gender',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return "please select designation";
                  }
                  return null;
                },
                value: _selecteddesignation,
                hint: Text(AppLocalizations.of(context)!
                        .translate("Select Designation") ??
                    "Select Designation"),
                onChanged: (newValue) {
                  setState(() {
                    _selecteddesignation = newValue!;
                  });
                },
                items: designation!.map((designation) {
                  return DropdownMenuItem<String>(
                    value: designation["designationName"],
                    child: Text(designation["designationName"]),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Center(
              child: Text(
                AppLocalizations.of(context)!.translate("How Many Employee?") ??
                    "How Many Employee?",
                style: TextStyle(fontSize: 20),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * .7,
                height: MediaQuery.of(context).size.height * .05,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * .2,
                      decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(20)),
                      child: IconButton(
                        icon: const Icon(
                          Icons.remove,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            if (itemCount > 1) {
                              itemCount--;
                            }
                          });
                        },
                      ),
                    ),
                    Text(
                      itemCount.toString(),
                      style:
                          const TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * .2,
                      decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(20)),
                      child: IconButton(
                        icon: const Icon(
                          Icons.add,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            itemCount++;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      requiretype = false;
                    });
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width * .35,
                    height: MediaQuery.of(context).size.height * .07,
                    decoration: BoxDecoration(
                        color: requiretype == false
                            ? Colors.redAccent
                            : Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        border: requiretype == true ? Border.all() : null),
                    alignment: Alignment.center,
                    child: Text(
                      AppLocalizations.of(context)!.translate("Fixed") ??
                          "Fixed",
                      style: TextStyle(
                          fontSize: 20,
                          color: requiretype == false
                              ? Colors.white
                              : Colors.black),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      requiretype = true;
                    });
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width * .35,
                    height: MediaQuery.of(context).size.height * .07,
                    decoration: BoxDecoration(
                        color: requiretype == true ? Colors.red : Colors.white,
                        border: requiretype == false
                            ? Border.all()
                            : null, //color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(30)),
                    alignment: Alignment.center,
                    child: Text(
                      AppLocalizations.of(context)!.translate("Retail") ??
                          "Retail",
                      style: TextStyle(
                          fontSize: 20,
                          color: requiretype == true
                              ? Colors.white
                              : Colors.black),
                    ),
                  ),
                ),
              ],
            ),
            requiretype == false
                ? Container(
                    padding: const EdgeInsets.all(20),
                    child: TextFormField(
                      controller: salary,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)!
                                  .translate("Enter Salary") ??
                              "Enter Salary",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20))),
                    ),
                  )
                : Container(
                    padding: const EdgeInsets.all(20),
                    child: TextFormField(
                      controller: retail,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)!
                                  .translate("Enter price per piece") ??
                              "Enter Price per piece",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20))),
                    ),
                  ),
            InkWell(
              onTap: () => _selectDate(context, true),
              child: Container(
                width: MediaQuery.of(context).size.width * .9,
                height: MediaQuery.of(context).size.height * .06,
                padding: const EdgeInsets.all(10),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  createJobPostDate != null
                      ? "${createJobPostDate!.toLocal()}".split(' ')[0]
                      : AppLocalizations.of(context)!
                              .translate("Select Create Job Post Date") ??
                          'Select Create Job Post Date',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            // End Job Post Date Picker
            InkWell(
              onTap: () => _selectDate(context, false),
              child: Container(
                width: MediaQuery.of(context).size.width * .9,
                height: MediaQuery.of(context).size.height * .06,
                padding: const EdgeInsets.all(10),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  endJobPostDate != null
                      ? "${endJobPostDate!.toLocal()}".split(' ')[0]
                      : AppLocalizations.of(context)!
                              .translate("Select End Job Post Date") ??
                          'Select End Job Post Date'.tr(),
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            // ... the rest of your existing code ...
            SizedBox(
              height: MediaQuery.of(context).size.height * .07,
              width: MediaQuery.of(context).size.width * .36,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    backgroundColor: Colors.black,
                  ),
                  onPressed: () {
                    submitPost();
                  },
                  child: Text(
                    AppLocalizations.of(context)!.translate("Post") ?? "Post",
                    style: TextStyle(fontSize: 20),
                  )),
            ),
            SizedBox(
              height: 50,
            )
          ],
        ),
      ),
    );
  }

  submitPost() async {
    if (requiretype == false && salary.text.isEmpty) {
      snackBar().display(context, "please enter a salary", Colors.red);
    } else if (requiretype == true && retail.text.isEmpty) {
      snackBar().display(context, "please enter a price", Colors.red);
    } else {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      Map<String, dynamic> data = json.decode(prefs.getString("user_details")!);
      var logitude = data["longitude"];
      var latitude = data["latitude"];


      String salaryText = salary.text.trim();
      int parsedSalary = salaryText.isEmpty ? 0 : int.parse(salaryText);
      String retailText = retail.text.trim();
      int parsedretail = retailText.isEmpty ? 0 : int.parse(retailText);
      var body1 = {
        ""
            "companyId": data["_id"],
        "companyName": data["companyName"],
        "departmentName": _selecteddepartment,
        "designationName": _selecteddesignation,
        "mobileNumber": data["mobileNumber"].toString(),
        "cityName": data["city"],
        "adress": data['adress'],
        "numberOfEmp": itemCount.toString(),
        "requirementTypes": requiretype.toString(),
        "salary": parsedSalary.toString(),
        "createJobPostDate": createJobPostDate.toString(),
        "endJobPostDate": endJobPostDate.toString(),
        "gender": selectedOption3 == "Option 1"
            ? "Male"
            : selectedOption3 == "Option 2"
                ? "Female"
                : "Both",
        "longitude": logitude.toString(),
        "latitude": latitude.toString(),
        "industry": data["industry"]
      };
      var body2 = {
        "companyId": data["_id"],
        "companyName": data["companyName"],
        "departmentName": data["department"],
        "designationName": data["designation"],
        "mobileNumber": data["mobileNumber"].toString(),
        "cityName": data["city"],
        "adress": data['adress'],
        "numberOfEmp": itemCount.toString(),
        "requirementTypes": requiretype.toString(),
        "price": parsedretail.toString(),
        "createJobPostDate": createJobPostDate.toString(),
        "endJobPostDate": endJobPostDate.toString(),
        "gender": selectedOption3 == "Option 1"
            ? "Male"
            : selectedOption3 == "Option 2"
                ? "Female"
                : "Both",
        "longitude": logitude.toString(),
        "latitude": latitude.toString(),
        "industry": data["industry"]
      };
      var body;
      if (requiretype == false) {
        body = body1;
      } else {
        body = body2;
      }
      try {
        var response = await http.post(
            Uri.parse("https://diamond-server.vercel.app/jobpost/jobpost"),
            body: body);
        var data = json.decode(response.body);
        if (data["statusCode"] == 200) {
          NotificationService().showNotification(
              0, "Job Post", "New Job post Created Successfully");
          Alert(
            context: context,
            title: "Job post created Successfully",
            type: AlertType.success,
            buttons: [
              DialogButton(
                child: Text(
                  "ok",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                onPressed: () => Navigator.pop(context),
                color: Color.fromRGBO(0, 179, 134, 1.0),
                radius: BorderRadius.circular(0.0),
              ),
            ],
          ).show();
          // snackBar().display(context, "Job post Successfully", Colors.green);
        } else {
          snackBar()
              .display(context, "Job post already Successfully", Colors.red);
        }
        //print(response.statusCode);
      } catch (e) {
        print(e);
      }
    }
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
      });
    } else {
      setState(() {
        designation = [];
      });
      //  designation = [];
    }
  }
}
