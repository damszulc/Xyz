import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_ui_collections/utils/utils.dart';

import '../LocalBindings.dart';
import 'page_login.dart';
import 'page_onboarding.dart';
import 'page_home.dart';
import 'package:shared_preferences/shared_preferences.dart';


class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Screen size;

  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 2), () {
       navigateFromSplash();
    });
  }

  @override
  Widget build(BuildContext context) {
     size = Screen(MediaQuery.of(context).size);
    return Scaffold(
        body: Center(
        child: Container(
          width: size.getWidthPx(300),
          height: size.getWidthPx(300),
          child: Image.asset("assets/EKOB-2.png")))
    );
  }

  Future navigateFromSplash () async {

    final prefs = await SharedPreferences.getInstance();

    if (prefs.getBool('first_run') ?? true) {
      LocalStorage.sharedInstance.deleteAll();
      prefs.setBool('first_run', false);
    }

   String isOnBoard = await LocalStorage.sharedInstance.readValue(Constants.isOnBoard);
   print("isOnBoard  $isOnBoard");
     String isLoggedIn = await LocalStorage.sharedInstance.readValue(Constants.isLoggedIn);
      print("isLoggedIn  $isLoggedIn");
      if(isOnBoard ==null || isOnBoard == "0"){
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => OnBoardingPage()));
      } else if(isLoggedIn ==null || isLoggedIn == "0"){
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
      }
      else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage()));
      }
  }
}