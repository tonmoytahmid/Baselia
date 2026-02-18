import 'dart:async';

import 'package:baseliae_flutter/Style/AppStyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Loadingscreen extends StatelessWidget {
  const Loadingscreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 2), () {
     return Get.to(() => StreamController());
    });
    return Scaffold(
        backgroundColor: whit,
        body: Center(
            child: CircularProgressIndicator(
          color: purpal,
        )));
  }
}
