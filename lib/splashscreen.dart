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
      backgroundColor: Color(0xfffd6a02),
      body: Center(
        child: Image.asset("assets/images/logo.png", height: MediaQuery.of(context).size.height,width: MediaQuery.of(context).size.width,),
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
      Future.delayed(const Duration(milliseconds: 5000), () {
        Navigator.pushReplacementNamed(context, '/Home');
      });
    }
  }
}
