// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:diamondplatform/Pages/Login_Page.dart';
import 'package:diamondplatform/Pages/company/home_page.dart';
import 'package:diamondplatform/Pages/employee/home_page.dart';


class check_login_page extends StatefulWidget {

   const check_login_page({Key? key}) : super(key: key);

  @override
  State<check_login_page> createState() => _check_login_pageState();
}

class _check_login_pageState extends State<check_login_page> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkLogin(context);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(),
    );
  }

  void checkLogin(BuildContext context) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //Map<String,dynamic>  data= json.decode(prefs.getString("user_details")!)??[];
    String? isLogin= prefs.getString("token");

    if(isLogin!=null){
      bool isEmployee = json.decode(prefs.getString("isEmployee")!);
      //print("${data.isNotEmpty}");
      if(isEmployee == false){
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Home_Page_company()));
      }
      else{
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Home_page_employee()));
      }
    }
    else{
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>const LoginPage()));
    }
  }
}
