import 'package:baseliae_flutter/Style/AppStyle.dart';
import 'package:flutter/material.dart';

class Cardwidgets extends StatelessWidget {
  String? text;
  String? image;

   Cardwidgets({super.key,required this.text,required this.image});

  @override
  Widget build(BuildContext context) {
    return Padding(

      padding: const EdgeInsets.only(top: 20),
      child: Card(
        elevation: 0,
        color: semiwhit,
        child: ListTile(
          leading: Image.asset(image!),
          title: Text(
            text!,
            style: robotostyle(black, 16, FontWeight.w600),
          ),
          trailing:Image.asset("assets/images/link.png"),
        ),
      ),
    );
  }
}
