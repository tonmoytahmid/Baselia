import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:get/get.dart';

class Authcontroller extends GetxController {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // late EmailAuth emailAuth;
  // var isResending = false.obs;

  // Authcontroller() {
  //   emailAuth = EmailAuth(sessionName: "FlutterOTP");
  // }


  // for user signup
  Future<UserCredential?> SignupUser(
      String email, String password, String cpassword,String fullname,String accountType) async {
    try {
  
        UserCredential userCredential = await auth
            .createUserWithEmailAndPassword(email: email, password: password);
        if (userCredential.user != null) {
          await userCredential.user!.sendEmailVerification();
         
          await firestore.collection("users").doc(auth.currentUser!.uid).set({
        "uid": auth.currentUser!.uid,
        "email": email,
        "fullName": fullname,
        "accountType": accountType,
        "phone": " ",
        "deviceToken": "",
        "profileImage": "assets/images/defaultprofilepicture.png",
        "coverImage": "assets/images/coverphoto.png",
        "createdAt": FieldValue.serverTimestamp(),
      });
       Get.snackbar("Success", "verification lonks sended to your email");

       return userCredential;
          
        }
 
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    } catch (e) {
      print(e);
    }
    return null;
  }

//for sending otp
  // Future<void> sendEmailOTP(String email) async {
  //   bool result = await emailAuth.sendOtp(recipientMail: email);
  //   if (result) {
  //     Get.snackbar("Success", "OTP Sent Successfully!");
  //   } else {
  //     Get.snackbar("Error", "Failed to send OTP");
  //   }
  // }

//for resending otp
  // Future<void> resendOTP(String email) async {
  //   isResending.value = true;
  //   bool result = await emailAuth.sendOtp(recipientMail: email);
  //   isResending.value = false;

  //   if (result) {
  //     Get.snackbar("Success", "OTP Resent Successfully!");
  //   } else {
  //     Get.snackbar("Error", "Failed to Resend OTP");
  //   }
  // }

  //for verifying otp

  // Future<void> verifyEmailOTP(
  //   String email,
  //   String otp,
  //   String fullname,
  //   String accountType,
  // ) async {
  //   bool isValid = emailAuth.validateOtp(recipientMail: email, userOtp: otp);
  //   if (isValid) {
  //     await firestore.collection("users").doc(auth.currentUser!.uid).set({
  //       "uid": auth.currentUser!.uid,
  //       "email": email,
  //       "fullName": fullname,
  //       "accountType": accountType,
  //       "phone": " ",
  //       "deviceToken": "",
  //       "profileImage": "assets/images/defaultprofilepicture.png",
  //       "coverImage": "assets/images/coverphoto.png",
  //       "createdAt": FieldValue.serverTimestamp(),
  //     });
  //     Get.snackbar("Success", "Email Verified!");
  //     Get.toNamed("confirmlogin");
  //   } else {
  //     Get.snackbar("Error", "Invalid OTP");
  //   }
  // }
}
