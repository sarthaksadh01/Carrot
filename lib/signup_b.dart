import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './main.dart';
import 'package:phone_auth_simple/phone_auth_simple.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_database/firebase_database.dart';

class SignupBFull extends StatefulWidget {
  final String name, email, photo;
  const SignupBFull({Key key,this.name, this.email, this.photo})
 : super(key: key);
  @override
  _SignupBFullState createState() => _SignupBFullState(name, email, photo);
}

class _SignupBFullState extends State<SignupBFull> {
   String name, email, photo;
  _SignupBFullState(this.name, this.email, this.photo);
  DateTime t;
  bool otp = false, vfy = false;
  String uname = "", phone = "", password = "", gender = "";
  @override
  void initState() {
    if(photo==null)photo="null";
    super.initState();
  }

  var bdate = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xfffd6a02),
        title: Text("Register"),
      ),
      body: otp == false
          ? ListView(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 15),
                  child: Image.asset(
                    "assets/images/logob.png",
                    height: 200,
                  ),
                ),
                Padding(
                    padding: EdgeInsets.fromLTRB(30, 20, 30, 10),
                    child: TextField(
                      onChanged: (val) {
                        setState(() {
                          uname = val;
                        });
                      },
                      decoration: new InputDecoration(
                          prefixIcon: Icon(Icons.portrait),
                          hintText: "User Name",
                          border: new OutlineInputBorder(
                              borderSide: new BorderSide(color: Colors.teal))),
                    )),
                Padding(
                    padding: EdgeInsets.fromLTRB(30, 0, 30, 10),
                    child: TextField(
                      obscureText: true,
                      onChanged: (val) {
                        setState(() {
                          password = val;
                        });
                      },
                      decoration: new InputDecoration(
                          prefixIcon: Icon(Icons.apps),
                          hintText: "Password",
                          border: new OutlineInputBorder(
                              borderSide: new BorderSide(color: Colors.teal))),
                    )),
                Padding(
                    padding: EdgeInsets.fromLTRB(30, 0, 30, 10),
                    child: TextField(
                      onChanged: (val) {
                        setState(() {
                          phone = val;
                        });
                      },
                      keyboardType: TextInputType.phone,
                      decoration: new InputDecoration(
                          prefixIcon: Icon(Icons.phone),
                          hintText: "Phone Number",
                          border: new OutlineInputBorder(
                              borderSide: new BorderSide(color: Colors.teal))),
                    )),
                Padding(
                    padding: EdgeInsets.fromLTRB(30, 0, 30, 10),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: TextField(
                            controller: bdate,
                            enabled: false,
                            onChanged: (val) {
                              setState(() {
                                phone = val;
                              });
                            },
                            keyboardType: TextInputType.phone,
                            decoration: new InputDecoration(
                                prefixIcon: Icon(Icons.calendar_today),
                                hintText: "Date of Birth!",
                                border: new OutlineInputBorder(
                                    borderSide:
                                        new BorderSide(color: Colors.teal))),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: IconButton(
                            color: Colors.white,
                            onPressed: () {
                              DatePicker.showDatePicker(context,
                                  showTitleActions: true,
                                  minTime: DateTime(1900, 01, 01),
                                  maxTime: DateTime(2016, 12, 30),
                                  onChanged: (date) {}, onConfirm: (date) {
                                setState(() {
                                  t = date;
                                  bdate.text = "${t.day}/${t.month}/${t.year}";
                                });
                              },
                                  currentTime: DateTime.now(),
                                  locale: LocaleType.en);
                            },
                            icon: Icon(
                              Icons.calendar_today,
                              color: Color(0xfffd6a02),
                            ),
                          ),
                        )
                      ],
                    )),
                Padding(
                    padding: EdgeInsets.fromLTRB(30, 0, 30, 10),
                    child: Row(
                      children: <Widget>[
                        Text("Male"),
                        Radio(
                          activeColor: Color(0xfffd6a02),
                          onChanged: (val) {
                            setState(() {
                              gender = val;
                              print(gender);
                            });
                          },
                          value: "M",
                          groupValue: gender,
                        ),
                        Text("Female"),
                        Radio(
                          activeColor: Color(0xfffd6a02),
                          onChanged: (val) {
                            setState(() {
                              gender = val;
                              print(gender);
                            });
                          },
                          value: "F",
                          groupValue: gender,
                        ),
                        Text("Other"),
                        Radio(
                          activeColor: Color(0xfffd6a02),
                          onChanged: (val) {
                            setState(() {
                              gender = val;
                              print(gender);
                            });
                          },
                          value: "Other",
                          groupValue: gender,
                        ),
                      ],
                    ))
              ],
            )
          : vfy == false
              ? PhoneAuthSimple(
                  countryCode: "+91",
                  phoneNumber: phone,
                  onVerificationSuccess: () {
                    setState(() {
                      vfy = true;
                    });
                    _saveData();
                  },
                  onVerificationFailure: () {
                    setState(() {
                      vfy = false;
                      otp = false;
                    });
                    _error();
                  },
                )
              : Center(
                  child: CircularProgressIndicator(
                    backgroundColor: Color(0xfffd6a02),
                  ),
                ),
      bottomNavigationBar: MaterialButton(
        height: 45,
        color: Color(0xfffd6a02),
        child: Text(
          "Register",
          style: TextStyle(color: Colors.white),
        ),
        onPressed: () {
          _sendOtp();
        },
      ),
    );
  }

  _sendOtp() {
    if (uname.trim().length < 4) {
      Fluttertoast.showToast(
          msg: "Username too short!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIos: 1,
          backgroundColor: Color(0xfffd6a02),
          textColor: Colors.white,
          fontSize: 16.0);
      return;
    }
    if (password.trim().length < 8) {
      Fluttertoast.showToast(
          msg: "Password should be atleast 8 charachter long!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIos: 1,
          backgroundColor: Color(0xfffd6a02),
          textColor: Colors.white,
          fontSize: 16.0);

      return;
    }
    if (phone.trim().length != 10) {
      Fluttertoast.showToast(
          msg: "Invalid Phone number",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIos: 1,
          backgroundColor: Color(0xfffd6a02),
          textColor: Colors.white,
          fontSize: 16.0);
      return;
    }
    if (gender.trim() == null || t == null) {
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

    setState(() {
      otp = true;
    });
  }

  _saveData() async {
    await FirebaseAuth.instance.signOut();
    final FirebaseAuth _auth = FirebaseAuth.instance;
    _auth
        .createUserWithEmailAndPassword(
            email: email.trim(), password: password.trim())
        .then((FirebaseUser user) {
      final reference =
          FirebaseDatabase.instance.reference().child('Users').child(user.uid);
      reference.set({
        'name': name,
        'username': uname.trim(),
        'email': email,
        'phone': phone.trim(),
        "dob": t.toString(),
        'gender': gender,
        'pic': photo,
        'time': new DateTime.now().millisecondsSinceEpoch
      }).then((onValue) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MyHomePage()),
        );
      });
    }).catchError((e) {
      Fluttertoast.showToast(
          msg: e.toString(),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIos: 1,
          backgroundColor: Color(0xfffd6a02),
          textColor: Colors.white,
          fontSize: 16.0);
      setState(() {
        otp = false;
      });
    });
    
  }

  _error() {
    Fluttertoast.showToast(
        msg: "Error Verifyng phone number!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIos: 1,
        backgroundColor: Color(0xfffd6a02),
        textColor: Colors.white,
        fontSize: 16.0);
    setState(() {
      otp = false;
    });
  }
}
