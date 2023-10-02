import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:diamondplatform/Widget/banner_slider.dart';
import 'package:diamondplatform/Widget/snackbar.dart';
import 'package:diamondplatform/model/model.dart';

import '../../main.dart';
class Edit_Job_Post extends StatefulWidget {
  JobPost? jobPost;
  Edit_Job_Post({Key? key,required this.jobPost}) : super(key: key);

  @override
  State<Edit_Job_Post> createState() => _Job_PostState();
}

class _Job_PostState extends State<Edit_Job_Post> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    diamondType();
    workType();
    dropdownValue1 = widget.jobPost!.typesOfDiamond;
    dropdownValue2 = widget.jobPost!.workType;
    itemCount = widget.jobPost!.numberOfEmp;
    requiretype = widget.jobPost!.requirementTypes;
    salary.text = widget.jobPost!.salary.toString() == "null" ? "0" : widget.jobPost!.salary.toString();
    retail.text = widget.jobPost!.price.toString() == "null" ? "0":widget.jobPost!.price.toString();
    createJobPostDate = DateTime.parse(widget.jobPost!.createJobPostDate!);
    endJobPostDate = DateTime.parse(widget.jobPost!.endJobPostDate!);
    selectedOption3 = widget.jobPost!.gender == "Male"? "Option 1" : widget.jobPost!.gender == "Female"? "Option 2" : "Option 3";
    _selecteddepartment = widget.jobPost!.departmentName.toString();
    _selecteddesignation = widget.jobPost!.designationName.toString();
    //createJobPostDate = widget.jobPost
    fetch_department();
    fetch_designation();
  }

  DateTime? createJobPostDate;
  DateTime? endJobPostDate;
  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      fieldHintText: isStartDate ?  "Select Create JobPost Date" : "Select End JobPost Date",
      initialDate: isStartDate ? DateTime.now() : DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 20)),
    );

    if (picked != null && picked != (isStartDate ? createJobPostDate : endJobPostDate)) {
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
  List? department = [];
  List? designation = [];
  String? _selecteddepartment;
  String? _selecteddesignation;

  String? dropdownValue1;
  String? dropdownValue2;
  String selectedOption1 = 'Option 1';
  String selectedOption2 = 'Option 1';
  String selectedOption3 = 'Option 1';
  int itemCount = 1;
  TextEditingController salary = TextEditingController();
  TextEditingController retail = TextEditingController();

  List<String> options = ['Option 1', 'Option 2','Option 3'];
  bool requiretype = false;
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text( AppLocalizations.of(context)!.translate("Edit Job Post") ??"Edit Job Post"),
      ),
      body:
      SingleChildScrollView(
        child: Column(
          children: [

            BannerSlider(),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  width:MediaQuery.of(context).size.width * .8,
                  padding: const EdgeInsets.all(8.0),
                  child: DropdownButtonFormField<String>(
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
                    items: department!.map((department) {
                      return DropdownMenuItem<String>(
                        value: department["departmentName"],
                        child: Text(department["departmentName"]),
                      );
                    }).toList(),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5,vertical: 5),
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
                          child: value == "Option 1" ? Image.asset("assets/male.png"): value == "Option 2" ? Image.asset("assets/female.png") :Image.asset("assets/both.png"),
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
                validator: (value){
                  if(value!.isEmpty){
                    return "please select designation";
                  }
                  return null;
                },
                value: _selecteddesignation,
                hint:  Text("${_selecteddesignation}").tr(),
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
             Center(child:
              Text( AppLocalizations.of(context)!.translate("How Many Employee?") ?? "How Many Employee?"
              ,style: TextStyle(fontSize: 20),),),
            const SizedBox(height: 20,),
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
                        color: Colors.black
                            ,borderRadius: BorderRadius.circular(20)
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.remove,color: Colors.white,),
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
                      style: const TextStyle(
                          fontSize: 16, color: Colors.black87),
                    ),
                    Container(

                        width: MediaQuery.of(context).size.width * .2,
                        decoration: BoxDecoration(
                            color: Colors.black
                            ,borderRadius: BorderRadius.circular(20)
                        ),
                      child: IconButton(
                        icon: const Icon(Icons.add,color: Colors.white,),
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
            const SizedBox(height: 20,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InkWell(
                  onTap: (){
                    setState(() {
                      requiretype = false;
                    });
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width * .35,
                    height: MediaQuery.of(context).size.height * .07,
                    decoration: BoxDecoration(
                      color: requiretype == false ? Colors.redAccent:Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      border: requiretype == true ? Border.all() : null
                    ),
                    alignment: Alignment.center,
                    child: Text( AppLocalizations.of(context)!.translate("Fixed") ??"Fixed",style: TextStyle(
                      fontSize: 20,color: requiretype ==false?Colors.white :Colors.black
                    ),) ,
                  ),
                ),
                InkWell(
                  onTap: (){
                    setState(() {
                      requiretype = true;
                    });
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width * .35,
                    height: MediaQuery.of(context).size.height * .07,
                    decoration: BoxDecoration(
                        color: requiretype == true ? Colors.red:Colors.white,
    border: requiretype == false ? Border.all() : null,//color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(30)
                    ),
                    alignment: Alignment.center,
                    child:Text( AppLocalizations.of(context)!.translate("Retail") ??"Retail",style: TextStyle(
                        fontSize: 20,color: requiretype ==true?Colors.white :Colors.black
                    ),),
                  ),
                ),

              ],
            ),
            requiretype == false ? Container(
              padding: const EdgeInsets.all(20),
              child: TextFormField(
                controller: salary,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(

                  hintText: "Enter Salary",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20)
                  )
                ),

              ),
            ) :Container(
              padding: const EdgeInsets.all(20),
              child: TextFormField(
                controller: retail,
                  keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    hintText: "Enter Price per piece",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20)
                    )
                ),
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
                      : 'Select Create Job Post Date',
                style: const TextStyle(
                  fontSize: 18
                ),),
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
                  : 'Select End Job Post Date',
            style: const TextStyle(fontSize: 18),),
          ),),
      const SizedBox(height: 10,),
            // ... the rest of your existing code ...
      SizedBox(
              height: MediaQuery.of(context).size.height * .07,
              width: MediaQuery.of(context).size.width * .36,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)
                    ),
                    backgroundColor: Colors.black,
                  ),
                  onPressed: (){
                    submitPost();
                  }, child: Text( AppLocalizations.of(context)!.translate("Update Post") ??"Update Post",style: TextStyle(fontSize: 17),)),
            )
          ],
        ),
      ),


      );

  }
  submitPost()async{
    if(dropdownValue1 == null){
      snackBar().display(context, "please select Diamond type", Colors.red);
    }
    else if(dropdownValue2 == null){
      snackBar().display(context, "please select work type", Colors.red);
    }
    else if(requiretype == false && salary.text.isEmpty){
      snackBar().display(context, "please enter a salary", Colors.red);
    }
    else if(requiretype == true && retail.text.isEmpty){
      snackBar().display(context, "please enter a price", Colors.red);
    }
    else {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      Map<String, dynamic> data = json.decode(prefs.getString("user_details")!);
      requiretype == true ? print("Retail : ${retail.text}") : print(
          "Salary : ${salary.text}");


       print(salary.text=="null" ? true : false);
      int parsedSalary = salary.text=="null" ? 0 : int.parse(salary.text);
      //String retailText = retail.text.trim();
      int parsedretail = retail.text=="null" ? 0 : int.parse(retail.text);
      var body1 = {
        "companyId":data["_id"],
        "employeerName": data["companyName"],
        "departmentName": _selecteddepartment,
        "designationName": _selecteddesignation,
        "mobileNumber": data["mobileNumber"].toString(),
        "cityName": data["city"],
        "typesOfDiamond": dropdownValue1,
        "workType": dropdownValue2,
        "numberOfEmp": itemCount.toString(),
        "requirementTypes": requiretype.toString(),
        "salary": parsedSalary.toString(),
        "createJobPostDate": createJobPostDate.toString(),
        "endJobPostDate": endJobPostDate.toString(),
        "gender": selectedOption3 == "Option 1" ? "Male" : "Female"
      };
      var body2 = {
        "companyId":data["_id"],
        "employeerName": data["companyName"],
        "departmentName": data["department"],
        "designationName": data["designation"],
        "mobileNumber": data["mobileNumber"].toString(),
        "cityName": data["city"],
        "typesOfDiamond": dropdownValue1,
        "workType": dropdownValue2,
        "numberOfEmp": itemCount.toString(),
        "requirementTypes": requiretype.toString(),
        "price": parsedretail.toString(),
        "createJobPostDate": createJobPostDate.toString(),
        "endJobPostDate": endJobPostDate.toString(),
        "gender": selectedOption3 == "Option 1" ? "Male" : "Female"

      };
      var body;
      if (requiretype == false) {
        body = body1;
      } else {
        body = body2;
      }
      try {
        var response = await http.put(Uri.parse(
            "https://diamond-platform-12038fd67b59.herokuapp.com/jobpost/jobpost/${widget.jobPost!.id}"),
            body: body);
        var data = json.decode(response.body);
        if (data["statusCode"] == 200) {
          snackBar().display(context, "Job post updated Successfully", Colors.green);
        }
        //print(response.statusCode);
      }
      catch (e) {
      }
    }
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
        });
      }
    } catch (e) {}
  }
  Future<void> fetch_department() async{
    final response = await http.get(Uri.parse("https://diamond-platform-12038fd67b59.herokuapp.com/department/department"));
    try{
      if(response.statusCode == 200){
        var data = json.decode(response.body);
        setState(() {
          department = data["data"];
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
