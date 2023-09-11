
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
  }

  void _loadSelectedLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      print(_selectedOption);
      _selectedOption = prefs.getString('selectedLanguage') ?? 'english';
      print(prefs.getString('selectedLanguage'));
    });
  }

  void _saveSelectedLanguage(String language) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedLanguage', language);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings").tr(),
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
                  'Languages:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ).tr(),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.blue,
                  width: 2,
                ),
              ),
              child: DropdownButton<String>(
                value: _selectedOption,
                onChanged: (String? newValue) {
                  setState(() {
                    if (newValue == 'english') {
                      _saveSelectedLanguage("english");
                      context.setLocale(Locale('en', 'US'));
                    } else if (newValue == 'hindi') {
                      _saveSelectedLanguage("hindi");
                      context.setLocale(Locale('hi', 'IN'));
                    } else {
                      _saveSelectedLanguage("gujarati");
                      context.setLocale(Locale('gu', 'IN'));
                    }
                    _selectedOption = newValue!;
                  });
                },
                items: _options.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }).toList(),
                dropdownColor: Colors.white,
                elevation: 4,
                icon: Icon(Icons.arrow_drop_down),
                iconSize: 30,
                isExpanded: true,
                underline: SizedBox(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

