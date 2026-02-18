import 'package:baseliae_flutter/Models/UserModel.dart';
import 'package:baseliae_flutter/Screens/Onbording/phoneChargepinVerification.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

import '../../Helper/SnackbarHelper.dart';

class Chargeleaderphonecontroller extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // ignore: unused_field
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // final String _verificationId = "";

  Future<void> sendOTP(String phoneNumber, String fullname, String accountType,
      String password, String pagename,String chrachlocation, String? existingChurchPageId,) async {
    try {
      EasyLoading.show(status: "Please wait");
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: '+880$phoneNumber',
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          print("Verification failed: ${e.message}");
          SnackbarHelper.showErrorSnackbar("Failed to send OTP: ${e.message}");
        },
        codeSent: (verificationId, forceResendingToken) {
          Get.to(()=>Phonechargepinverification(), arguments: {
            "verificationId": verificationId,
            "phone": phoneNumber,
            "fullname": fullname,
            "accountType": accountType,
            "password": password,
            "pagename": pagename,
            "chrachlocation": chrachlocation,
            "existingChurchPageId": existingChurchPageId
          });
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          print("OTP auto-retrieval timed out");
        },
      );
      EasyLoading.dismiss();
    } on FirebaseException catch (e) {
      EasyLoading.dismiss();
      print("Error=>$e");
    }
  }

  Future<void> verifyOTP(String otpCode, String verificationId, String phone,
      String password, String fullname, String accountType,
      String pagename,String chrachlocation, String? existingChurchPageId,) async {
    try {
      EasyLoading.show(status: "Please wait");
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otpCode,
      );

      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      if (userCredential.user != null) {
        await _registerUser(phone, password, fullname, accountType,pagename,chrachlocation, existingChurchPageId);
      }
        EasyLoading.dismiss();
    } catch (e) {
        EasyLoading.dismiss();
      print("Error verifying OTP: $e");
      SnackbarHelper.showErrorSnackbar("Invalid OTP");
    }
  }

  Future<void> _registerUser(String phone, String password, String fullname,
      String accountType,String pagename,String chrachlocation, String? existingChurchPageId,) async {
    try {
      String formattedEmail = "$phone@yourapp.com";

       String? churchPageId = existingChurchPageId;

       

       if ( churchPageId == null) {
      // Create new church page first
      DocumentReference churchPageRef = FirebaseFirestore.instance.collection('ChurchPages').doc();

      await churchPageRef.set({
        'churchPageId': churchPageRef.id,
        'Ownersname': fullname,
        'createdBy': formattedEmail,
        'churchName': pagename,
        'churchLocation': chrachlocation,
        'createdAt': DateTime.now(),
        'profileImage': 'https://cdn-icons-png.flaticon.com/512/847/847969.png',
        'coverImage': 'https://cdn-icons-png.flaticon.com/512/847/847969.png',
        // Add more fields as needed
      });

      churchPageId = churchPageRef.id; // save ID for later
    }

      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: formattedEmail,
        password: password,
      );



      if (userCredential.user != null) {
        Usermodel usermodel = Usermodel(
          uid: userCredential.user!.uid,
          email: formattedEmail,
          fullName: fullname,
          accountType: accountType,
          phone: phone,
          deviceToken: " ",
          profileImage: "https://cdn-icons-png.flaticon.com/512/847/847969.png",
          coverImage:  "https://cdn-icons-png.flaticon.com/512/847/847969.png",
          createdAt: DateTime.now(),
          // ignore: unnecessary_null_comparison
          groups: churchPageId != null ? [churchPageId] : [],
          bio: "",
          password: password,
          location: "",
          about: "",
          gender: " ",
          dob: " ",
        );

        await FirebaseFirestore.instance
            .collection('Users')
            .doc(userCredential.user!.uid)
            .set(usermodel.toMap());

        Get.toNamed('confirmlogin');
      }
    } catch (e) {
      print("Error registering user: $e");
      SnackbarHelper.showErrorSnackbar("User registration failed");
    }
  }
}
