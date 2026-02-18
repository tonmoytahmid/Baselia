import 'package:baseliae_flutter/Controller/MenueController/MenueController.dart';
import 'package:baseliae_flutter/Controller/MenueController/UsersessionController.dart';
import 'package:baseliae_flutter/Screens/Menu/MenuScreen.dart';
import 'package:baseliae_flutter/Screens/Pages/SearchScreen.dart';
import 'package:baseliae_flutter/Screens/Switchprofle/SwitchprofileScreen.dart';
import 'package:baseliae_flutter/Style/AppStyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart'; // import your controller

AppBar HomeScreenAppbar(context) {
  final menuController =
      Get.find<MenuControllers>(); // Get the controller instance
  final userSession = Get.find<UserSessionController>();

  return AppBar(
    backgroundColor: Colors.white,
    elevation: 0,
    leading: Padding(
      padding: EdgeInsets.only(left: 21),
      child: Material(
          elevation: 1.5,
          shape: CircleBorder(),
          child: Image.asset(
            'assets/images/LOGO_NW 1.png',
            width: 90,
            height: 90,
          )),
    ),
    actions: [
      IconButton(
          onPressed: () {
            Get.to(() => Searchscreen());
          },
          icon: Icon(
            Icons.search,
            color: purpal,
            size: 30,
          )),
      Padding(
        padding: EdgeInsets.only(right: 20),
        child: GestureDetector(
          onTap: () {
            // ✅ Use the actual flag from the correct session controller
            if (userSession.isPageProfile.value) {
              Get.to(() => SwitchProfileScreen());
            } else {
              Get.to(() => Menuscreen());
            }
          },
          // onTap: () {
          //   if (menuController.isSwitchedProfile .value) {
          //     Get.to(() => SwitchProfileScreen());
          //   } else {
          //     Get.to(() => Menuscreen());
          //   }
          // },
          child: Image.asset(
            'assets/images/Top Navigation.png',
            width: 30,
            height: 30,
          ),
        ),
      )
    ],
  );
}
