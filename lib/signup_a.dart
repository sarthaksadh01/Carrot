import 'package:flutter/material.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';
import './signup_b.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SignupAFull extends StatefulWidget {
  @override
  _SignupAFullState createState() => _SignupAFullState();
}

class _SignupAFullState extends State<SignupAFull> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset("assets/images/logob.png", height: 250),
           
            // Padding(
            //   padding: EdgeInsets.all(10),
            //   child: FacebookSignInButton(onPressed: () {}),
            // ),
          ],
        ),

      ),
      bottomNavigationBar:  Padding(
              padding: EdgeInsets.all(10),
              child: GoogleSignInButton(onPressed: () {
                _googleSignIn();
              }),
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
      if(user==null)return;
      Navigator.of(context).pushReplacement(new MaterialPageRoute(
          settings: const RouteSettings(name: '/SignUpB'),
          builder: (context) => new SignupBFull(
                email: user.email,
                name: user.displayName,
                photo: user.displayName,
              )));
    });
  }
}
