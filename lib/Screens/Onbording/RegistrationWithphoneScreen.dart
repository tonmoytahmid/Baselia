import 'package:baseliae_flutter/Component/OnbordingAppbar.dart';
import 'package:baseliae_flutter/Component/PasswordTextfield.dart';
import 'package:baseliae_flutter/Controller/AuthController/EmailsignUpController.dart';
import 'package:baseliae_flutter/Controller/AuthController/PhoneAuthController.dart';
import 'package:baseliae_flutter/Style/AppStyle.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Helper/SnackbarHelper.dart';

class Registrationwithphonescreen extends StatefulWidget {
  const Registrationwithphonescreen({super.key});

  @override
  State<Registrationwithphonescreen> createState() =>
      _RegistrationwithphonescreenState();
}

class _RegistrationwithphonescreenState
    extends State<Registrationwithphonescreen> {
  TextEditingController? fullnamecontroller = TextEditingController();
  TextEditingController? phonecontroller = TextEditingController();
  TextEditingController? passwordcontroller = TextEditingController();
  TextEditingController? cpasswordcontroller = TextEditingController();
  final String accountType = Get.arguments["accountType"];

  final Emailsignupcontroller emailsignupcontroller =
      Get.put(Emailsignupcontroller());

  final Phoneauthcontroller phoneauthcontroller =
      Get.put(Phoneauthcontroller());

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whit,
      appBar: OnbordingAppbar(context, "Sign in"),
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
                "Register",
                style: robotostyle(purpal, 32, FontWeight.w500).copyWith(),
              )),
              SizedBox(
                height: 10,
              ),
              Center(
                  child: Text(
                "Create your new account",
                style: robotostyle(semigray, 16, FontWeight.w400),
              )),
              SizedBox(
                height: 30,
              ),
              TextFormField(
                controller: fullnamecontroller,
                decoration: AppInputDecoration(
                  "Full Name",
                ),
              ),
              SizedBox(
                height: 15,
              ),
              TextFormField(
                controller: phonecontroller,
                decoration: AppInputDecoration(
                  "Phone",
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Obx(
                () => Passwordtextfield(
                  controller: passwordcontroller,
                  obscureText: emailsignupcontroller.isvisiblep.value,
                  labelText: "Password",
                  suffixIcon: GestureDetector(
                      onTap: () {
                        emailsignupcontroller.isvisiblep.toggle();
                      },
                      child: emailsignupcontroller.isvisiblep.value
                          ? Icon(
                              Icons.visibility_off,
                              color: sufficsicon,
                            )
                          : Icon(
                              Icons.visibility,
                              color: sufficsicon,
                            )),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Obx(
                () => Passwordtextfield(
                  controller: cpasswordcontroller,
                  obscureText: emailsignupcontroller.isvisiblec.value,
                  labelText: "Confirm Password",
                  suffixIcon: GestureDetector(
                      onTap: () {
                        emailsignupcontroller.isvisiblec.toggle();
                      },
                      child: emailsignupcontroller.isvisiblec.value
                          ? Icon(
                              Icons.visibility_off,
                              color: sufficsicon,
                            )
                          : Icon(
                              Icons.visibility,
                              color: sufficsicon,
                            )),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.check_box,
                      color: purpal,
                    )),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          "I agree to your ",
                          style: robotostyle(semigray, 12, FontWeight.w400),
                        ),
                        Text(
                          "privacy policy ",
                          style: robotostyle(purpal, 12, FontWeight.w400),
                        ),
                        Text(
                          "and",
                          style: robotostyle(semigray, 12, FontWeight.w400),
                        ),
                      ],
                    ),
                    Text(
                      textAlign: TextAlign.left,
                      "terms & Condition ",
                      style: robotostyle(purpal, 12, FontWeight.w400),
                    )
                  ],
                ),
              ]),
              SizedBox(
                height: 40,
              ),
              ElevatedButton(
                  style: AppButtonStyle(purpal).copyWith(),
                  onPressed: () async {
                    String phoneNumber = phonecontroller!.text.trim();
                    String fullname = fullnamecontroller!.text.trim();
                    String password = passwordcontroller!.text.trim();

                    if (phoneNumber.isEmpty || phoneNumber.length < 10) {
                      SnackbarHelper.showErrorSnackbar(
                          'Enter a valid phone number');
                      return;
                    }

                    await phoneauthcontroller.sendOTP(
                        phoneNumber, fullname, accountType, password);
                  },
                  child: SuccessButtonChild2("Sign Up")),
              SizedBox(
                height: 30,
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

  

