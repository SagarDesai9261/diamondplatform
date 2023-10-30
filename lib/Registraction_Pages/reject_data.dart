import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../main.dart';

class RejectEmployeeForm extends StatefulWidget {
  @override
  State<RejectEmployeeForm> createState() => _RejectEmployeeFormState();
}

class _RejectEmployeeFormState extends State<RejectEmployeeForm> {
  Future<Map<String, dynamic>?> fetchEmployeeData(String mobileNumber) async {
    final response = await http.get(
        Uri.parse('https://diamond-server.vercel.app/employee_data/6262626262'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print(data);
      return data;
    } else {
      throw Exception('Failed to load employee data');
    }
  }

  String? mobileNumber = '6262626262'; // Replace with the actual mobile number
  Future<Map<String, dynamic>?>? employeeData;

  @override
  void initState() {
    super.initState();
    employeeData = fetchEmployeeData("626262626262");
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
   TextEditingController _nameController = TextEditingController();
   TextEditingController _addressController = TextEditingController();
   TextEditingController _contactNo1Controller = TextEditingController();
   TextEditingController _contactNo2Controller = TextEditingController();
   TextEditingController _passwordController = TextEditingController();
   TextEditingController _aadhaarController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Re-Register Form"),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: FutureBuilder<Map<String, dynamic>?>(
            future: employeeData,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData) {
                return Center(child: Text('No data available'));
              } else {
                final employeeInfo = snapshot.data!;
                print(snapshot.data!["data"][0]["adress"]);
                // Populate the form fields with employee data
                _nameController.text = snapshot.data!["data"][0]["name"];
                _addressController.text = snapshot.data!["data"][0]["adress"];
                _contactNo1Controller.text = snapshot.data!["data"][0]["mobileNumber"].toString();
                _contactNo2Controller.text = snapshot.data!["data"][0]["mobileNumber1"].toString() ?? "";
                _aadhaarController.text = snapshot.data!["data"][0]["adharNumber"].toString();
                // Add code to populate other fields here

                return Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(
                              color: Colors.black), // Specify border color
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)!
                              .translate('Please enter a address') ??
                              "Please enter a address";
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _addressController,
                      decoration: InputDecoration(

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(
                              color: Colors.black), // Specify border color
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)!
                              .translate('Please enter a address') ??
                              "Please enter a address";
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _contactNo1Controller,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(
                              color: Colors.black), // Specify border color
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)!
                              .translate('Please enter a address') ??
                              "Please enter a address";
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _contactNo2Controller,
                      decoration: InputDecoration(

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(
                              color: Colors.black), // Specify border color
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)!
                              .translate('Please enter a address') ??
                              "Please enter a address";
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _aadhaarController,
                      decoration: InputDecoration(

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(
                              color: Colors.black), // Specify border color
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)!
                              .translate('Please enter a address') ??
                              "Please enter a address";
                        }
                        return null;
                      },
                    ), TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(
                              color: Colors.black), // Specify border color
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)!
                              .translate('Please enter a address') ??
                              "Please enter a address";
                        }
                        return null;
                      },
                    ), TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(
                              color: Colors.black), // Specify border color
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)!
                              .translate('Please enter a address') ??
                              "Please enter a address";
                        }
                        return null;
                      },
                    ), TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(
                              color: Colors.black), // Specify border color
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)!
                              .translate('Please enter a address') ??
                              "Please enter a address";
                        }
                        return null;
                      },
                    ),




                    // Add other form fields here
                  ],
                );
              }
            },
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: RejectEmployeeForm(),
  ));
}
