import 'dart:convert';

import 'package:diamondplatform/main.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../Widget/MyListTile.dart';
import '../../model/model.dart';
import '../../model/service.dart';

class History_jobpost extends StatefulWidget {
  const History_jobpost({Key? key}) : super(key: key);

  @override
  State<History_jobpost> createState() => _History_jobpostState();
}

class _History_jobpostState extends State<History_jobpost> {
 @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetch_department();
    diamondType();
    workType();
 }
  final jobPostService = JobPostService();
  double bottomNavBarHeight = 60;
  List? diamondTypeList = [];
  List? workTypeList = [];
  List? bannerList = [];
  List? job_post_for_company = [];
  String? dropdownValue1;
 List? department = [];
 List? designation = [];
 String? _selecteddepartment;
 String? _selecteddesignation;

 String? dropdownValue2;
  String selectedOption3 = 'Option 1';
  List<String> options = ['Option 1', 'Option 2','Option 3'];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * .3,
                      padding: const EdgeInsets.only(left: 5),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded:true,
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
                              child: Text(AppLocalizations.of(context)!.translate(diamondTypeList["departmentName"])??diamondTypeList["departmentName"]),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    SizedBox(width: 10,),
                    Container(
                      width: MediaQuery.of(context).size.width * .45,
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded:true,
                          hint: Text(AppLocalizations.of(context)!.translate("Designation")??"Designation"),
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
                              child: Text(AppLocalizations.of(context)!.translate(workTypeList["designationName"])??workTypeList["designationName"]),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    SizedBox(width: 10,),
                    Container(
                      margin: const EdgeInsets.only(top: 5),
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
                                  : value == "Option 2" ?  Image.asset("assets/female.png") :Image.asset("assets/both.png") ,
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              StreamBuilder<List<JobPost>>(
                stream: jobPostService.fetchJobPosts(), // Make sure this returns a Stream<List<JobPost>>
                builder: (context, snapshot) {
                  // print(snapshot.data!.length);
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    print(snapshot.error);
                    return const Center(child: Text('Error fetching data'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text(AppLocalizations.of(context)!.translate('No job posts available')??"No job posts available"));
                  } else {


                    // var filteredJobPosts;
                    List<JobPost>? filteredJobPosts;

                    if (_selecteddepartment == "All"  && selectedOption3 =="Option 1" ) {
                      filteredJobPosts = snapshot.data!.where((jobPost) {
                        return jobPost.gender =="Male";
                      }).toList();
                      // filteredJobPosts = snapshot.data;
                    }
                    else if(_selecteddepartment == "All"   && selectedOption3 =="Option 2"){
                      filteredJobPosts = snapshot.data!.where((jobPost) {
                        return jobPost.gender =="Female";
                      }).toList();
                    }
                    else if(_selecteddesignation == "All" && selectedOption3 == "Option 1"){
                      filteredJobPosts = snapshot.data!.where((jobPost) {
                        return jobPost.departmentName == _selecteddepartment && jobPost.gender =="Male";
                      }).toList();
                    }
                    else if(_selecteddesignation == "All" && selectedOption3 == "Option 2"){
                      filteredJobPosts = snapshot.data!.where((jobPost) {
                        return jobPost.departmentName == _selecteddepartment && jobPost.gender =="Female";
                      }).toList();
                    }

                    else if(selectedOption3 == "Option 1") {
                      filteredJobPosts = snapshot.data!.where((jobPost) {
                        return jobPost.departmentName == _selecteddepartment && jobPost.designationName == _selecteddesignation && jobPost.gender == "Male";
                      }).toList();

                    }
                    else if(selectedOption3 == "Option 2") {
                      filteredJobPosts = snapshot.data!.where((jobPost) {
                        return jobPost.departmentName == _selecteddepartment && jobPost.designationName == _selecteddesignation  && jobPost.gender == "Female";
                      }).toList();

                    }
                    filteredJobPosts = snapshot.data!.where((element) => element.isJobPostShow == false).toList();
                    // Your filtering logic here...

                    if (filteredJobPosts!.length == 0) {
                      return const Center(
                        child: Text("No Record Found"),
                      );
                    }

                    return SizedBox(
                      height: MediaQuery.of(context).size.height * .68,
                      child: ListView.builder(
                        itemCount: filteredJobPosts.length,
                        itemBuilder: (context, index) {
                          print(filteredJobPosts![index].isJobPostShow);

                          return ChangeNotifierProvider(
                            create: (context) => MyListTileState(),
                            child: MyListTile(
                              title: 'List Tile $index',
                              subTitle: 'Subtitle for Tile $index',
                              jobPost: filteredJobPosts![index],
                            ),
                          );
                        },
                      ),
                    );
                  }
                },
              ),


            ],
          ),
        ),);
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
 Future<void> fetch_department() async{
   SharedPreferences prefs = await SharedPreferences.getInstance();
   Map<String,dynamic> data = json.decode(prefs.getString("user_details")!);
   final response = await http.get(Uri.parse("https://diamond-platform-12038fd67b59.herokuapp.com/department/department/${data["industry"]}"));
   try{
     if(response.statusCode == 200){
       var data = json.decode(response.body);
       setState(() {
         department = data["data"];
         department!.insert(0, {"departmentName": "All"});
         _selecteddepartment = department![0]["departmentName"];
       });
     }

   }
   catch(e){
     if (kDebugMode) {
       print(e);
     }
   }
 }
 fetch_designation()async{
   var endpointUrl = 'https://diamond-platform-12038fd67b59.herokuapp.com/designation/$_selecteddepartment';
   var response = await http.get(Uri.parse(endpointUrl));

   if(response.statusCode == 200){
     var data = json.decode(response.body);
     setState(() {
       designation = data["data"];
       designation = data["data"];
       designation!.insert(0, {"designationName": "All"});
       _selecteddesignation = designation![0]["designationName"];
     });

   }
   else{
     setState(() {
       designation = [];
     });
     //  designation = [];
   }

 }
}
