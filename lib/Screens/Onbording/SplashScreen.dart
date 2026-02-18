import 'package:baseliae_flutter/Style/AppStyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ignore: unused_import
import 'WelcomeScreen.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: purpal,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
       
        children: [
         Spacer(),
   Center(child: Image.asset("assets/images/LOGO_NW 1.png")),
         Spacer(),
          Center(
            child: Padding(
              padding:  EdgeInsets.only(left: 61,right: 61,bottom:15,top: 15),
              child: ElevatedButton(
                style:AppButtonStyle(whit),
                onPressed: (){
          Get.offNamed('welcome');
                }, child: SuccessButtonChild("Get Started")),
            ),
          )
        ],
      ),
    );
  }
}