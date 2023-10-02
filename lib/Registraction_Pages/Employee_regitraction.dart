// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:diamondplatform/main.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:diamondplatform/Pages/Login_Page.dart';
import 'package:diamondplatform/Widget/snackbar.dart';
class EmployeeForm extends StatefulWidget {
  final bool isEmployee; // Add this parameter
  const EmployeeForm({required this.isEmployee, Key? key}) : super(key: key);
  @override
  State<EmployeeForm> createState() => _EmployeeFormState();
}
class _EmployeeFormState extends State<EmployeeForm> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetch_industry();
    fetchCities();
    fetch_department();
  }
  List? department = [];
  List? industry = [];
  List? designation = [];
  String? _selectIndustry;
  String? _selecteddepartment;
  String? _selecteddesignation;

  bool _securepassword = true;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  final TextEditingController _contactNo1Controller = TextEditingController();
  final TextEditingController _contactNo2Controller = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _aadhaarController = TextEditingController();

  String _selectedGender = 'Male';
  bool isVerify = false;
//aadhaar Card photo
  bool _isLoading = false;
  File? _selectedImage;
  bool _isUploading = false;
  final picker = ImagePicker();
  late String imagePath;

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _selectedImage = File(pickedFile.path);
      } else {
      }
    });
  }

  Future<void> _uploadImage() async {
    setState(() {
      _isUploading = true;
    });

    String url = 'https://www.sparrowgroups.com/CDN/image_upload.php/';

    var request = http.MultipartRequest('POST', Uri.parse(url));
    if (_selectedImage != null) {
      request.files.add(
          await http.MultipartFile.fromPath('b_video', _selectedImage!.path));
    }

    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        var responseData = await response.stream.toBytes();
        var responseString = utf8.decode(responseData);
        var jsonResponse = json.decode(responseString);
        imagePath =
            jsonResponse['iamge_path']; // Correct the key to "iamge_path"

        // Now you can set your image using the 'imagePath' variable
      } else {
      }
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }
  //Fetch City API

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

  @override
  //POST API


  // employee  Data register
  Future<void> postData() async {
    final url = Uri.parse(
        'https://diamond-platform-12038fd67b59.herokuapp.com/employee');

    final headers = {
      'Content-Type': 'application/json',
    };

    final body = json.encode({
      'name': _nameController.text,
      'city': selectedCity,
      'adress': _addressController.text,
      'mobileNumber': _contactNo1Controller.text,
      'mobileNumber2': _contactNo2Controller.text,
      'adharNumber': _aadhaarController.text,
      'adharPhoto': imagePath,
      'gender': _selectedGender,
      'department': _selecteddepartment,
      'designation': _selecteddesignation,
      'password': _passwordController.text,
      'isEmployee':widget.isEmployee,
      'isAdminApproval':false,
      'industry':_selectIndustry
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        title: Text('Registering'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 10),
            Text('Please wait...'),
          ],
        ),
      ),
    );

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      Navigator.pop(context); // Close the progress dialog

      if (response.statusCode == 200) {


        // ignore: use_build_context_synchronously
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text( AppLocalizations.of(context)!.translate('Registration Successfully')??"Registration Successfully"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginPage()));
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
    } catch (error) {
      Navigator.pop(context); // Close the progress dialog
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
              labelText: AppLocalizations.of(context)!.translate('Enter your Name'),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide:
                    const BorderSide(color: Colors.black), // Specify border color
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return  AppLocalizations.of(context)!.translate('Please enter a name')??"Please enter a name";
              }
              return null;
            },
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _addressController,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.translate('Enter your Address'),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide:
                    const BorderSide(color: Colors.black), // Specify border color
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return  AppLocalizations.of(context)!.translate('Please enter a address') ??"Please enter a address";
              }
              return null;
            },
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
              value: selectedCity ?? "choose the city",
              items: cities.map((String city) { return DropdownMenuItem<String>(value:city,child:Text( AppLocalizations.of(context)!.translate(city) ?? city));}).toList(),
              onChanged: (value){
                setState(() {
                  selectedCity = value;
                });

              },
            decoration: InputDecoration(

              hintText: "Select the city",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: const BorderSide(color: Colors.black),
            ),
          ),),
          const SizedBox(height: 10),
          TextFormField(
            controller: _contactNo1Controller,
            keyboardType: TextInputType.number,
            inputFormatters: [
              LengthLimitingTextInputFormatter(10),
            ],
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.translate('Enter your Contact No'),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide:
                    const BorderSide(color: Colors.black), // Specify border color
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return  AppLocalizations.of(context)!.translate('Please enter a contact number') ??"Please enter a contact number";
              }
              else if(value.length < 10){
                return  AppLocalizations.of(context)!.translate('Please enter valid mobile number')??"Please enter valid mobile number";
              }
              return null;
            },
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _contactNo2Controller,
            keyboardType: TextInputType.number,
            inputFormatters: [
              LengthLimitingTextInputFormatter(10),
            ],
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.translate('Enter your Contact No 2 (Optional)'),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: const BorderSide(
                    color: Colors.black), // Specify border color
              ),
            ),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Gender',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: const BorderSide(color: Colors.grey),
              ),
            ),
            value: _selectedGender,
            onChanged: (String? newValue) {
              setState(() {
                _selectedGender = newValue!;
              });
            },
            items: <String>['Male', 'Female', 'Other']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a gender';
              }
              return null;
            },
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(
              suffixIcon: InkWell(
                  onTap: (){
                    setState(() {
                      _securepassword ? _securepassword = false : _securepassword = true;
                    });
                  },
                  child: _securepassword ? const Icon(Icons.visibility):const Icon(Icons.visibility_off)),
              labelText: AppLocalizations.of(context)!.translate('Please enter a password'),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: const BorderSide(color: Colors.grey),
              ),
            ),
            obscureText: _securepassword ?  true : false,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return  AppLocalizations.of(context)!.translate('Please enter a password') ?? "Please enter a password";
              }
              return null;
            },
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _aadhaarController,
            inputFormatters: [
              AadhaarCardNumberFormatter(),
              FilteringTextInputFormatter.digitsOnly,
            ],
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              suffixIcon: TextButton( onPressed: () {
                setState(() {
                  isVerify = true;
                });
              }, child: const Text("Verify",style: TextStyle(color: Colors.blue),),
              ),
              labelText: AppLocalizations.of(context)!.translate('Enter Aadhaar Card Number'),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: const BorderSide(color: Colors.grey),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return  AppLocalizations.of(context)!.translate('Please enter aadhar card number') ??"Please enter aadhar card number";
              }
              return null;
            },
          ),
          isVerify == true? Column(
           children: [
             const SizedBox(height: 10),
             TextFormField(
               decoration: InputDecoration(
                 suffixIcon: TextButton(onPressed: () {
                   setState(() {
                     isVerify = false;
                   });
                 }, child: const Text("Submit"),),
                   hintText: "Enter Verification code",
                 border: OutlineInputBorder(
                   borderRadius: BorderRadius.circular(10)
                 )
               ),
             )
           ],
          ):const SizedBox(height: 10),
          Row(
            children: [
              InkWell(
                onTap: getImage,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: _selectedImage == null
                      ? const Icon(Icons.add_a_photo, size: 36)
                      : Image.file(_selectedImage!),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                _selectedImage == null
                    ? "Add Your Aadhaar Card Photo"
                    : "Image Selected",
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 5),
          if (_selectedImage == null)
             Text(
              AppLocalizations.of(context)!.translate('please_add_photo') ??"please_add_photo",
              style: TextStyle(color: Colors.red),
            ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: const BorderSide(color: Colors.grey),
              ),
            ),
            hint: Text(AppLocalizations.of(context)!.translate('select_industry') ?? 'select_industry'),
            isExpanded: true,
            isDense: true,
            value: _selectIndustry,
            onChanged: (newValue) {
              setState(() {
                _selectIndustry = newValue!;
                fetch_department( );
              });
            },
            items: industry!.map((department) {
              return DropdownMenuItem<String>(
                value: department["industry"],
                child: Text(AppLocalizations.of(context)!.translate(department["industry"])?? department["industry"]),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
          // dropdown_menu_for_department(),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: const BorderSide(color: Colors.grey),
              ),
            ),
            hint: Text(AppLocalizations.of(context)!.translate("Select Department") ?? "select Department"),
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
                child: Text(AppLocalizations.of(context)!.translate(department["departmentName"])??department["departmentName"]),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
          // dropdown_menu_for_department(),


          DropdownButtonFormField<String>(
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
            hint:  Text(AppLocalizations.of(context)!.translate("Select Designation") ??"Select Designation"),
            onChanged: (newValue) {
              setState(() {
                _selecteddesignation = newValue!;
              });
            },
            items: designation!.map((designation) {
              return DropdownMenuItem<String>(
                value: designation["designationName"],
                child: Text( AppLocalizations.of(context)!.translate(designation["designationName"])??designation["designationName"]),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * .06,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading
                    ? null // Disable button while loading
                    : () async {
                  if(_selectIndustry == null){
                    snackBar().display(context, "please select Industry", Colors.red);
                  }
                  else if(_selecteddepartment == null){
                    snackBar().display(context, "please select Department", Colors.red);
                  }
                  else if(_selecteddesignation == null){
                    snackBar().display(context, "please select Designation", Colors.red);
                  }

                  else if (_formKey.currentState!.validate()) {

                    setState(() {
                            _isLoading = true;
                          });
                          await _uploadImage();
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
                    :  Text(
                  AppLocalizations.of(context)!.translate('Register') ?? "Register",
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
    final response = await http.get(Uri.parse("https://diamond-platform-12038fd67b59.herokuapp.com/department/department/$_selectIndustry"));
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
  Future<void> fetch_industry() async{
    final response = await http.get(Uri.parse("https://diamond-platform-12038fd67b59.herokuapp.com/industry/industry"));
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
   dropdown_menu_for_department(){
   return FutureBuilder<List<String>>(
     future: getAlldepartment(),
     builder: (context, snapshot) {
       if (snapshot.hasData) {
         var data = snapshot.data!;
         return DropdownButton(
           // Initial Value
           value: dropdownvalue ?? data[0],

           // Down Arrow Icon
           icon: const Icon(Icons.keyboard_arrow_down),

           // Array list of items
           items: data.map((String items) {
             return DropdownMenuItem(
               value: items,
               child: Text(items),
             );
           }).toList(),
           // After selecting the desired option,it will
           // change button value to selected value
           onChanged: (String? newValue) {
             setState(() {
               dropdownvalue = newValue!;
             });
           },
         );
       } else {
         return const CircularProgressIndicator();
       }
     },
   );
  }
  String? dropdownvalue;

  Future<List<String>> getAlldepartment() async {
    var baseUrl = "https://diamond-platform-12038fd67b59.herokuapp.com/department/department";

    http.Response response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      List<String> items = [];
      var jsonData = json.decode(response.body) as List;
      for (var element in jsonData) {
        items.add(element["ClassName"]);
      }
      return items;
    } else {
      throw response.statusCode;
    }
  }
  Future<List<String>> getAllIndustry() async {
    var baseUrl = "https://diamond-platform-12038fd67b59.herokuapp.com/industry/industry";

    http.Response response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      List<String> items = [];
      var jsonData = json.decode(response.body) as List;
      for (var element in jsonData) {
        items.add(element["ClassName"]);
      }
      return items;
    } else {
      throw response.statusCode;
    }
  }
}


class AadhaarCardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text;

    if (text.length <= 12) {
      String formatted = '';

      for (int i = 0; i < text.length; i++) {
        if (i == 4 || i == 8) {
          formatted += ' ';
        }
        formatted += text[i];
      }

      return TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }

    return oldValue;
  }

}
