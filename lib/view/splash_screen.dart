import 'dart:async';
import 'package:chat_app/main.dart';
import 'package:chat_app/theme/appcolors.dart';
import 'package:chat_app/view/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:page_transition/page_transition.dart';
import 'package:chat_app/view/authscreen/logn_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // TODO: implement initState
    Timer(const Duration(seconds: 3), () {
      // To Exit from full Screen
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: AppColor().white,
        systemNavigationBarColor: AppColor().white,
      ));

      // Checking if user is already login
      if (FirebaseAuth.instance.currentUser != null) {
        // print(FirebaseAuth.instance.currentUser);
        Navigator.pushReplacement(
            context,
            PageTransition(
                child: const HomeScreen(),
                type: PageTransitionType.rightToLeft));
      } else {
        Navigator.pushReplacement(
            context,
            PageTransition(
                child: const LoginScreen(),
                type: PageTransitionType.rightToLeft));
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return Scaffold(
      body: Center(
        child: SizedBox(
            width: mq.height * .2,
            height: mq.height * .2,
            child: Column(
              children: [
                SizedBox(
                    width: mq.height * .13,
                    height: mq.height * .13,
                    child: Image.asset("assets/images/logo.png")),
                Text(
                  "ASPIRAN Chat",
                  style: TextStyle(fontSize: 23, fontFamily: "Monopoly"),
                )
              ],
            )),
      ),
    );
  }
}
