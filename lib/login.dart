import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LoginFull extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<LoginFull> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String email = "", password = "";
  bool loading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ListView(
          shrinkWrap: true,
          // mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset('assets/images/logob.png', height: 250),
            Padding(
                padding: EdgeInsets.fromLTRB(30, 20, 30, 10),
                child: TextField(
                  onChanged: (val) {
                    setState(() {
                      email = val;
                    });
                  },
                  decoration: new InputDecoration(
                      prefixIcon: Icon(Icons.email),
                      hintText: "Email",
                      border: new OutlineInputBorder(
                          borderSide: new BorderSide(color: Colors.teal))),
                )),
            Padding(
                padding: EdgeInsets.fromLTRB(30, 10, 30, 10),
                child: TextField(
                  onChanged: (val) {
                    setState(() {
                      password = val;
                    });
                  },
                  obscureText: true,
                  decoration: new InputDecoration(
                      prefixIcon: Icon(Icons.apps),
                      hintText: "Password",
                      border: new OutlineInputBorder(
                          borderSide: new BorderSide(color: Colors.teal))),
                )),
            Padding(
                padding: EdgeInsets.all(10),
                child: MaterialButton(
                  height: 45,
                  
                  color: Color(0xfffd6a02),
                  child: loading != true
                      ? Text(
                          "Login",
                          style: TextStyle(color: Colors.white),
                        )
                      : CircularProgressIndicator(
                     
                          valueColor: new AlwaysStoppedAnimation<Color>(Colors.white,),
                        ),
                  onPressed: () {
                    if (!loading) login();
                  },
                )),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
              Padding(
                padding: EdgeInsets.all(10),
                child: InkWell(
                  onTap: () {
                    Navigator.pushReplacementNamed(context, '/SignUpA');
                  },
                  child: Text(
                    "Create new Account?",
                    style: TextStyle(color: Colors.blue),
                  ),
                ))
            ],),
          ],
        ),
      ),
    );
  }

  void login() async {
    if (password.trim().length == 0 || email.trim().length == 0) {
      Fluttertoast.showToast(
          msg: "All fields are required!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIos: 1,
          backgroundColor: Color(0xfffd6a02),
          textColor: Colors.white,
          fontSize: 16.0);
      return;
    }
    if (password.length < 8) {
      Fluttertoast.showToast(
          msg: "Password should be atleast 8 charachter long",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIos: 1,
          backgroundColor: Color(0xfffd6a02),
          textColor: Colors.white,
          fontSize: 16.0);
      return;
    }
    setState(() {
      loading=true;
    });

    await _auth
        .signInWithEmailAndPassword(
            email: email.trim(), password: password.trim())
        .then((FirebaseUser user) {
      Navigator.pushReplacementNamed(context, '/Home');
    }).catchError((e) {
      setState(() {
        loading=false;
      });
      Fluttertoast.showToast(
          msg: e.toString(),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIos: 1,
          backgroundColor: Color(0xfffd6a02),
          textColor: Colors.white,
          fontSize: 16.0);
    });
  }
}
