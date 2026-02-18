import 'package:baseliae_flutter/Component/OnbordingAppbar.dart';
import 'package:baseliae_flutter/Style/AppStyle.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../Helper/SnackbarHelper.dart';

class Pinverificationscreen extends StatefulWidget {
  const Pinverificationscreen({super.key});

  @override
  State<Pinverificationscreen> createState() => _PinverificationscreenState();
}

class _PinverificationscreenState extends State<Pinverificationscreen> {
  final TextEditingController otpController = TextEditingController();
  String verificationId = Get.arguments['verificationId'];
  String phoneNumber = Get.arguments['phoneNumber'];
  String email = Get.arguments['email'];
  String fullname = Get.arguments['fullname'];
  String accountType = Get.arguments['accountType'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whit,
      appBar: OnbordingAppbar(context, "Verified"),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 30),
            Center(
              child: Image.asset(
                "assets/images/Group 1000001840.png",
                width: 106,
                height: 95,
              ),
            ),
            SizedBox(height: 30),
            Center(
              child: Text(
                "Enter Verification Code",
                style: robotostyle(purpal, 24, FontWeight.w500),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: Text(
                "We sent a code to your phone $phoneNumber. Please check your messages.",
                style: robotostyle(semigray, 14, FontWeight.w400),
              ),
            ),
            SizedBox(height: 40),
            PinCodeTextField(
              appContext: context,
              controller: otpController,
              length: 6,
              pinTheme: AppOTPStyle(),
              onCompleted: (value) {},
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: AppButtonStyle(purpal),
              onPressed: () async {
                String otp = otpController.text.trim();
                if (otp.length == 6) {
                  await _verifyOTP(otp);
                } else {
                  SnackbarHelper.showErrorSnackbar("Please enter a valid OTP");
                }
              },
              child: SuccessButtonChild2("Verify"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _verifyOTP(String otp) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );

      // Sign in the user with the credential
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      // Create user account in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'fullname': fullname,
        'email': email,
        'phoneNumber': phoneNumber,
        'accountType': accountType,
        'createdAt': DateTime.now(),
      });

      // Navigate to the dashboard or confirmation screen
      Get.toNamed('confirmlogin');
    } catch (e) {
      print("Error verifying OTP: $e");
      SnackbarHelper.showErrorSnackbar("Invalid OTP");
    }
  }
}