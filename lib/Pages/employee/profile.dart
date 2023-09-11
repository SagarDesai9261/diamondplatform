import 'dart:convert';
import 'dart:io';
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

class ProfilePageEmployee extends StatefulWidget {
  const ProfilePageEmployee({super.key});

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
        print('$profileImgPath'); // Correct the key to "iamge_path"

        // Now you can set your image using the 'imagePath' variable
      } else {}
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<void> _updateProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString("token");
    var data1 = json.decode(prefs.getString("user_details")!);
    print("Data Are: ${json.encode(data1)}");
    var _id = data1["_id"];
    var _password = data1["password"];
    print("Passowrd :" + _password);
    final String apiUrl =
        'https://diamond-platform-12038fd67b59.herokuapp.com/employee/${_id}';

    final Map<String, dynamic> data = {
      'name': _nameController.text,
      'city': selectedCity,
      'adress': _addressController.text,
      'mobileNumber': _contactNo1Controller.text,
      'mobileNumber2': _contactNo2Controller.text,
      'adharNumber': _aadhaarController.text,
      'gender': _selectedGender,
      'department': _selecteddepartment,
      'designation': _selecteddesignation,
      'password': _password,
      'employeeImage': profileImgPath,
      'companyName': company_Name.text ,
      'isSalaryMethod': method == 1 ? true : false,
      'salary': salary.text,
      'price': price.text,

    };

    final response = await http.put(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      snackBar().display(context, 'Profile Updated Sucessfully', Colors.blue);
      // Successful update, handle accordingly
      print('Profile updated successfully');
      // Parse the response body as JSON
      final Map<String, dynamic> responseData = json.decode(response.body);

      // Assuming there is a field named 'message' in the response
      final String message = responseData['message'];

      // Print the message or any other relevant data
      print('${response.body}');
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
        title: Text('Profile Update'),
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
                    SizedBox(
                      height: 40,
                    ),

                    CircleAvatar(
                      maxRadius: 60,
                      backgroundImage: NetworkImage(profileImgPath),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    InkWell(
                      onTap: () {
                        getImage();
                      },
                      child: Text(
                        _isImageSelected
                            ? 'Image Selected ✔'
                            : 'Change Image', // Use the flag to change the text
                        style: TextStyle(
                          fontSize: 14,
                          color: _isImageSelected
                              ? Colors.green
                              : Colors
                              .blue, // Change color if image is selected
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'name_hint'.tr(),
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
                        labelText: 'address_hint'.tr(),
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
                        labelText: 'contact_hint'.tr(),
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
                        labelText: 'contact2_hint'.tr(),
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
                        labelText: 'aadhaar_hint'.tr(),
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

                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text("Current Company :-").tr(),
                        Expanded(
                          child: Row(
                            children: [
                              Radio(
                                  value: 1, groupValue: currentCompany, onChanged: (index) {
                                setState(() {
                                  currentCompany = 1;
                                });
                              }),
                              Expanded(
                                child: Text('none'),
                              )
                            ],
                          ),
                        ),
                        Expanded(
                          child: Row(
                            children: [
                              Radio(
                                  value: 2, groupValue: currentCompany, onChanged: (index) {
                                setState(() {
                                  currentCompany = 2;
                                });
                              }),
                              Expanded(child: Text('Yes'))
                            ],
                          ),

                        ),

                      ],
                    ),
                    const SizedBox(height: 5),

                    currentCompany == 2 ? Column(
                      children: [
                        TextFormField(
                          controller: company_Name,
                          decoration: InputDecoration(
                            labelText: 'Company Name'.tr(),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(
                                  color: Colors.black), // Specify border color
                            ),
                          ),
                          validator: (value) {
                            if ((value == null && currentCompany == 2 )|| (value!.isEmpty && currentCompany == 2) ) {
                              return 'Please enter a company name';
                            }
                            return null;
                          },
                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text("Choose method :-"),
                            Expanded(
                              child: Row(
                                children: [
                                  Radio(
                                      value: 1, groupValue: method, onChanged: (index) {
                                    setState(() {
                                      method = 1;
                                    });
                                  }),
                                  Expanded(
                                    child: Text('Salary'.tr()),
                                  )
                                ],
                              ),
                            ),
                            Expanded(
                              child: Row(
                                children: [
                                  Radio(
                                      value: 2, groupValue: method, onChanged: (index) {
                                    setState(() {
                                      method = 2;
                                    });
                                  }),
                                  Expanded(child: Text('per piece').tr())
                                ],
                              ),
                            ),
                          ],
                        ),
                        method == 1 ? TextFormField(
                          controller: salary,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(10),
                          ],
                          decoration: InputDecoration(
                            labelText: 'Enter Salary'.tr(),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(
                                  color: Colors.black), // Specify border color
                            ),
                          ),
                        ) : TextFormField(
                          controller: salary,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(10),
                          ],
                          decoration: InputDecoration(
                            labelText: 'Enter price per piece'.tr(),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(
                                  color: Colors.black), // Specify border color
                            ),
                          ),
                        ),
                      ],
                    ) :Container(),

                    const SizedBox(height: 10),
                    // dropdown_menu_for_department(),
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
                      items: department!.map((department) {
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
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "please select designation";
                        }
                        return null;
                      },
                      value: _selecteddesignation,
                      hint: Text("${_selecteddesignation}"),
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
                          },
                          child: Text(
                            'Update',
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

  Future<void> fetch_department() async {
    final response = await http.get(Uri.parse(
        "https://diamond-platform-12038fd67b59.herokuapp.com/department/department"));
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
        'https://diamond-platform-12038fd67b59.herokuapp.com/designation/$_selecteddepartment';
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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> data = json.decode(prefs.getString("user_details")!);
    var _id = data["_id"];
    final url = Uri.parse(
      'https://diamond-platform-12038fd67b59.herokuapp.com/employee/profile/$_id', // Replace with your API URL
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      print(data['data']);
      _nameController.text = data['data']['name'];
      _addressController.text = data['data']['adress'];
      selectedCity = data['data']['city'];
      _contactNo1Controller.text = data['data']['mobileNumber'].toString();
      _contactNo2Controller.text =
      data['data']['mobileNumber2'].toString() == "null"
          ? ""
          : data['data']['mobileNumber2'].toString();
      _selectedGender = data['data']['gender'];
      _aadhaarController.text = data['data']['adharNumber'].toString();
      _selecteddepartment = data['data']['department'];
      _selecteddesignation = data['data']['designation'];
      profileImgPath = data['data']['employeeImage'];

      company_Name.text = data['data']['companyName'] ?? "";
      salary.text = data["data"]["salary"]??"";
      data['data']['companyName']=="null" || data['data']['companyName']==null ? currentCompany = 1 : currentCompany = 2;
      price.text = data["data"]["price"]??"";
      print(getProfileImgURL);

      return data['data'];
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