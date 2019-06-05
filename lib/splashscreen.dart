import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SplashFull extends StatefulWidget {
  @override
  _SplashFullState createState() => _SplashFullState();
}

class _SplashFullState extends State<SplashFull> {
  @override
  void initState() {
    _permission();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xfffd6a02),
        body: Center(
            child: Image.asset(
          "assets/images/logo.png",
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
        ))
        //

        //
        );
  }

  _permission() async {
    // _nextPage();
    const platform = const MethodChannel('samples.flutter.io/screen_record');
    try {
      final String result = await platform.invokeMethod('requestPermission');
      if (result == "granted") {
        _nextPage();
      } else if (result == "denied") {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              // return object of type Dialog
              return AlertDialog(
                title:
                    new Text("Camera and Microphone permissions are required!"),
                content: new Text("open app settings?"),
                actions: <Widget>[
                  // usually buttons at the bottom of the dialog
                  new FlatButton(
                    child: new Text("open"),
                    onPressed: () async {
                      final String result =
                          await platform.invokeMethod('openSettings');
                    },
                  ),
                  new FlatButton(
                    child: new Text("done"),
                    onPressed: () {
                      _permission();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            });

        Fluttertoast.showToast(
            msg: "Please enable permissions in setting",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIos: 1,
            backgroundColor: Colors.black,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    } on PlatformException catch (e) {}
  }

  _nextPage() async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    FirebaseUser user = await _auth.currentUser();
    if (user == null) {
      Future.delayed(const Duration(milliseconds: 3000), () {
        Navigator.pushReplacementNamed(context, '/Login');
      });
    } else {
      Future.delayed(const Duration(milliseconds: 3000), () {
        Navigator.pushReplacementNamed(context, '/Home');
      });
    }
  }
}
