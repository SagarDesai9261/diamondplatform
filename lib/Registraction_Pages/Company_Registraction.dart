// ignore: file_names
// ignore: file_names
import 'package:diamondplatform/Pages/Login_Page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../Pages/company/add_location.dart';
import '../Widget/snackbar.dart';

class CompanyForm extends StatefulWidget {
  final bool isEmployee; // Add this parameter

  const CompanyForm({required this.isEmployee, Key? key}) : super(key: key);
  @override
  State<CompanyForm> createState() => _CompanyFormState();
}
class _CompanyFormState extends State<CompanyForm> {
  @override
  void initState() {
    fetchCities();
    fetch_department();
    super.initState();
  }
  final _formKey = GlobalKey<FormState>();
  bool _securepassword = true;
  List department = [];
  List designation = [];
  String? _selecteddepartment ;
  String? _selecteddesignation;
  LatLng? selectedLocation;
  // city api
  bool _isLoading = false;

  final bool _isUploading = false;
  List<String> cities = [];
  late String selectedCity = 'Bhavnagar';

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



  //controller
  final String _selectedItem = 'Option 1';
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _employeernameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  final TextEditingController _contactNoController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _gstController = TextEditingController();
  final TextEditingController _designationController = TextEditingController();

  Future<void> saveFormData(Map<String, dynamic> formData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('form_data', json.encode(formData));
  }

  Future<Map<String, dynamic>> loadFormData() async {
    final prefs = await SharedPreferences.getInstance();
    final formDataString = prefs.getString('form_data');
    if (formDataString != null) {
      return json.decode(formDataString);
    }
    return {};
  }

  Future<void> postData() async {
    final url = Uri.parse(
        'https://diamond-platform-12038fd67b59.herokuapp.com/company');

    final headers = {
      'Content-Type': 'application/json',
    };

    final body = json.encode({
      'companyName': _nameController.text,
      'gstNumber': _gstController.text,
      'adress': _addressController.text,
      'city': selectedCity,
      'employeerName':_employeernameController.text,
      'mobileNumber': int.parse(_contactNoController.text),
      'department': _selecteddepartment,
      'designation': _selecteddesignation,
      'password': _passwordController.text,
      'latitude':selectedLocation!.latitude,
      'longitude':selectedLocation!.longitude
    });
    print(body);
    final response = await http.post(
      url,
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200) {

      final companyData = {
        'companyName': _nameController.text,
        'gstNumber': _gstController.text,
        'address': _addressController.text,
        'city': selectedCity,
        'mobileNumber': int.parse(_contactNoController.text),
        'department': _selectedItem,
        'designation': _designationController.text,
        'password': _passwordController.text,
      };

      await saveFormData(companyData);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Registration Successfully'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {
      final responseData = json.decode(response.body);

      // Show a snackbar with the error message
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Registration Failed'),
          content: Text('${responseData['message']}'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          //Text('${widget.isEmployee}'),
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'name_hint'.tr(),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: const BorderSide(color: Colors.black),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a name';
              }
              return null;
            },
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _employeernameController,
            decoration: InputDecoration(
              labelText: 'Manager Name'.tr(),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: const BorderSide(color: Colors.black),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a managar name';
              }
              return null;
            },
          ),
          SizedBox(height: 10,),
          TextFormField(
            controller: _addressController,
            decoration: InputDecoration(
              labelText: 'address_hint'.tr(),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: const BorderSide(color: Colors.black),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a address';
              }
              return null;
            },
          ),
          const SizedBox(
            height: 10,
          ),
          DropdownButtonFormField<String>(
            value: selectedCity,
            items: cities.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  selectedCity = newValue;
                });
              }
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a city';
              }
              return null;
            },
            decoration: InputDecoration(
              labelText: 'Select a city',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: const BorderSide(color: Colors.black),
              ),
            ),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _contactNoController,
            keyboardType: TextInputType.number,

            maxLength: 10,

            decoration: InputDecoration(

              labelText: 'contact_hint'.tr(),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: const BorderSide(color: Colors.black),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a contact number';
              }
              else if(value.length < 10){
                return 'Please enter valid mobile number';
              }
              return null;
            },
          ),
          const SizedBox(height: 10),
          TextFormField(
            obscureText: _securepassword ?  true : false,
            controller: _passwordController,
            decoration: InputDecoration(

              suffixIcon: InkWell(
                  onTap: (){
                    setState(() {
                      _securepassword ? _securepassword = false : _securepassword = true;
                    });
                  },
                  child: _securepassword ? const Icon(Icons.visibility):const Icon(Icons.visibility_off)),
              labelText: 'password_hint'.tr(),

              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: const BorderSide(color: Colors.black),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a password';
              }
              return null;
            },

          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _gstController,
            inputFormatters: [
              LengthLimitingTextInputFormatter(15)
            ],
            decoration: InputDecoration(
              labelText: 'gst_number_hint'.tr(),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: const BorderSide(color: Colors.black),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a Gst number';
              }
              else if(value.length < 15){
                return 'Please valid Gst Number';
              }
              return null;
            },
          ),
          const SizedBox(
            height: 10,
          ),
          DropdownButtonFormField<String>(
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

            items: department.map((department) {
              return DropdownMenuItem<String>(
                value: department["departmentName"],
                child: Text(department["departmentName"]),
              );
            }).toList(),
          ),
          const SizedBox(
            height: 10,
          ),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              //labelText: 'Gender',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: const BorderSide(color: Colors.grey),
              ),
            ),
            value: _selecteddesignation,
            hint: const Text("select_designation").tr(),
            onChanged: (newValue) {
              setState(() {
                _selecteddesignation = newValue!;
              });
            },
            items: designation.map((designation) {
              return DropdownMenuItem<String>(
                value: designation["designationName"],
                child: Text(designation["designationName"]),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Icon(Icons.location_on_outlined),
              TextButton(onPressed: (){
                _navigateToMapScreen();
                print(selectedLocation!.latitude );
                print(selectedLocation!.longitude );
              }, child: Text("select the Address on map")),
            ],
          ),
          selectedLocation != null ? Column(children: [
            Text("latitude : ${selectedLocation!.latitude}"),
            Text("longitude : ${selectedLocation!.longitude}")
          ],) : Container(),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading
                    ? null // Disable button while loading
                    : () async {
                  if(_selecteddepartment == null){
                    snackBar().display(context, "please select Department", Colors.red);

                  }
                  else if(_selecteddesignation == null){
                    snackBar().display(context, "please select Designation", Colors.red);
                  }
                  else if(selectedLocation == null){
                    snackBar().display(context, "please select address on map", Colors.red);
                  }
                  else  if (_formKey.currentState!.validate()) {
                          setState(() {
                            _isLoading = true;
                          });

                          if (!_isUploading) {
                            await postData();
                          }

                          setState(() {
                            _isLoading = false;
                          });
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text(
                        'register',
                        style: TextStyle(fontSize: 18.0),
                      ).tr(),
              ),
            ),
          ),
        ],
      ),
    );
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
      print(e);
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
  void _navigateToMapScreen() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MapScreen(),
      ),
    );

    if (result != null && result is LatLng) {
      setState(() {
        selectedLocation = result;
      });
    }
  }
}
