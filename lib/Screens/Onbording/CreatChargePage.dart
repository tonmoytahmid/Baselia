import 'package:baseliae_flutter/Component/OnbordingAppbar.dart';

import 'package:baseliae_flutter/Controller/AuthController/ChargeLeaderController.dart';

import 'package:baseliae_flutter/Style/AppStyle.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

import '../../Helper/SnackbarHelper.dart';

class Creatchargepage extends StatefulWidget {
  const Creatchargepage({super.key});

  @override
  State<Creatchargepage> createState() => _CreatchargepageState();
}

class _CreatchargepageState extends State<Creatchargepage> {
  TextEditingController? pagenamecontroller = TextEditingController();
  TextEditingController? locationcontroller = TextEditingController();
  // final String accountType = Get.arguments["accountType"];

  final ChargeLeaderController emailsignupcontroller =
      Get.put(ChargeLeaderController());

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
                    String pagename = pagenamecontroller!.text.trim();
                    String chrachlocation = locationcontroller!.text.trim();

                    if (pagename.isEmpty || chrachlocation.isEmpty) {
                      SnackbarHelper.showErrorSnackbar(
                          "Please fill all the fields");
                      return;
                    }

                    try {
                      EasyLoading.show(status: "Creating page...");

                      final FirebaseFirestore firestore =
                          FirebaseFirestore.instance;
                      final FirebaseAuth auth = FirebaseAuth.instance;
                      final currentUser = auth.currentUser;

                      if (currentUser == null) {
                        EasyLoading.dismiss();
                        SnackbarHelper.showErrorSnackbar("User not logged in.");
                        return;
                      }

                      final userDocRef =
                          firestore.collection('Users').doc(currentUser.uid);

                      // ✅ Step 1: Create Church Page
                      // ✅ Step 1: Create Church Page
                      final churchPageRef =
                          firestore.collection('ChurchPages').doc();

                      await churchPageRef.set({
                        'churchPageId': churchPageRef.id,
                        'Ownersname': Get.arguments["fullname"],
                        'createdBy': currentUser.email ?? "",
                        'churchName': pagename,
                        'churchLocation': chrachlocation,
                        'createdAt': DateTime.now(),

                        // ✅ Default images
                        'profileImage':
                            'https://cdn-icons-png.flaticon.com/512/847/847969.png',
                        'coverImage':
                            'https://cdn-icons-png.flaticon.com/512/847/847969.png',

                        // ✅ Added fields
                        'about': '',
                        'dob': '',
                        'gender': '',

                        'followersCount': 0,
                        'followingCount': 0,
                        'postCount': 0,
                        'commentcount': 0,

                        'followers': [],
                        'following': [],
                        'pendingRequests': [],
                      });

                      // ✅ Step 2: Add page ID to user's 'groups' field
                      await userDocRef.update({
                        'groups': FieldValue.arrayUnion([churchPageRef.id])
                      });

                      EasyLoading.dismiss();
                      SnackbarHelper.showSuccessSnackbar(
                          "Church page created successfully!");

                      // Optionally navigate somewhere
                      Get.offAllNamed('/dashboard');
                    } catch (e) {
                      EasyLoading.dismiss();
                      SnackbarHelper.showErrorSnackbar(
                          "Error creating page. Please try again.");
                      print("Church page creation error: $e");
                    }
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
