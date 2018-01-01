import 'package:flutter/material.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';
import './signup_b.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:ui';

class SignupAFull extends StatefulWidget {
  @override
  _SignupAFullState createState() => _SignupAFullState();
}

class _SignupAFullState extends State<SignupAFull> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              color: Color(0xfffd6a02),
              child: Image.asset("assets/images/logo.png"),
            ),
            Center(
              child: new ClipRect(
                child: new BackdropFilter(
                  filter: new ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                  child: new Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    decoration: new BoxDecoration(
                        color: Colors.grey.shade200.withOpacity(0.2)),
                    child: new Center(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.all(10),
                          child: FacebookSignInButton(onPressed: () {}),
                        ),
                        Padding(
                          padding: EdgeInsets.all(10),
                          child: GoogleSignInButton(onPressed: () {
                            _googleSignIn();
                          }),
                        ),
                         Padding(
                          padding: EdgeInsets.all(10),
                          child: TwitterSignInButton(onPressed: () {
                            _googleSignIn();
                          }),
                        )
                      ],
                    )),
                  ),
                ),
              ),
            ),
            Transform.rotate(
              angle: 70,
              child:Center(child: Image.asset("assets/images/carrotlogin.png"),) ,
            )
            // 
          ],
        )

        //  Center(
        //   child: Stack(
        //     // mainAxisAlignment: MainAxisAlignment.center,
        //     children: <Widget>[
        //       Image.asset("assets/images/logob.png", height: 250),
        //       Column(
        //         mainAxisAlignment: MainAxisAlignment.end,
        //         children: <Widget>[
        //           Padding(
        //             padding: EdgeInsets.all(10),
        //             child: FacebookSignInButton(onPressed: () {}),
        //           ),
        //           Padding(
        //             padding: EdgeInsets.all(10),
        //             child: GoogleSignInButton(onPressed: () {
        //               _googleSignIn();
        //             }),
        //           )
        //         ],
        //       )
        //     ],
        //   ),
        // ),
        // bottomNavigationBar: Padding(
        //   padding: EdgeInsets.all(10),
        //   child: GoogleSignInButton(onPressed: () {
        //     _googleSignIn();
        //   }),
        // ),
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
      if (user == null) return;
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
