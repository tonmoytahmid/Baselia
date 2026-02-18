// ignore_for_file: unnecessary_null_comparison

import 'package:baseliae_flutter/Helper/SnackbarHelper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

import '../../Models/UserModel.dart';
import '../../Style/AppStyle.dart';

class ChargeLeaderController extends GetxController {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  RxBool isvisiblep = false.obs;
   RxBool isvisiblec = false.obs;

  // ignore: body_might_complete_normally_nullable
  Future<UserCredential?> EmailSignUp(String email, String password,
      String cpassword, String fullname, String accountType,
      String pagename,String chrachlocation, String? existingChurchPageId, ) async {
    try {
      EasyLoading.show(
        status: email,
        indicator: CircularProgressIndicator(
          color: purpal,
        ),
      );

      String? churchPageId = existingChurchPageId;

       if ( churchPageId == null) {
      // Create new church page first
      DocumentReference churchPageRef = firestore.collection('ChurchPages').doc();

      await churchPageRef.set({
        'churchPageId': churchPageRef.id,
        'Ownersname': fullname,
        'createdBy': email,
        'churchName': pagename,
        'churchLocation': chrachlocation,
        'createdAt': DateTime.now(),
        'profileImage': 'https://cdn-icons-png.flaticon.com/512/847/847969.png',
        'coverImage': 'https://cdn-icons-png.flaticon.com/512/847/847969.png',
        // Add more fields as needed
      });

      churchPageId = churchPageRef.id; // save ID for later
    }


      
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
          email: email, password: password);
      await userCredential.user!.sendEmailVerification();
      if (userCredential.user != null) {
        Usermodel? usermodel = Usermodel(
          uid: userCredential.user!.uid,
          email: userCredential.user!.email.toString(),
          fullName: fullname.toString(),
          accountType: accountType.toString(),
          phone: userCredential.user!.phoneNumber.toString(),
          deviceToken: " ",
          profileImage: "https://cdn-icons-png.flaticon.com/512/847/847969.png",
          coverImage: "https://cdn-icons-png.flaticon.com/512/847/847969.png",
          createdAt:DateTime.now(),
          groups: churchPageId != null ? [churchPageId] : [], 
          bio: "",
          password: password,
          location: "",
          about: "",
          followers: [],
          following: [],
          pendingRequests: [],
           gender: "",
          dob: "",
         
        );
        await firestore
            .collection('Users')
            .doc(userCredential.user!.uid)
            .set(usermodel.toMap());
      }
      EasyLoading.dismiss();
       SnackbarHelper.showSuccessSnackbar('Email Verification link Sended to your Email');
   

      return userCredential;
    } on FirebaseAuthException catch (e) {
      EasyLoading.dismiss();
      if (e.code == 'weak-password') {
        SnackbarHelper.showErrorSnackbar('The password provided is too weak.');
        
      } else if (e.code == 'email-already-in-use') {
         SnackbarHelper.showErrorSnackbar('The account already exists for that email.');
       
      }
    }
  }

  
}
