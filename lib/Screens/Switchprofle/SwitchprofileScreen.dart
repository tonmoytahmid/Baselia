import 'package:baseliae_flutter/Fatching/FatchingPageInfo.dart';
import 'package:baseliae_flutter/Fatching/FatchingSwitchMenuItems.dart';


import 'package:baseliae_flutter/Style/AppStyle.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SwitchProfileScreen extends StatefulWidget {
  const SwitchProfileScreen({super.key});

  @override
  State<SwitchProfileScreen> createState() => _SwitchProfileScreenState();
}

class _SwitchProfileScreenState extends State<SwitchProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: whit,
        appBar: AppBar(
           iconTheme: IconThemeData(color: purpal),
          backgroundColor: Colors.white,
          elevation: 0,
          // leading: Padding(
          //   padding: EdgeInsets.only(left: 21),
          //   child: Material(
          //     elevation: 1.5,
          //     shape: CircleBorder(),
          //     child: GestureDetector(
          //       // onTap: () {
          //       //   Get.to(()=>Navigationscreen());
          //       // },
          //       child: CircleAvatar(
          //           backgroundColor: Colors.white,
          //           child: Image.asset(
          //             "assets/images/Vector.png",
          //             color: purpal,
          //           )),
          //     ),
          //   ),
          // ),
          title: Text(
            "Menu",
            style: TextStyle(
                color: black, fontSize: 16, fontWeight: FontWeight.w600),
          ),
          centerTitle: true,
          actions: [
            IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.search,
                  color: purpal,
                  size: 30,
                )),
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: IconButton(
                  onPressed: () {
                    Get.toNamed('/settings');
                  },
                  icon: Icon(
                    Icons.settings,
                    color: purpal,
                    size: 30,
                  )),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Fatchuserinfo(),

              FetchChurchPages(userId: FirebaseAuth.instance.currentUser!.uid),
             
              FatchingSwitchMenuItems(),
            ],
          ),
        ));
  }
}