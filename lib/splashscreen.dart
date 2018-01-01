import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flare_flutter/flare_actor.dart';

class SplashFull extends StatefulWidget {
  @override
  _SplashFullState createState() => _SplashFullState();
}

class _SplashFullState extends State<SplashFull> {
  bool _animation = true;
  @override
  void initState() {
    _flareAnimation();
    _loadUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _animation ? Colors.white : Color(0xfffd6a02),
      body: _animation
          ? FlareActor(
              "assets/flare/splashLoading.flr",
              alignment: Alignment.center,
              fit: BoxFit.contain,
              animation: "tv2",
            )
          : Center(
              child: Image.asset(
              "assets/images/logo.png",
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
            )),
      //

      //
    );
  }

  _loadUser() async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    FirebaseUser user = await _auth.currentUser();
    if (user == null) {
      Future.delayed(const Duration(milliseconds: 4200), () {
        Navigator.pushReplacementNamed(context, '/Login');
      });
    } else {
      Future.delayed(const Duration(milliseconds: 4200), () {
        Navigator.pushReplacementNamed(context, '/Home');
      });
    }
  }

  _flareAnimation() {

     Future.delayed(const Duration(milliseconds: 3000), () {
       setState(() {
         _animation=false;
         
       });

        
     });

  }
}
