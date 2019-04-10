import 'package:flutter/material.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';
import './signup_b.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SignupA extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SignupAFull(),
    );
  }
}

class SignupAFull extends StatefulWidget {
  @override
  _SignupAFullState createState() => _SignupAFullState();
}

class _SignupAFullState extends State<SignupAFull> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset("assets/images/logo.png", height: 250),
            Padding(
              padding: EdgeInsets.all(10),
              child: GoogleSignInButton(onPressed: () {
                _googleSignIn();
        
              }),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: FacebookSignInButton(onPressed: () {}),
            ),
          ],
        ),
      ),
    );
  }

  _googleSignIn() async {
    final googleSignIn = new GoogleSignIn();
    GoogleSignInAccount user = googleSignIn.currentUser;
    await googleSignIn.signIn().then((account) {
      user = account;
    }, onError: (error) {
      Fluttertoast.showToast(
          msg: error.toString(),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIos: 1,
          backgroundColor: Color(0xfffd6a02),
          textColor: Colors.white,
          fontSize: 16.0);
    }).whenComplete(() {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                SignupB(user.displayName, user.email, user.photoUrl)),
      );
    });
  }
}
