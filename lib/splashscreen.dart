import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';


class SplashFull extends StatefulWidget {
  @override
  _SplashFullState createState() => _SplashFullState();
}

class _SplashFullState extends State<SplashFull> {
  @override
  void initState() {
    _loadUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset("assets/images/logo.png", height: 250),
      ),
    );
  }

  _loadUser() async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    FirebaseUser user = await _auth.currentUser();
    if (user == null) {
      Future.delayed(const Duration(milliseconds: 2000), () {
      Navigator.pushReplacementNamed(context, '/Login');
      });
    } else {
      Future.delayed(const Duration(milliseconds: 2000), () {
        Navigator.pushReplacementNamed(context, '/Home');
      });
    }
  }
}
