import 'package:baseliae_flutter/Models/UserModel.dart';
import 'package:baseliae_flutter/Style/AppStyle.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSigninController extends GetxController {
  GoogleSignIn? googleSignin = GoogleSignIn();
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;

  Future<void> SignInWithGoogle() async {
    try {
      EasyLoading.show(
        status: "Loading...",
        indicator: CircularProgressIndicator(
          color: purpal,
        ),
      );
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignin!.signIn();
      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );
        final UserCredential userCredential =
            await auth.signInWithCredential(credential);
        final User? user = userCredential.user;

        if (user != null) {
          Usermodel? usermodel = Usermodel(
            uid: user.uid,
            email: user.email.toString(),
            fullName: user.displayName.toString(),
            accountType: "Basic User",
            phone: user.phoneNumber.toString(),
            deviceToken: " ",
            profileImage: "https://cdn-icons-png.flaticon.com/512/847/847969.png",
            coverImage: "https://cdn-icons-png.flaticon.com/512/847/847969.png",
            createdAt: DateTime.now(),
            groups: [],
            bio: "",
            password: "",
            location: "",
            about: "",
          followers: [],
          following: [],
          pendingRequests: [],
          gender: "",
          dob: ""
          );
          await firestore
              .collection('Users')
              .doc(user.uid)
              .set(usermodel.toMap());
          EasyLoading.dismiss();
          Get.offAllNamed('dashboard');
        }
      }
    } catch (e) {
      EasyLoading.dismiss();
      print(e);
    }
  }
}
