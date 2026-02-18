import 'package:baseliae_flutter/Component/OnbordingAppbar.dart';
import 'package:baseliae_flutter/Screens/Onbording/ChargeLeaderLogin.dart';
import 'package:baseliae_flutter/Screens/Onbording/ChargeLeaderScreen.dart';
import 'package:baseliae_flutter/Screens/Onbording/phoneChargeLeaderScreen.dart';
import 'package:baseliae_flutter/Style/AppStyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Choseauthmethodscreen extends StatefulWidget {
  const Choseauthmethodscreen({super.key});

  @override
  State<Choseauthmethodscreen> createState() => _ChoseauthmethodscreenState();
}

class _ChoseauthmethodscreenState extends State<Choseauthmethodscreen> {
  String accounttype = Get.arguments["accountType"];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whit,
      appBar: OnbordingAppbar(context, "Sign in"),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            SizedBox(
              height: 40,
            ),
            Center(
                child: Image.asset(
              "assets/images/Enter OTP-amico 1.png",
              height: 184,
              width: 184,
            )),
            SizedBox(
              height: 40,
            ),
            Center(
                child: Text(
              "Register Your Account With",
              style: robotostyle(purpal, 24, FontWeight.w600),
            )),
            SizedBox(
              height: 10,
            ),
            Center(
                child: Text(
              "Create your new account using",
              style: robotostyle(semigray, 17, FontWeight.w400),
            )),
            SizedBox(
              height: 30,
            ),
            Center(
              child: GestureDetector(
                onTap: () {
                  if (accounttype == 'Church Leader') {
                    Get.to(() => PhoneChargeLeaderScreen(),
                        arguments: {'accountType': accounttype});
                  } else if (accounttype == 'Church Page') {
                    Get.to(() => Chargeleaderlogin());
                  }else {
                    Get.toNamed('phonesignup',
                        arguments: {'accountType': accounttype});
                  }
                },
                child: Container(
                  padding: EdgeInsets.all(10),
                  height: 40,
                  width: 150,
                  decoration: BoxDecoration(
                    color: purpal,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Color(0XFFDCDCDC)),
                  ),
                  child: Center(
                      child: Text(
                    "Mobile",
                    style: robotostyle(whit, 14.75, FontWeight.w400),
                  )),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Center(
                child: Text(
              "or",
              style: robotostyle(purpal, 12.75, FontWeight.w400),
            )),
            SizedBox(
              height: 10,
            ),
            Center(
              child: GestureDetector(
                onTap: () {
                  if (accounttype == 'Church Leader') {
                    Get.to(() => Chargeleaderscreen(),
                        arguments: {'accountType': accounttype});
                  } else if (accounttype == 'Church Page') {
                    Get.to(() => Chargeleaderlogin());
                  } else {
                    Get.toNamed('emailsignup', arguments: {
                      'accountType': accounttype,
                      'existingChurchPageId': null
                    });
                  }
                },
                child: Container(
                  padding: EdgeInsets.all(10),
                  height: 40,
                  width: 150,
                  decoration: BoxDecoration(
                    color: purpal,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Color(0XFFDCDCDC)),
                  ),
                  child: Center(
                      child: Text(
                    "Email",
                    style: robotostyle(whit, 14.75, FontWeight.w400),
                  )),
                ),
              ),
            ),
            SizedBox(
              height: 40,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Already have an account? ",
                  style: robotostyle(semigray, 14, FontWeight.w400),
                ),
                GestureDetector(
                    onTap: () {
                      Get.toNamed('login');
                    },
                    child: Text(
                      "Login!",
                      style: robotostyle(purpal, 14, FontWeight.w400),
                    )),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Column(
              children: [
                Text(
                  "Protected by reCAPTCHA and subject to the",
                  style: robotostyle(semigray, 12, FontWeight.w400),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Rhombus",
                      style: robotostyle(semigray, 12, FontWeight.w400),
                    ),
                    Text(
                      "Privacy Policy",
                      style: robotostyle(purpal, 12, FontWeight.w400),
                    ),
                    Text(
                      " and ",
                      style: robotostyle(semigray, 12, FontWeight.w400),
                    ),
                    Text(
                      "Terms of Service.",
                      style: robotostyle(purpal, 12, FontWeight.w400),
                    ),
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
