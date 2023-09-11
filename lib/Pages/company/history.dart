import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
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
  String? dropdownValue2;
  String selectedOption3 = 'Option 1';
  List<String> options = ['Option 1', 'Option 2','Option 3'];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
            child: Column(children: <Widget>[
      Row(
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
                items: options.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: value == "Option 1"
                        ? Image.asset("assets/male.png")
                        : value == "Option 2"  ? Image.asset("assets/female.png") : Image.asset("assets/both.png"),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
      StreamBuilder<List<JobPost>>(
        stream: jobPostService
            .fetchJobPosts(), // Make sure this returns a Stream<List<JobPost>>
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            print(snapshot.error);
            return const Center(child: Text('Error fetching data'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return  Center(child: Text('No job posts available').tr());
          } else {
            // var filteredJobPosts;
            var filteredJobPosts = snapshot.data;
           filteredJobPosts =  filteredJobPosts!.where((element){
            return element.isJobPostShow == false;}).toList();
           if(filteredJobPosts.length == 0){
             return Center(child: Text("No History Found"));
           }

            if (dropdownValue1 == "All" &&
                dropdownValue2 == "All" &&
                selectedOption3 == "Option 1") {
              filteredJobPosts = snapshot.data!.where((jobPost) {
                return jobPost.gender == "Male";
              }).toList();
              // filteredJobPosts = snapshot.data;
            } else if (dropdownValue1 == "All" &&
                dropdownValue2 == "All" &&
                selectedOption3 == "Option 2") {
              filteredJobPosts = snapshot.data!.where((jobPost) {
                return jobPost.gender == "Female";
              }).toList();
            } else if (dropdownValue1 == "All" &&
                selectedOption3 == "Option 1") {
              filteredJobPosts = snapshot.data!.where((jobPost) {
                return jobPost.workType == dropdownValue2 &&
                    jobPost.gender == "Male";
              }).toList();
            } else if (dropdownValue1 == "All" &&
                selectedOption3 == "Option 2") {
              filteredJobPosts = snapshot.data!.where((jobPost) {
                return jobPost.workType == dropdownValue2 &&
                    jobPost.gender == "Female";
              }).toList();
            } else if (dropdownValue2 == "All" &&
                selectedOption3 == "Option 1") {
              filteredJobPosts = snapshot.data!.where((jobPost) {
                return jobPost.typesOfDiamond == dropdownValue1 &&
                    jobPost.gender == "Male";
              }).toList();
            } else if (dropdownValue2 == "All" &&
                selectedOption3 == "Option 2") {
              filteredJobPosts = snapshot.data!.where((jobPost) {
                return jobPost.typesOfDiamond == dropdownValue1 &&
                    jobPost.gender == "Female";
              }).toList();
            } else if (selectedOption3 == "Option 1") {
              filteredJobPosts = snapshot.data!.where((jobPost) {
                return jobPost.typesOfDiamond == dropdownValue1 &&
                    jobPost.workType == dropdownValue2 &&
                    jobPost.gender == "Male";
              }).toList();
            } else if (selectedOption3 == "Option 2") {
              filteredJobPosts = snapshot.data!.where((jobPost) {
                return jobPost.typesOfDiamond == dropdownValue1 &&
                    jobPost.workType == dropdownValue2 &&
                    jobPost.gender == "Female";
              }).toList();
            }
            // Your filtering logic here...

            if (filteredJobPosts.length == 0) {
              return Center(
                child: Text("No Record Found"),
              );
            }

            return SizedBox(
              height: MediaQuery.of(context).size.height * .42,
              child: ListView.builder(
                itemCount: filteredJobPosts.length,
                itemBuilder: (context, index) {
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
    ])));
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
