import 'package:flutter/material.dart';

import './profile.dart';
import './adddesc.dart';
import './splashscreen.dart';
import './login.dart';
import './signup_a.dart';
import './signup_b.dart';
import './main_pages/subcategory.dart';
import './golive_screen.dart';
import './main_pages/viewlive.dart';
import './other_profile.dart';
import './search/search.dart';
import './donate.dart';
import './wallet.dart';
import './myhomepage.dart';


void main() {

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
        primaryColor: Color(0xfffd6a02), accentColor: Color(0xfffd6a02)),
    title: 'Simosa',
    initialRoute: '/',
    routes: {
      '/': (context) => SplashFull(),
      '/Home': (context) => MyHomePage(),
      '/Login': (context) => LoginFull(),
      '/Profile': (context) => Profile(),
      '/AddDesc': (context) => AddDescFull(),
      '/SignUpA': (context) => SignupAFull(),
      '/SignUpB': (context) => SignupBFull(),
      '/Sub': (context) => SubCategoryFull(),
      '/ScreenRecord': (context) => ScreenRecord(),
      '/ViewLive': (context) => ViewLive(),
      '/OtherProfile': (context) => OtherProfile(),
      '/Donate': (context) => Donate(),
      '/Wallet': (context) => Wallet(),
      'Search': (context) => Search(),

    },
  ));
}


