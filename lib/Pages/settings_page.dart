
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:diamondplatform/main.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences

import 'company/home_page.dart';
import 'employee/home_page.dart';

class SettingsPage extends StatefulWidget {
  final bool isEmployee;

  const SettingsPage({required this.isEmployee, Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  List? industry = [];
  String? _selectIndustry;
  List<String> _options = [
    'english',
    'hindi',
    'gujarati',
  ];

  String _selectedOption = 'english';
  @override
  void initState() {
    super.initState();
    _loadSelectedLanguage();
    fetch_industry();
  }

  void _loadSelectedLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
     // print(_selectedOption);
      _selectIndustry = prefs.getString('selectedLanguage') ?? 'en';
      print(prefs.getString('selectedLanguage'));
    });
  }

  void _saveSelectedLanguage(String language) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedLanguage', language);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop:()async{
        Navigator.pop(context);
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.translate("Settings") ?? "Settings"),
        ),
        body: Column(
          children: [
            Row(
              children: [
                SizedBox(
                  width: 20,
                ),
                Icon(Icons.language),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    AppLocalizations.of(context)!.translate('Languages:') ?? "Languages",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            // Padding(
            //   padding: const EdgeInsets.all(8.0),
            //   child: Container(
            //     padding: EdgeInsets.symmetric(horizontal: 20),
            //     decoration: BoxDecoration(
            //       borderRadius: BorderRadius.circular(10),
            //       border: Border.all(
            //         color: Colors.blue,
            //         width: 2,
            //       ),
            //     ),
            //     child: DropdownButton<String>(
            //       value: _selectedOption,
            //       onChanged: (String? newValue) {
            //         setState(() {
            //           if (newValue == 'english') {
            //             _saveSelectedLanguage("english");
            //             AppLocalizations.of(context)!.setLocale(Locale("en"));
            //           } else if (newValue == 'hindi') {
            //             _saveSelectedLanguage("hindi");
            //             AppLocalizations.of(context)!.setLocale(Locale("hi"));
            //           } else {
            //             _saveSelectedLanguage("gujarati");
            //             AppLocalizations.of(context)!.setLocale(Locale("gu"));
            //           }
            //           _selectedOption = newValue!;
            //         });
            //         setState(() {
            //
            //         });
            //     //    runApp(MyApp());
            //       },
            //       items: _options.map<DropdownMenuItem<String>>((String value) {
            //         return DropdownMenuItem<String>(
            //           value: value,
            //           child: Text(
            //             AppLocalizations.of(context)!.translate(value) ?? value,
            //             style: TextStyle(fontSize: 16),
            //           ),
            //         );
            //       }).toList(),
            //       dropdownColor: Colors.white,
            //       elevation: 4,
            //       icon: Icon(Icons.arrow_drop_down),
            //       iconSize: 30,
            //       isExpanded: true,
            //       underline: SizedBox(),
            //     ),
            //   ),
            // ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(

                height: MediaQuery.of(context).size.height * .06,
                padding: EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.blue,
                        width: 2,
                      ),
                    ),

                child: DropdownButton<String>(

                  hint: Text(AppLocalizations.of(context)!.translate('select_language') ?? 'Select Language'),
                  isExpanded: true,
                  isDense: true,
                  underline: SizedBox(),
                  value: _selectIndustry,
                  onChanged: (newValue) {
                    setState(() {
                      _selectIndustry = newValue!;
                      print(newValue);
                      _saveSelectedLanguage(newValue);
                      AppLocalizations.of(context)!.setLocale(Locale(newValue));

                   //   fetch_department( );
                    });
                  },
                  items: industry!.map((department) {
                    return DropdownMenuItem<String>(
                      value: department["code"],
                      child: Text(AppLocalizations.of(context)!.translate(department["name"])?? department["name"], style: TextStyle(fontSize: 20),),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Future<void> fetch_industry() async{
    final response = await http.get(Uri.parse("https://diamond-platform-12038fd67b59.herokuapp.com/language"));
    try{
      if(response.statusCode == 200){
        var data = json.decode(response.body);
        setState(() {
          industry = data["data"];
        });
      }

    }
    catch(e){
      if (kDebugMode) {
        print(e);
      }
    }
  }
}

