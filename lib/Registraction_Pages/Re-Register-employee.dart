import 'dart:convert';
import 'dart:io';
import 'package:diamondplatform/main.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Registraction_Pages/Employee_regitraction.dart';
import '../../Widget/snackbar.dart';
import '../../model/service.dart';

void main(){
  runApp(MaterialApp(home: ProfilePageEmployee()));
}

class ProfilePageEmployee extends StatefulWidget {
  //const ProfilePageEmployee({super.key});
  String? mobile;
  ProfilePageEmployee({
    this.mobile
});
  @override
  State<ProfilePageEmployee> createState() => _ProfilePageEmployeeState();
}

class _ProfilePageEmployeeState extends State<ProfilePageEmployee> {
  var currentCompany = 1;
  var method = 1;
  final TextEditingController company_Name = TextEditingController();
  final TextEditingController salary = TextEditingController();
  final TextEditingController price = TextEditingController();
  bool _isImageSelected = false;
  bool _isUpdatingProfile = false;
  bool isLoading = false;
  List<String> cities = [];
  String? selectedCity = 'Bhavnagar';
  List? department = [];
  List? designation = [];
  String? _selecteddepartment;
  String? _selecteddesignation;
  bool isVerify = false;
  File? _selectedImage;
  bool _isUploading = false;
  String _selectedGender = 'Male';
  late String profileImgPath = '';
  var getProfileImgURL = '';
  final picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  final TextEditingController _contactNo1Controller = TextEditingController();
  final TextEditingController _contactNo2Controller = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _aadhaarController = TextEditingController();

  //profile Photo

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _selectedImage = File(pickedFile.path);
        _isImageSelected = true; // Set the flag to true when an image is picked
      }
    });
  }

  Future<void> _uploadProfileImage() async {
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
        profileImgPath = jsonResponse['iamge_path'];


        // Now you can set your image using the 'imagePath' variable
      } else {}
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<void> _updateProfile() async {

    final String apiUrl = 'https://diamond-server.vercel.app/employee_approval_update/${widget.mobile}';

    final Map<String, dynamic> data = {
      'name': _nameController.text,
      'city': selectedCity,
      'adress': _addressController.text,
      'mobileNumber2': _contactNo2Controller.text,
      'adharNumber': _aadhaarController.text,
      'gender': _selectedGender,
      'department': _selecteddepartment,
      'designation': _selecteddesignation,
      'adharPhoto': profileImgPath,
      'status' : "Reapproval".toString(),
    //  'deniedReason': [],
      //'password': _password,
      //'employeeImage': profileImgPath,

    };
      print(json.encode(data));
    final response = await http.put(
      Uri.parse("https://diamond-server.vercel.app/employee_approval_update/${widget.mobile}"),

      body: data
    );
    print(response.body);
    if (response.statusCode == 200) {
     snackBar().display(context, 'Register data Updated Sucessfully', Colors.blue);
      // Successful update, handle accordingly

      // Parse the response body as JSON
      final Map<String, dynamic> responseData = json.decode(response.body);

      // Assuming there is a field named 'message' in the response
      final String message = responseData['message'];
      print(message);
      // Print the message or any other relevant data

    } else {
      // Handle errors here
      print('Failed to update profile');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    getApiEmployee().then((_) {
      setState(() {
        isLoading =
        false; // After the response is received, set isLoading to false
      });
    });
    fetchCities();
    fetch_department();
    fetch_designation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.translate('Re-Registration') ??
            "Re-Registration"),
      ),
      body: Stack(children: [
        Form(
          key: _formKey,
          child: AnimatedOpacity(
            opacity: isLoading ? 0.0 : 1.0,
            duration: Duration(milliseconds: 300),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [

                    const SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    TextFormField(

                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText:
                        AppLocalizations.of(context)!.translate('Name') ??
                            "Name",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(
                              color: Colors.black), // Specify border color
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
                      controller: _addressController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!
                            .translate('Address:') ??
                            "Address",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(
                              color: Colors.black), // Specify border color
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: selectedCity ?? "choose the city",
                      items: cities.map((String city) {
                        return DropdownMenuItem<String>(
                            value: city, child: Text(city));
                      }).toList(),
                      onChanged: (value) {
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
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _contactNo1Controller,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(10),
                      ],
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!
                            .translate('Contact') ??
                            "Contact",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(
                              color: Colors.black), // Specify border color
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a contact number';
                        } else if (value.length < 10) {
                          return 'Please enter valid mobile number';
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
                        labelText: AppLocalizations.of(context)!
                            .translate('Contact 2') ??
                            "Contact 2",
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
                        labelText:
                        AppLocalizations.of(context)!.translate('Gender') ??
                            "Gender",
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
                          child: Text(
                            AppLocalizations.of(context)!.translate(value) ??
                                value,
                          ),
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

                    const SizedBox(height: 10),
                    TextFormField(
                      // initialValue: 'yash',
                      controller: _aadhaarController,
                      inputFormatters: [
                        AadhaarCardNumberFormatter(),
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        suffixIcon: TextButton(
                          onPressed: () {
                            setState(() {
                              isVerify = true;
                            });
                          },
                          child: const Text(
                            "Verify",
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                        labelText: AppLocalizations.of(context)!
                            .translate('Aadhar Number') ??
                            "Aadhar Number",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter aadhar card number';
                        }
                        return null;
                      },
                    ),
                    isVerify == true
                        ? Column(
                      children: [
                        const SizedBox(height: 10),
                        TextFormField(
                          decoration: InputDecoration(
                              suffixIcon: TextButton(
                                onPressed: () {
                                  setState(() {
                                    isVerify = false;
                                  });
                                },
                                child: const Text("Submit"),
                              ),
                              hintText: "Enter Verification code",
                              border: OutlineInputBorder(
                                  borderRadius:
                                  BorderRadius.circular(10))),
                        )
                      ],
                    )
                        : const SizedBox(height: 10),
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
                              ? AppLocalizations.of(context)!
                              .translate("Add Your Aadhaar Card Photo") ??
                              "Add Your Aadhaar Card Photo"
                              : "Image Selected",
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
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
                      hint: Text(
                        AppLocalizations.of(context)!
                            .translate('Select Department') ??
                            "Select Department",
                      ),
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
                          child: Text(AppLocalizations.of(context)!
                              .translate(department["departmentName"]) ??
                              department["departmentName"]),
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
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "please select designation";
                        }
                        return null;
                      },
                      value: _selecteddesignation,
                      hint: Text(_selecteddesignation ?? ""),
                      onChanged: (newValue) {
                        setState(() {
                          _selecteddesignation = newValue!;
                        });
                      },
                      items: designation!.map((designation) {
                        return DropdownMenuItem<String>(
                          value: designation["designationName"],
                          child: Text(AppLocalizations.of(context)!
                              .translate(designation["designationName"]) ??
                              designation["designationName"]),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 10),
                    if (_isUpdatingProfile)
                      Positioned.fill(
                        child: Center(
                          child: AnimatedDotsLoader(),
                        ),
                      ),
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * .06,
                        width:
                        double.infinity, // Increase the width of the button
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          onPressed: () async {
                            if(_formKey.currentState!.validate()){
                              if(profileImgPath ==null||profileImgPath == ""&& _selectedImage == null){
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text("Please select the Aadhar Image")));
                              }
                              else{
                                setState(() {
                                  _isUpdatingProfile =
                                  true; // Show CircularProgressIndicator
                                });
                                if (_isImageSelected) await _uploadProfileImage();
                                await _updateProfile();
                                setState(() {
                                  _isUpdatingProfile =
                                  false; // Hide CircularProgressIndicator
                                });
                              }

                            }

                          },
                          child: Text(
                            AppLocalizations.of(context)!.translate('Update') ??
                                "Update",
                            style: TextStyle(fontSize: 18.0),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (isLoading) Center(child: AnimatedDotsLoader())
      ]),
    );
  }

  //fetch data

  Future<void> fetchCities() async {
    final response =
    await http.get(Uri.parse('https://diamond-server.vercel.app/city'));

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

  Future<void> fetch_department() async {
    final response = await http.get(
        Uri.parse("https://diamond-server.vercel.app/department/department"));
    try {
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        setState(() {
          department = data["data"];
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  fetch_designation() async {
    var endpointUrl =
        'https://diamond-server.vercel.app/designation/$_selecteddepartment';
    var response = await http.get(Uri.parse(endpointUrl));

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      setState(() {
        designation = data["data"];
      });
    } else {
      setState(() {
        designation = [];
      });
      //  designation = [];
    }
  }

  //getApiEmployee

  Future<Map<String, dynamic>> getApiEmployee() async {
    setState(() {
      isLoading = true; // Set loading state to true
    });
    final url = Uri.parse(
      'https://diamond-server.vercel.app/employee_data/${widget.mobile}', // Replace with your API URL
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      var data = json.decode(response.body);

      _nameController.text = data['data'][0]['name'];
      _addressController.text = data['data'][0]['adress'];
      selectedCity = data['data'][0]['city'];
      _contactNo1Controller.text = data['data'][0]['mobileNumber'].toString();
      _contactNo2Controller.text =
      data['data'][0]['mobileNumber2'].toString() == "null"
          ? ""
          : data['data'][0]['mobileNumber2'].toString();
      _selectedGender = data['data'][0]['gender'];
      _aadhaarController.text = data['data'][0]['adharNumber'].toString();
      _selecteddepartment = data['data'][0]['department'];
      _selecteddesignation = data['data'][0]['designation'];

      return data['data'][0];
    } else {
      throw Exception('Failed to load data');
    }
  }
}

class AnimatedDotsLoader extends StatefulWidget {
  @override
  _AnimatedDotsLoaderState createState() => _AnimatedDotsLoaderState();
}

class _AnimatedDotsLoaderState extends State<AnimatedDotsLoader> {
  int dotCount = 4; // Number of dots
  double dotSize = 10.0; // Size of each dot
  double spacing = 5.0; // Spacing between dots
  Color dotColor = Colors.blue; // Color of the dots
  Duration animationDuration =
  Duration(milliseconds: 400); // Duration of the animation

  @override
  void initState() {
    super.initState();
    startAnimation();
  }

  void startAnimation() {
    Future.delayed(animationDuration, () {
      if (mounted) {
        setState(() {
          dotCount = (dotCount + 1) % 4; // Increment the dot count
        });
        startAnimation();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> dots = [];

    for (int i = 0; i < dotCount; i++) {
      dots.add(
        Container(
          width: dotSize,
          height: dotSize,
          margin: EdgeInsets.symmetric(horizontal: spacing / 2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: dotColor,
          ),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: dots,
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
