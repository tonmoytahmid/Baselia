import 'package:baseliae_flutter/Component/OnbordingAppbar.dart'
    show OnbordingAppbar;
import 'package:baseliae_flutter/Controller/AuthController/ChargeLeaderPhoneController.dart';


import 'package:baseliae_flutter/Style/AppStyle.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class Phonechargepinverification extends StatefulWidget {
  const Phonechargepinverification({super.key});

  @override
  State<Phonechargepinverification> createState() => _PhonechargepinverificationState();
}

class _PhonechargepinverificationState extends State<Phonechargepinverification> {
  // final TextEditingController otpController = TextEditingController();
  String verificationId = Get.arguments['verificationId'];
  String phone = Get.arguments['phone'];
  String fullname = Get.arguments['fullname'];
  String accountType = Get.arguments['accountType'];
  String password = Get.arguments['password'];
  String pagename = Get.arguments['pagename'];
  String chrachlocation = Get.arguments['chrachlocation'];
  String? otpCode;

  final Chargeleaderphonecontroller chargeleaderphonecontroller =
      Get.put(Chargeleaderphonecontroller());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whit,
      appBar: OnbordingAppbar(context, "Verify Your Phone"),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 30),
              Center(
                  child: Image.asset("assets/images/Group 1000001840.png",
                      width: 106, height: 95)),
              SizedBox(height: 30),
              Text("Enter Verification Code",
                  style: robotostyle(purpal, 24, FontWeight.w500)),
              SizedBox(height: 20),
              Text(
                  "We have sent a verification code to +880$phone. Please enter it below.",
                  style: robotostyle(semigray, 14, FontWeight.w400)),
              SizedBox(height: 40),
              PinCodeTextField(
                appContext: context,
                keyboardType: TextInputType.number,
                length: 6,
                pinTheme: AppOTPStyle(),
                animationType: AnimationType.fade,
                animationDuration: Duration(milliseconds: 300),
                enableActiveFill: true,
                onCompleted: (value) {
                  setState(() {
                    otpCode = value;
                  });
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: AppButtonStyle(purpal),
                onPressed: () async {
                  if (otpCode != null) {
                    await chargeleaderphonecontroller.verifyOTP(otpCode.toString(), verificationId,
                        phone, password, fullname, accountType,pagename,chrachlocation, null);
                  } else {}
                },
                child: SuccessButtonChild2("Verify"),
              ),
              SizedBox(height: 60),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Didn’t receive OTP? ",
                      style: robotostyle(semigray, 16, FontWeight.w400)),
                  GestureDetector(
                    onTap: () {},
                    child: Text("Resend!",
                        style: robotostyle(purpal, 16, FontWeight.w400)),
                  ),
                ],
              ),
              SizedBox(height: 90),
              Column(
                children: [
                  Text("Protected by reCAPTCHA and subject to the",
                      style: robotostyle(semigray, 12, FontWeight.w400)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Rhombus",
                          style: robotostyle(semigray, 12, FontWeight.w400)),
                      Text("Privacy Policy",
                          style: robotostyle(purpal, 12, FontWeight.w400)),
                      Text(" and ",
                          style: robotostyle(semigray, 12, FontWeight.w400)),
                      Text("Terms of Service.",
                          style: robotostyle(purpal, 12, FontWeight.w400)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
