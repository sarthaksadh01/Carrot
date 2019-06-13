import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignupBFull extends StatefulWidget {
  final String name, email, photo;
  const SignupBFull({Key key, this.name, this.email, this.photo})
      : super(key: key);
  @override
  _SignupBFullState createState() => _SignupBFullState(name, email, photo);
}

class _SignupBFullState extends State<SignupBFull> {
  String name, email, photo;
  _SignupBFullState(this.name, this.email, this.photo);
  DateTime t;
  bool otp = false, vfy = false, loading = false;
  String uname = "", phone = "", password = "", gender = "";
  final TextEditingController _uname = new TextEditingController();
  final TextEditingController _pno = new TextEditingController();
  @override
  void initState() {
    if (photo == null) photo = "null";
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
      body: ListView(
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
                inputFormatters: [
                  new BlacklistingTextInputFormatter(new RegExp(
                      '[\\.|\\,|\\!|\\#|\\%|\\^|\\&|\\*|\\(|\\)|\\~|\\`|\\[|\\{|\\]|\\}|\\;|\\:|\\"|\\?|\\/|\\>|\\<|\\ ]')),
                ],
                maxLength: 8,
                controller: _uname,
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
                maxLength: 10,
                controller: _pno,
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
                              borderSide: new BorderSide(color: Colors.teal))),
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
                        }, currentTime: DateTime.now(), locale: LocaleType.en);
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
      ),
      bottomNavigationBar: MaterialButton(
        height: 45,
        color: Color(0xfffd6a02),
        child: loading == false
            ? Text(
                "Register",
                style: TextStyle(color: Colors.white),
              )
            : CircularProgressIndicator(
                valueColor: new AlwaysStoppedAnimation<Color>(
                Colors.white,
              )),
        onPressed: () {
          if (!loading) _sendOtp();
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
      loading = true;
    });
    _checkUserName();
  }

  _checkUserName() {
    Firestore.instance
        .collection('Users')
        .where('username', isEqualTo: uname.trim())
        .getDocuments()
        .then((docSnapshot) {
      int _numberOfUsers = docSnapshot.documents.length;
      if (_numberOfUsers == 0) {
        _saveData();
      } else {
        Fluttertoast.showToast(
            msg: "Username already exist!",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            timeInSecForIos: 1,
            backgroundColor: Color(0xfffd6a02),
            textColor: Colors.white,
            fontSize: 16.0);
        setState(() {
          loading = false;
        });
      }
    });
  }

  _saveData() async {
    await FirebaseAuth.instance.signOut();
    final FirebaseAuth _auth = FirebaseAuth.instance;
    _auth
        .createUserWithEmailAndPassword(
            email: email.trim(), password: password.trim())
        .then((FirebaseUser user) {
      Firestore.instance.collection('Users').document(user.uid).setData({
        'name': name,
        'username': uname.trim(),
        'email': email,
        'phone': phone.trim(),
        "dob": t.toString(),
        'gender': gender,
        'pic': photo,
        'time': new DateTime.now().millisecondsSinceEpoch,
        'level': 1,
        'followers': FieldValue.arrayUnion([]),
        'following': [],
        'wallet':0
      }).then((onValue) {
        Navigator.pushReplacementNamed(context, '/Home');
      }).catchError((e) {
        Fluttertoast.showToast(
            msg: e.message,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIos: 1,
            backgroundColor: Color(0xfffd6a02),
            textColor: Colors.white,
            fontSize: 16.0);
        setState(() {
          loading = false;
        });
      });
    }).catchError((e) {
      Fluttertoast.showToast(
          msg: e.message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIos: 1,
          backgroundColor: Color(0xfffd6a02),
          textColor: Colors.white,
          fontSize: 16.0);
      setState(() {
        otp = false;
        loading = false;
      });
    });
  }
}
