
import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:diamondplatform/Pages/Login_Page.dart';
import 'package:diamondplatform/Pages/company/home_page.dart';
import 'package:diamondplatform/Pages/company/profile.dart';
import 'package:diamondplatform/Pages/employee/home_page.dart';
import 'package:diamondplatform/Pages/employee/profile.dart';
import 'package:diamondplatform/Pages/settings_page.dart';

import 'company/add_location.dart';

class CustomDrawer extends StatefulWidget {
  final bool isEmployee; // Add this parameter

  const CustomDrawer({required this.isEmployee, Key? key}) : super(key: key);

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  String number = "";
  String name = "";
  String companyName = "";
  getdata()async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var value = prefs.getString("user_details");
    Map<String,dynamic> data = json.decode(value!);
    setState(() {
      number = data["mobileNumber"].toString();
      name = data["name"].toString();
      companyName = data["companyName"].toString();
      //print(data["name"]);
    });
    //number = data["mobileNumber"].toString();
    //print(data["mobileNumber"]);
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getdata();
  }
  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 260,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
              ),
              currentAccountPicture: const CircleAvatar(
                backgroundImage: AssetImage('assets/tree-736885_1280.jpg'),
              ),
              accountName:  Text(widget.isEmployee == true ? name : companyName,style: const TextStyle(color: Colors.white),),
              accountEmail: Text(number,style: const TextStyle(color: Colors.white),),
            ),
          ),
          InkWell(
            onTap: () {
              if(widget.isEmployee == true){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Home_page_employee()),
                );
              }
              else{
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Home_Page_company()),
                );
              }

            },
            child:  ListTile(
              leading: Icon(
                Icons.home,
                color: Colors.black,
              ),
              title: Text('Home').tr(),
            ),
          ),
          InkWell(
            onTap: () async {
              if(widget.isEmployee == false){
                SharedPreferences prefs = await SharedPreferences.getInstance();
                Map<String,dynamic> user_details = json.decode(prefs.getString("user_details")!);
                print(prefs.getString("token"));
                Navigator.push(context, MaterialPageRoute(builder: (context)=>ProfilePageCompany()));
              }
              else{Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePageEmployee()),
              );}
            },
            child:  ListTile(
              leading: Icon(
                Icons.person,
                color: Colors.black,
              ),
              title: Text("Profile").tr(),
            ),
          ),

          InkWell(
            onTap: () async{

              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SettingsPage(
                          isEmployee: widget.isEmployee,
                        )),
              );
            },
            child:  ListTile(
              leading: Icon(
                Icons.settings,
                color: Colors.black,
              ),
              title: Text("Settings").tr(),
            ),
          ),
          InkWell(
            onTap: () async{
              try {
                final apkFilePath = await _copyApkFile();
                await Share.shareFiles([apkFilePath], text: 'Share APK File');
              } catch (e) {
                print('Error sharing APK file: $e');
              }

             // Share.share("https://github.com/SagarDesai9261/diamondplatform");
            },
            child:  ListTile(
              leading: Icon(
                Icons.share,
                color: Colors.black,
              ),
              title: Text("Share").tr(),
            ),
          ),
          InkWell(
            onTap: ()async {

              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("Confirm Logout"),
                    content: Text("Are you sure you want to logout?"),
                    actions: [
                      TextButton(
                        onPressed: () {
                          // Close the dialog
                          Navigator.of(context).pop();
                        },
                        child: Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () async {
                          // Perform logout action here
                          SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                          prefs.remove("user_details");
                          prefs.setString("isLogin", "No");
                          prefs.remove("token");
                          prefs.setStringList("notification_data", []);
                          Navigator.pop(context);
                          // Instead of pushReplacement, use push to navigate to the login screen
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginPage()),
                          );
                        },
                        child: Text("Logout"),
                      ),
                    ],
                  );
                },
              );
            },
            child: ListTile(
              leading: Icon(
                Icons.exit_to_app,
                color: Colors.black,
              ),
              title: Text("Logout").tr(),
            ),
          ),
        ],
      ),
    );
  }
  Future<String> _copyApkFile() async {
    final directory = await getTemporaryDirectory();
    final apkFile = File('${directory.path}/app-release.apk');
    final data = await rootBundle.load('assets/app-release.apk');
    await apkFile.writeAsBytes(data.buffer.asUint8List());
    return apkFile.path;
  }
}
