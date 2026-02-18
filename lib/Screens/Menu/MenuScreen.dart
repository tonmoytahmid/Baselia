import 'package:baseliae_flutter/Fatching/FatchUserInfo.dart';


import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../Fatching/FatchingMenuItems.dart';
import '../../Style/AppStyle.dart';

class Menuscreen extends StatefulWidget {
  const Menuscreen({super.key});

  @override
  State<Menuscreen> createState() => _MenuscreenState();
}

class _MenuscreenState extends State<Menuscreen> {
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
          //       //   Get.to(()=> Navigationscreen(),duration: Duration(milliseconds: 2000));
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
              Fatchuserinfo(),
              Fatchingmenuitems(),
            ],
          ),
        ));
  }
}
