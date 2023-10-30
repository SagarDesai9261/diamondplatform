import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../main.dart';
import '../../model/service.dart';

class employee_view extends StatefulWidget {
  const employee_view({Key? key}) : super(key: key);

  @override
  State<employee_view> createState() => _employee_viewState();
}

class _employee_viewState extends State<employee_view> {
  List? diamondTypeList = [];
  List? workTypeList = [];
  List? bannerList = [];
  List? job_post_for_company = [];
  String? dropdownValue1;
  String? dropdownValue2;
  String? companyname;
  String selectedOption3 = 'Option 1';
  List<String> options = ['Option 1', 'Option 2', 'Option 3'];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    diamondType();
    workType();
    fetchCities();
  }

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
          selectedCity  = cities[0];
        });

      } else {
        throw Exception('Invalid city data format');
      }
    } else {
      throw Exception(
          'Failed to load cities. Status code: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            /*   Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * .26,
                  padding: const EdgeInsets.only(left: 5),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      hint: const Text("Diamond"),
                      value: dropdownValue1,
                      onChanged: (newValue) {
                        setState(() {
                          dropdownValue1 = newValue!;
                          // fetch_designation();
                        });
                      },
                      items: diamondTypeList!.map((diamondTypeList) {
                        return DropdownMenuItem<String>(
                          value: diamondTypeList["diamondType"],
                          child: Text(diamondTypeList["diamondType"]),
                        );
                      }).toList(),
                    ),
                  ),
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
                      hint: const Text("select_worktype"),
                      value: dropdownValue2,
                      onChanged: (newValue) {
                        setState(() {
                          dropdownValue2 = newValue!;
                          // fetch_designation();
                        });
                      },
                      items: workTypeList!.map((workTypeList) {
                        return DropdownMenuItem<String>(
                          value: workTypeList["diamondWorkType"],
                          child: Text(workTypeList["diamondWorkType"]),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 5),
                  height: MediaQuery.of(context).size.height * .06,
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
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
                              : value == "Option 2" ? Image.asset("assets/female.png"):Image.asset("assets/both.png"),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),*/
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 3.0, horizontal: 14),
              child: DropdownButtonFormField<String>(
                value: selectedCity ?? "choose the city",
                items: cities.map((String city) {
                  return DropdownMenuItem<String>(
                    value: city,
                    child: Text(
                        AppLocalizations.of(context)!.translate(city) ??
                            city),
                  );
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
            StreamBuilder(
                stream: employee_display().fetchEmployee(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text("Employee data display error"),
                    );
                  } else if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }


                  var filterdata = snapshot.data;
                  if(selectedCity == "All"){
                    filterdata = filterdata;
                  }
                  else if (selectedCity != null) {
                    filterdata = filterdata!
                        .where((element) => element.city == selectedCity)
                        .toList();
                  }

                  if (filterdata!.length == 0) {
                    return Container(
                        child: Text(AppLocalizations.of(context)!
                                .translate("No Employees Found") ??
                            "No Employees Found"));
                  }

                  return SizedBox(
                    height: MediaQuery.of(context).size.height * .68,
                    child: ListView.builder(
                        itemCount: filterdata!.length,
                        itemBuilder: (context, index) {
                          if (filterdata![index].companyName != "" ||
                              filterdata![index].companyName != null) {
                            companyname =
                                filterdata![index]!.companyName.toString();
                            if (companyname!.length > 25) {
                              companyname = companyname!.substring(0, 25);
                            }
                          }

                          return Container(
                            margin: EdgeInsets.all(5),
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              //border: Border.all(),
                            ),
                            child: Card(
                              elevation: 5, // Add elevation for a shadow effect
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    15), // Rounded corners
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              AppLocalizations.of(context)!
                                                      .translate("Name:") ??
                                                  "Name:",
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              "${filterdata![index].name}",
                                              style: TextStyle(fontSize: 16),
                                            ),
                                          ],
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              AppLocalizations.of(context)!
                                                      .translate(
                                                          "Position Name:") ??
                                                  "Position Name:".tr(),
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              "${AppLocalizations.of(context)!.translate(filterdata![index].designation!) ?? filterdata![index].designation}",
                                              style: TextStyle(fontSize: 16),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      AppLocalizations.of(context)!
                                              .translate("Address:") ??
                                          "Address:".tr(),
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      "${filterdata![index].adress}, ${filterdata![index].city}",
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              AppLocalizations.of(context)!
                                                      .translate("Mobile:") ??
                                                  "Mobile:".tr(),
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              "${snapshot.data![index].mobileNumber}",
                                              style: TextStyle(fontSize: 16),
                                            ),
                                          ],
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              AppLocalizations.of(context)!
                                                      .translate(
                                                          "Current Company :-") ??
                                                  "Current Company :-",
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            snapshot.data![index].companyName ==
                                                        null ||
                                                filterdata![index]
                                                            .companyName ==
                                                        "" ||
                                                filterdata![index]
                                                            .companyName ==
                                                        "null"
                                                ? Text(
                                                    "None",
                                                    style:
                                                        TextStyle(fontSize: 16),
                                                  )
                                                : Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        companyname.toString(),
                                                      ),
                                                      filterdata![index]
                                                                  .isSalaryMethod ==
                                                              true
                                                          ? Text(filterdata![index]
                                                                  .salary
                                                                  .toString() +
                                                              " ${AppLocalizations.of(context)!.translate("per month") ?? "per Month"} ")
                                                          : Text(filterdata![index]
                                                                  .price
                                                                  .toString() +
                                                              "per piece".tr())
                                                    ],
                                                  ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
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
}
