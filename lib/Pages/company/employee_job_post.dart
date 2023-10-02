import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../main.dart';
import '../../model/service.dart';

class employee_view_job_post extends StatefulWidget {
  const employee_view_job_post({Key? key}) : super(key: key);

  @override
  State<employee_view_job_post> createState() => _employee_viewState();
}

class _employee_viewState extends State<employee_view_job_post> {
  List? diamondTypeList = [];
  List? workTypeList = [];
  List? bannerList = [];
  List? job_post_for_company = [];
  String? dropdownValue1;
  String? dropdownValue2;
  String? companyname;
  String selectedOption3 = 'Option 1';
  List<String> options = ['Option 1', 'Option 2','Option 3'];
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 14),
              child: DropdownButtonFormField<String>(
                value: selectedCity ?? "choose the city",
                items: cities.map((String city) {
                  return DropdownMenuItem<String>(value: city, child: Text(AppLocalizations.of(context)!.translate(city)??city));
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
                stream: employee_job_post_for_comapny().employee_view_job_post(),
                builder: (context, snapshot) {
                  if(snapshot.hasError){
                    return Center(child: Text("Employee data display error"),);
                  }
                  else if(snapshot.connectionState == ConnectionState.waiting){
                    return Center(child: CircularProgressIndicator(),);
                  }
                  print(snapshot.data!.length);

                  var filterdata = snapshot.data;
                  if(selectedCity != null){
                    filterdata = filterdata!.where((element) => element.cityName == selectedCity).toList();
                  }
                  if(filterdata!.length == 0){
                    return Container(
                        child:Text("No Employees Found")
                    );
                  }

                  return SizedBox(
                    height: MediaQuery.of(context).size.height * .71,
                    child: ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context,index){

                          return Container(
                            margin: EdgeInsets.all(5),
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              //border: Border.all(),

                            ),
                            child:Card(
                              elevation: 5, // Add elevation for a shadow effect
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15), // Rounded corners
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              AppLocalizations.of(context)!.translate("Employee Name") ?? "Employee Name",
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              "${snapshot.data![index].employeeName}",
                                              style: TextStyle(fontSize: 16),
                                            ),
                                          ],
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              AppLocalizations.of(context)!.translate( "Position Name") ?? "Position Name",
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              "${AppLocalizations.of(context)!.translate(snapshot.data![index].designationName!)??snapshot.data![index].designationName}",
                                              style: TextStyle(fontSize: 16),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 16),

                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              AppLocalizations.of(context)!.translate("Mobile")??"Mobile",
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

                                      ],
                                    ),
                                    SizedBox(height: 10,),
                                    if(snapshot.data![index].requirementTypes == false)
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Text(AppLocalizations.of(context)!.translate("Expected Salary") ?? "Expected Salary" ),Text(":- ${snapshot.data![index].salary }"),
                                        ],
                                      ),
                                    if(snapshot.data![index].requirementTypes == true)
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Text(AppLocalizations.of(context)!.translate("Expected Price per piece") ?? "Expected Price per piece"),
                                          Text(":- ${snapshot.data![index].price }"),
                                        ],
                                      ),

                                  ],
                                ),
                              ),
                            )
                            ,
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
        Uri.parse(
            "https://diamond-platform-12038fd67b59.herokuapp.com/diamondtype/diamondtype"),
        headers: {
          'Authorization': 'Bearer $token',
        });
    try {
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        print(data["data"]);
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
        Uri.parse(
            "https://diamond-platform-12038fd67b59.herokuapp.com/worktype/worktype"),
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
        //  print(workTypeList);
      }
    } catch (e) {}
  }
}
