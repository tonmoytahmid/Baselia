// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';


import '../Style/AppStyle.dart';

class Passwordtextfield extends StatefulWidget {
 TextEditingController? controller;
  String? labelText;
  Widget? suffixIcon;
  bool obscureText;
   Passwordtextfield({super.key,required this.controller,required this.labelText,required this.suffixIcon,required this.obscureText});

  @override
  State<Passwordtextfield> createState() => _PasswordtextfieldState();
}

class _PasswordtextfieldState extends State<Passwordtextfield> {


  @override
  Widget build(BuildContext context) {
     return TextFormField(
      controller:widget.controller ,
      obscureText:widget.obscureText,
      decoration: InputDecoration(
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: semiwhit, width: 1),
          ),
          fillColor: semiwhit,
          filled: true,
          contentPadding: EdgeInsets.fromLTRB(20, 10, 10, 20),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: semiwhit, width: 0.0),
          ),
          border: OutlineInputBorder(),
          labelText: widget.labelText,
          labelStyle: robotostyle(textinputcolor, 16, FontWeight.w400),
          suffixIcon: widget.suffixIcon),
    );
  }
}



