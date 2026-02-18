import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Style/AppStyle.dart';

AppBar OnbordingAppbar(context, text) {
  return AppBar(
    backgroundColor: Colors.white,
    elevation: 0,
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
    title: Text(text, style: TextStyle(color: purpal,fontSize:  24,fontWeight:  FontWeight.bold),), 
    centerTitle: true,
  );
}
