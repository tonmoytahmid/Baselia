import 'package:baseliae_flutter/Style/AppStyle.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Settingscreen extends StatefulWidget {
  const Settingscreen({super.key});

  @override
  State<Settingscreen> createState() => _SettingscreenState();
}

class _SettingscreenState extends State<Settingscreen> {
  List<Map<String, dynamic>> items = [
    {
      'icon': 'assets/images/Frame 1197134532.png',
      'title': 'Personal Information',
      'subtitle': 'Edit your personal information',
    },
    {
      'icon': 'assets/images/Frame 1197134532 (1).png',
      'title': 'Password & Security',
      'subtitle':
          'Manage your password and security settings to keep your account safe',
    },
    {
      'icon': 'assets/images/Frame 1197134532 (2).png',
      'title': 'Language',
      'subtitle':
          'Select your preferred language for a personalized experience',
    },
    {
      'icon': 'assets/images/Frame 1197134532 (3).png',
      'title': 'Donation History',
      'subtitle': 'View your past donations and track your contributions',
    },
    {
      'icon': 'assets/images/Frame 1197134532 (4).png',
      'title': 'Privacy Policy',
      'subtitle':
          'Review our policies to understand your privacy rights and choices',
    },
    {
      'icon': 'assets/images/Frame 1197134532 (5).png',
      'title': 'Delete Account',
      'subtitle': 'Leave group that no longer interest you',
    },
    {
      'icon': 'assets/images/Frame 1197134532 (6).png',
      'title': 'Blocking',
      'subtitle': 'Manage your blocked users list',
    },
    {
      'icon': 'assets/images/Frame 1197134532 (7).png',
      'title': 'Log Out',
      'subtitle': 'Sign out of your account securely',
    },
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whit,
      appBar: AppBar(
        backgroundColor: whit,
        leading: Padding(
          padding: EdgeInsets.only(left: 21),
          child: Material(
            elevation: 1.5,
            shape: CircleBorder(),
            child: GestureDetector(
              onTap: () {
                Get.back();
              },
              child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Image.asset(
                    "assets/images/Vector.png",
                    color: purpal,
                  )),
            ),
          ),
        ),
        title: Text(
          "Settings & Privacy",
          style: robotostyle(black, 16, FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.search,
                  color: purpal,
                  size: 50,
                )),
          )
        ],
      ),
      body: ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            final data = items[index];
            return Padding(
              padding: const EdgeInsets.only(top: 10),
              child: GestureDetector(
                onTap: () => handelNavigation(context, index),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Image.asset(data['icon']),
                  ),
                  title: Text(
                    data['title'],
                    style: robotostyle(black, 18, FontWeight.w600),
                  ),
                  subtitle: Text(
                    data['subtitle'],
                    style: robotostyle(semigray, 12, FontWeight.w400),
                  ),
                ),
              ),
            );
          }),
    );
  }
}

void handelNavigation(BuildContext context, int index) {
  switch (index) {
    case 0:
      Get.toNamed('/updateprofileinfo');
      break;
    case 7:

     showDialog(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: 116,
          width: 236,
          child: AlertDialog(
            
            elevation: 20,
            backgroundColor: whit,
           
            content: Wrap(
              children: [
                Text(
                  textAlign: TextAlign.center,
                  "Are you sure you want to ",style: robotostyle(black, 14, FontWeight.w400),),
                  Text(
                  textAlign: TextAlign.center,
                  " Log Out ?",style: robotostyle(Colors.red, 14, FontWeight.w400),),
              ],
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                 
                  TextButton(
                onPressed: () {
                  Navigator.pop(context); 

                   FirebaseAuth.instance.signOut();
      GoogleSignIn().signOut();
      Get.offAllNamed('/login');
                  // updateUserData(); 
                },
                child: Text("Confirm",style: robotostyle(Colors.red, 16, FontWeight.w600),),
              ),

               TextButton(
                    onPressed: () {
                      Navigator.pop(context); 
                    },
                    child: Text("Cancel",style: robotostyle(semigray, 16, FontWeight.w600),),
                  ),
                ],
              ),
              
            ],
          ),
        );
      },
    );
     
      
  }
}
