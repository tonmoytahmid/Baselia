
// ignore_for_file: unused_local_variable

import 'package:baseliae_flutter/Component/OnbordingAppbar.dart';

import 'package:baseliae_flutter/Controller/AuthController/ChargeLeaderController.dart';
import 'package:baseliae_flutter/Controller/AuthController/ChargeLeaderPhoneController.dart';


import 'package:baseliae_flutter/Style/AppStyle.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';


import '../../Helper/SnackbarHelper.dart';

class Phonechargepagecreat extends StatefulWidget {
  const Phonechargepagecreat({super.key});

  @override
  State<Phonechargepagecreat> createState() => _PhonechargepagecreatState();
}

class _PhonechargepagecreatState extends State<Phonechargepagecreat> {


   TextEditingController? pagenamecontroller = TextEditingController();
  TextEditingController? locationcontroller = TextEditingController();
  final String accountType = Get.arguments["accountType"];

  final ChargeLeaderController emailsignupcontroller =
      Get.put(ChargeLeaderController());

      
  final Chargeleaderphonecontroller chargeleaderphonecontroller =
      Get.put(Chargeleaderphonecontroller());



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whit,
      appBar: OnbordingAppbar(context, "Creat Page"),
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
                "Church Page",
                style: robotostyle(purpal, 32, FontWeight.w500).copyWith(),
              )),
              SizedBox(
                height: 10,
              ),
              Center(
                  child: Text(
                "Create your new Church page",
                style: robotostyle(semigray, 16, FontWeight.w400),
              )),
              SizedBox(
                height: 30,
              ),
         
              TextFormField(
                controller: pagenamecontroller,
                decoration: AppInputDecoration(
                  "Page Name",
                ),
              ),
              SizedBox(
                height: 15,
              ),
              
                   TextFormField(
                      controller: locationcontroller,
                      decoration: AppInputDecoration(
                        "church Location",
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

                    String phoneNumber = Get.arguments["phoneNumber"];
                    String fullname = Get.arguments["fullname"];
                    String password = Get.arguments["password"];
                    String accountType = Get.arguments["accountType"];
                    String pagename = pagenamecontroller!.text.trim();
                    String chrachlocation = locationcontroller!.text.trim();
                  if (phoneNumber.isEmpty || phoneNumber.length < 10) {
                      SnackbarHelper.showErrorSnackbar(
                          'Enter a valid phone number');
                      return;
                    }

                    await chargeleaderphonecontroller.sendOTP(
                        phoneNumber, fullname, accountType, password, pagename, chrachlocation, null);
                   
                  },
                  child: SuccessButtonChild2("Creat Page")),
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
