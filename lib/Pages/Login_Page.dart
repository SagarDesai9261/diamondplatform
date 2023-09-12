// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:diamondplatform/Pages/company/home_page.dart';
import 'package:diamondplatform/Pages/employee/home_page.dart';
import 'package:diamondplatform/Registraction_Pages/Register_page.dart';
import 'package:http/http.dart' as http;
import 'package:diamondplatform/Widget/snackbar.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  User? _user;
  final formkey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;
  TextEditingController mobile = TextEditingController();
  TextEditingController password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop:() {  SystemNavigator.pop(); return Future.value(false); },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text('login_screen_title'.tr()),
          actions: [
            IconButton(
              onPressed: () {
                _showLanguageDialog(context);
              },
              icon: const Icon(Icons.language),
            ),
          ],
        ),
        body: Form(
          key: formkey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 50,
                ),
                const CircleAvatar(
                  backgroundImage: AssetImage('assets/logo.png'),
                  maxRadius: 120,
                ),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: mobile,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(10),
                    ],
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.phone_android,
                        color: Colors.black,
                      ),
                      hintText: 'mobile_hint'.tr(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Mobile is required';
                      } else if (value.length < 10) {
                        return "Mobile number is invalid";
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: password,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.security,
                        color: Colors.black,
                      ),
                      hintText: 'password_hint'.tr(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    obscureText: _obscurePassword,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Password is required';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * 0.06,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (formkey.currentState!.validate()) {
                          setState(() {
                            _isLoading = true;
                          });
                          await login();
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
                          ? const CircularProgressIndicator(
                        backgroundColor: Colors.white,
                        color: Colors.black,
                      )
                          : Text(
                        'login'.tr(),
                        style: const TextStyle(fontSize: 18.0),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                OutlinedButton.icon(
                  onPressed: () {
                    _handleSignIn();
                  },
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  icon: const Icon(Icons.login),
                  label: const Text('Sign in with Google'),
                ),
                const SizedBox(
                  height: 50,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'create_account'.tr(),
                      style: const TextStyle(fontSize: 14),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => RegistrationPage()));
                      },
                      child: Text(
                        'register_now'.tr(),
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> login() async {
    var response = await http.post(
        Uri.parse(
            "https://diamond-platform-12038fd67b59.herokuapp.com/employee/login"),
        body: {"mobileNumber": mobile.text, "password": password.text});
    var data = json.decode(response.body);

    if (data["statusCode"] == 403) {
      final response1 = await http.post(
          Uri.parse(
              "https://diamond-platform-12038fd67b59.herokuapp.com/company/login"),
          body: {"mobileNumber": mobile.text, "password": password.text});
      var jsonResponse = jsonDecode(response1.body);
      if (jsonResponse['statusCode'] == 402 ||
          jsonResponse['statusCode'] == 403) {
        snackBar s = snackBar();
        s.display(context, 'Mobile Number And Password Is Invalid', Colors.red);
      } else {
        Map<String, dynamic> decodeToken =
        JwtDecoder.decode(jsonResponse["token"]);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_details', jsonEncode(decodeToken));
        await prefs.setString("isLogin", "Yes");
        await prefs.setString("isEmployee", "false");
        await prefs.setString("token", jsonResponse["token"]);
        var _id = decodeToken["_id"];
        print(_id);
        final String apiUrl =
            'https://diamond-platform-12038fd67b59.herokuapp.com/company/${_id}';
        var token = jsonResponse["token"];
        var notificationtoken = prefs.getString("NotificationToken");
        final Map<String, dynamic> datatoken = {
          'token':notificationtoken.toString()
        };
        var response2 = await http.put(
          Uri.parse(apiUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: json.encode(datatoken),
        );
        if(response2.statusCode == 200){
          snackBar().display(context, "Login Successfully", Colors.green);

          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      Home_Page_company()));
        }
      }
    } else if (data["statusCode"] == 200) {
      var jsonResponse = jsonDecode(response.body);
      Map<String, dynamic> decodeToken =
      JwtDecoder.decode(jsonResponse["token"]);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_details', jsonEncode(decodeToken));
      await prefs.setString("isEmployee", "true");
      await prefs.setString("isLogin", "Yes");
      await prefs.setString("token", jsonResponse["token"]);
      var _id = decodeToken["_id"];
      print(_id);
      final String apiUrl =
            'https://diamond-platform-12038fd67b59.herokuapp.com/employee/${_id}';
      var token = jsonResponse["token"];
      var notificationtoken = prefs.getString("NotificationToken");
      final Map<String, dynamic> datatoken = {
        'token':notificationtoken.toString()
      };
      var response2 = await http.put(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(datatoken),
      );
      if(response2.statusCode == 200){
        snackBar().display(context, "Login Successfully", Colors.green);
        print(prefs.getStringList("notification_data"));
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    Home_page_employee()));
      }

    }
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('select_language'.tr()),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLanguageButton(context, const Locale('en', 'US'), 'english'),
              _buildLanguageButton(context, const Locale('hi', 'IN'), 'hindi'),
              _buildLanguageButton(context, const Locale('gu', 'IN'), 'gujarati'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageButton(
      BuildContext context, Locale locale, String language) {
    return TextButton(
      onPressed: () async{
        context.setLocale(locale);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('selectedLanguage', language);
        Navigator.pop(context); // Close the dialog
      },
      child: Text(language.tr()),
    );
  }
  Future<void> _handleSignIn() async {
    try {
      final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount!.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      final UserCredential authResult = await _auth.signInWithCredential(credential);
      final User? user = authResult.user;

      setState(() {
        _user = user;
        print(_user);
      });
    } catch (error) {
      print("Google Sign-In Error: $error");
    }
  }
}
