import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SignInDemo extends StatefulWidget {
  @override
  State createState() => SignInDemoState();
}

class SignInDemoState extends State<SignInDemo> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  User? _user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Google Sign-In Demo with Firebase'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_user == null)
              ElevatedButton(
                onPressed: _handleSignIn,
                child: Text('Sign in with Google'),
              )
            else
              Column(
                children: <Widget>[
                  CircleAvatar(

                    backgroundImage: NetworkImage(_user!.photoURL.toString()),
                    maxRadius: 60,
                  ),
                  Text('Welcome, ${_user!.displayName}'),
                  Text('Email: ${_user!.email}'),
                  ElevatedButton(
                    onPressed: _handleSignOut,
                    child: Text('Sign out'),
                  ),
                ],
              ),
          ],
        ),
      ),
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

  Future<void> _handleSignOut() async {
    await _auth.signOut();
    await googleSignIn.signOut();

    setState(() {
      _user = null;
    });
  }
}
