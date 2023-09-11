import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

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
    diamondType();
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
  List? diamondTypeList = [];
  List? workTypeList = [];
  List? bannerList = [];
  List? job_post_for_company = [];
  String? dropdownValue1;
  String? dropdownValue2;
  String selectedOption3 = 'Option 1';
  List<String> options = ['Option 1', 'Option 2','Option 3'];

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * .28,
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
                  width: MediaQuery.of(context).size.width * .43,
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
                              : value == "Option 2" ?  Image.asset("assets/female.png"): Image.asset("assets/both.png"),
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
                value: selectedCity ?? "choose the city",
                items: cities.map((String city) { return DropdownMenuItem<String>(value:city,child:Text(city));}).toList(),
                onChanged: (value){
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
                ),),
            ),
          StreamBuilder<List<JobPost>>(
              stream: employee_job_post_details().fetchJobPosts(),
              builder: (context, snapshot) {
                if(snapshot.connectionState == ConnectionState.waiting){
                  return CircularProgressIndicator();
                }
                else if (snapshot.hasError){
                  print(snapshot.error);

                }
               List<JobPost> filterdata = snapshot.data!;
                if(selectedCity!=null){
                 filterdata =  filterdata.where((element) => element.cityName == selectedCity).toList();
                }
                if(dropdownValue1 != "All"){
                 filterdata =  filterdata.where((element) => element.typesOfDiamond == dropdownValue1).toList();
                }
                if(dropdownValue2 != "All"){
                filterdata =  filterdata.where((element) => element.workType == dropdownValue2).toList();
                }
                print(filterdata.length);
                if(filterdata.length == 0){
                  return Center(
                    child: Text("No Job Post Found"),
                  );
                }
                return SizedBox(
                  height: MediaQuery.of(context).size.height * .6,
                  child: ListView.builder(
                      itemCount: filterdata.length,
                      itemBuilder: (context,index){
                        //print(filterdata[index].designationName);
                        return Container(
                          height:120,
                          padding: const EdgeInsets.all(10),
                          margin: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              const BoxShadow(color: Colors.grey, spreadRadius: 3),
                            ],
                          ),
                          child: InkWell(
                              onTap: () {
                                Navigator.push(
                                    context, MaterialPageRoute(builder: (context) => JobPosts(post: filterdata[index],)));
                              },
                              child: ListTile(
                                //     contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                tileColor: Colors.grey[200],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                title:  Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Row(
                                          children: [
                                            Icon(Icons.diamond_outlined, color: Colors.blue),
                                            SizedBox(width: 8),
                                            Text(filterdata[index].typesOfDiamond,
                                                style: TextStyle(color: Colors.black,
                                                    fontSize: 18, fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Row(
                                          children: [
                                            Icon(Icons.diamond_outlined, color: Colors.blue),
                                            SizedBox(width: 8),
                                            Text(filterdata[index].workType,
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 18, fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    Text("Vacancy:".tr()+" ${filterdata[index].numberOfEmp}",
                                        style: TextStyle(fontSize: 16, color: Colors.green)),
                                    SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(Icons.location_city, color: Colors.grey),
                                        SizedBox(width: 8),
                                        Text("${filterdata[index].employeerName}",
                                            style: TextStyle(fontSize: 16, color: Colors.grey)),
                                      ],
                                    ),
                                  ],
                                ),
                              )),
                        );
                      }),
                );

              }
                )
          ],
        ),
      ) ,
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
