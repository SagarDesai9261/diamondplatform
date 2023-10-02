// ignore_for_file: use_build_context_synchronously
import 'package:rflutter_alert/rflutter_alert.dart';

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

import '../main.dart';
class LanguageService {
  static const String apiUrl =
      'https://diamond-platform-12038fd67b59.herokuapp.com/language';

   Future<List<dynamic>> fetchLanguageCodes() async {
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final  languages = data['data'];
      print(languages);
      return languages;
    } else {
      throw Exception('Failed to fetch language codes');
    }
  }
}
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
  Future<List>? _languages;
  bool _obscurePassword = true;
  TextEditingController mobile = TextEditingController();
  TextEditingController password = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _languages = LanguageService().fetchLanguageCodes();
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop:() {  SystemNavigator.pop(); return Future.value(false); },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(AppLocalizations.of(context)!.translate('Login')??"Login"),
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
                      hintText: AppLocalizations.of(context)!.translate('Enter your Mobile Number') ?? "Enter your Mobile Number",
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
                      hintText: AppLocalizations.of(context)!.translate('Enter your password')??"Enter your password",
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
                        //_onAlertButtonPressed(context);
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
                        AppLocalizations.of(context)!.translate('Login')??"Login",
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
                  label:  Text(AppLocalizations.of(context)!.translate('Sign in with Google') ?? "Sign in with Google"),
                ),
                const SizedBox(
                  height: 50,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.translate('Create New Account....') ?? "Create New account....",
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
                        AppLocalizations.of(context)!.translate('Register Now') ?? "Register now",
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
    print(data);
    if (data["statusCode"] == 403) {
      final response1 = await http.post(
          Uri.parse(
              "https://diamond-platform-12038fd67b59.herokuapp.com/company/login"),
          body: {"mobileNumber": mobile.text, "password": password.text});
      var jsonResponse = jsonDecode(response1.body);
      print(jsonResponse);
      if (jsonResponse['statusCode'] == 402 ||
          jsonResponse['statusCode'] == 403) {
        snackBar s = snackBar();
        s.display(context, 'Mobile Number And Password Is Invalid', Colors.red);
        setState(() {
          _isLoading = false;
        });
      }
      else if(jsonResponse["statusCode"] == 401 || data["statusCode"] == 401){
        _onAlertButtonPressed(context);
        setState(() {
          _isLoading = false;
        });
      }

      else {
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
    }
    else if(data["statusCode"]==401){
      print("hello");
      _onAlertButtonPressed(context);

    }
    else if (data["statusCode"] == 200) {
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
          title: Text(AppLocalizations.of(context)!.translate('select_language') ?? "Select Language"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FutureBuilder<List<dynamic>>(
                future: _languages,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    final List? languages = snapshot.data;
                    print(languages);
                    return Column(
                      children: [
                        for(var i in languages!) ...[
                         _buildLanguageButton(context, Locale(i["code"]), i["name"])
                        ]
                      ],
                    );

                  }
                },
              ),
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
        AppLocalizations.of(context)!.setLocale(locale);
        print(locale.languageCode);
        /*SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('selectedLanguage', locale.languageCode);*/
        setState(() {

        });
        Navigator.pop(context); // Close the dialog

      },
      child: Text(AppLocalizations.of(context)!.translate(language) ?? language),
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
  _onAlertButtonPressed(context) {
    print("hello");
    Alert(
      context: context,
      type: AlertType.warning,
      title:AppLocalizations.of(context)!.translate('Under Verifing')??"Under Verifing",
      desc: AppLocalizations.of(context)!.translate('Your Profile is under Verifing')??"Your Profile is under Verifing",
      buttons: [
        DialogButton(
          child: Text(
            "OK",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () => Navigator.pop(context),
          width: 120,
        )
      ],
    ).show();
  }
}
