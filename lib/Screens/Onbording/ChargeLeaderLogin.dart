import 'package:baseliae_flutter/Component/OnbordingAppbar.dart';
import 'package:baseliae_flutter/Component/PasswordTextfield.dart';
import 'package:baseliae_flutter/Controller/AuthController/ChargeLeaderLoginController.dart';
import 'package:baseliae_flutter/Helper/SnackbarHelper.dart';
import 'package:baseliae_flutter/Screens/Onbording/CreatChargePage.dart';

import 'package:baseliae_flutter/Style/AppStyle.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../Controller/AuthController/GooglesignInController.dart';

class Chargeleaderlogin extends StatefulWidget {
  const Chargeleaderlogin({super.key});

  @override
  State<Chargeleaderlogin> createState() => _ChargeleaderloginState();
}

class _ChargeleaderloginState extends State<Chargeleaderlogin> {
  TextEditingController? emailcontroller = TextEditingController();
  TextEditingController? passwordcontroller = TextEditingController();
  final Chargeleaderlogincontroller chargeleaderlogincontroller =
      Get.put(Chargeleaderlogincontroller());

  GoogleSigninController googleSigninController =
      Get.put(GoogleSigninController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whit,
      appBar: OnbordingAppbar(context, "Church Leader Login"),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 40,
              ),
              Center(
                  child: Text(
                "Welcome Back",
                style: robotostyle(purpal, 34, FontWeight.w500),
              )),
              SizedBox(
                height: 10,
              ),
              Center(
                  child: Text(
                "Login to your account",
                style: robotostyle(semigray, 16, FontWeight.w400),
              )),
              SizedBox(
                height: 30,
              ),
              TextFormField(
                controller: emailcontroller,
                decoration: AppInputDecoration(
                  "Email or Phone",
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Obx(
                () => Passwordtextfield(
                  controller: passwordcontroller,
                  obscureText: chargeleaderlogincontroller.isvisibel.value,
                  labelText: "Password",
                  suffixIcon: GestureDetector(
                    onTap: () {
                      chargeleaderlogincontroller.isvisibel.toggle();
                    },
                    child: chargeleaderlogincontroller.isvisibel.value
                        ? Icon(
                            Icons.visibility_off,
                            color: sufficsicon,
                          )
                        : Icon(
                            Icons.visibility,
                            color: sufficsicon,
                          ),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  GestureDetector(
                      onTap: () {},
                      child: Text(
                        "Forgot Password?",
                        style: robotostyle(purpal, 14, FontWeight.w500),
                      )),
                ]),
              ),
              SizedBox(
                height: 40,
              ),
              ElevatedButton(
                  style: AppButtonStyle(purpal),
                  onPressed: () async {
                    String? email = emailcontroller!.text.toString().trim();
                    String? password =
                        passwordcontroller!.text.toString().trim();

                    if (email.isEmpty || password.isEmpty) {
                      SnackbarHelper.showErrorSnackbar(
                          'Please enter email and password');
                    } else {
                      UserCredential? userCredential =
                          await chargeleaderlogincontroller.EmailLogin(
                              email, password);

                      if (userCredential != null) {
                        final FirebaseFirestore firestore =
                            FirebaseFirestore.instance;
                        final userDocSnapshot = await firestore
                            .collection('Users')
                            .doc(userCredential.user!.uid)
                            .get();

                        if (userDocSnapshot.exists) {
                          final userData = userDocSnapshot.data();

                          if (userData?['accountType'] == 'Church Leader') {
                            Get.to(() => Creatchargepage(), arguments: {
                              "fullname": userData?['fullName'],
                            });
                          } else {
                            SnackbarHelper.showErrorSnackbar(
                                "Only Church Leaders can create church pages.");
                          }
                        } else {
                          SnackbarHelper.showErrorSnackbar(
                              "User data not found.");
                        }
                      }
                    }
                  },
                  child: SuccessButtonChild2("Login")),
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: Color(0XFFE4E6EC),
                      thickness: 1,
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    "or",
                    style: headpoppins(Color(0XFF969AB8), FontWeight.w500, 14),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Divider(
                      color: Color(0XFFE4E6EC),
                      thickness: 1,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      googleSigninController.SignInWithGoogle();
                    },
                    child: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                          color: semiwhit,
                          borderRadius: BorderRadius.circular(8)),
                      child: Image.asset("assets/images/Group 427320702.png"),
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                        color: semiwhit,
                        borderRadius: BorderRadius.circular(8)),
                    child: Image.asset("assets/images/XMLID_17_.png"),
                  ),
                ],
              ),
              SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don’t have an account? ",
                    style: robotostyle(semigray, 14, FontWeight.w400),
                  ),
                  GestureDetector(
                      onTap: () {
                        Get.toNamed('creataccount');
                      },
                      child: Text(
                        "Sign Up!",
                        style: robotostyle(purpal, 14, FontWeight.w500),
                      )),
                ],
              ),
              SizedBox(
                height: 40,
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
      ),
    );
  }
}
