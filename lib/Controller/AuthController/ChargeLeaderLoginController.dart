import 'package:baseliae_flutter/Helper/SnackbarHelper.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import '../../Style/AppStyle.dart';
class Chargeleaderlogincontroller extends GetxController {
  FirebaseAuth auth = FirebaseAuth.instance;
  RxBool isvisibel = false.obs;
  // ignore: non_constant_identifier_names, body_might_complete_normally_nullable
  Future<UserCredential?> EmailLogin(String input, String password) async {
    try {
     
       EasyLoading.show(status: input,indicator: CircularProgressIndicator(color: purpal,),);

       String email;

    // Check if input is a valid email
    if (EmailValidator.validate(input)) {
      email = input; // Use email directly
    } else {
      email = "$input@yourapp.com"; // Convert phone number to email format
    }

      UserCredential userCredential = await auth.signInWithEmailAndPassword(
          email: email, password: password);
      EasyLoading.dismiss();
      return userCredential;
    } on FirebaseAuthException catch (e) {
      EasyLoading.dismiss();
      if (e.code == 'user-not-found') {
        SnackbarHelper.showErrorSnackbar('No user found for that email.');
      } else if (e.code == 'wrong-password') {
         SnackbarHelper.showErrorSnackbar('Wrong password provided for that user.');
       
      }
      return null;
    }
  }

  
}
