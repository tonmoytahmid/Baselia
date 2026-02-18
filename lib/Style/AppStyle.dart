import 'package:flutter/material.dart';

import 'package:pin_code_fields/pin_code_fields.dart';

// App Colors

const Color whit = Color(0XFFFFFFFF);
const Color semiwhit = Color(0XFFF6F6F6);
const Color deepgray = Color(0XFF646982);
const Color semigray = Color(0XFF999999);
const Color purpal = Color(0XFF6D2B7D);
const Color semiblack = Color(0XFF202020);
const Color pinkish = Color.fromARGB(255, 239, 221, 239);
const Color border = Color(0XFFDCDCDC);
const Color black = Color(0XFF020202);
const Color blakish = Color(0XFF424242);
const Color textinputcolor = Color(0XFF999999);
const Color sufficsicon = Color(0XFFA9A9A9);
const Color lightpinkish = Color(0XFFD0BDD4);
const Color lightash = Color(0XFFF2F3F5);


// App TextStyles
TextStyle montserratstyle(Color,double fontsize,FontWeight? fontWeight)  {
  return TextStyle(
      color: Color, fontSize: fontsize, fontWeight: fontWeight,fontFamily: 'montserrat');
}

TextStyle robotostyle(Color,double fontsize,FontWeight? fontWeight)  {
  return TextStyle(
      color: Color, fontSize: fontsize, fontWeight: fontWeight,fontFamily: 'roboto');
}

TextStyle ButtonTextStyle(Color,double fontsize,FontWeight? fontWeight) {
  return TextStyle(
      color: Color, fontSize: fontsize, fontWeight: fontWeight,fontFamily: 'poppins');
}

TextStyle headpoppins(Color, fontweight, double fontsize) {
  return TextStyle(
      color: Color, fontSize: fontsize, fontWeight:fontweight,fontFamily: 'poppins');
}

// Elevated Button styles
ButtonStyle AppButtonStyle(Color) {
  return ElevatedButton.styleFrom(
      elevation: 1,
      padding: EdgeInsets.zero,
      backgroundColor: Color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)));
}


Ink SuccessButtonChild(String ButtonText) {
  return Ink(
    decoration: BoxDecoration(
        color: whit, borderRadius: BorderRadius.circular(8),
        
        border: Border.all(color: purpal)),
    child: Container(
      height: 45,
      alignment: Alignment.center,
      child: Text(
        ButtonText,
        style: ButtonTextStyle(purpal, 17, FontWeight.w600),
      ),
    ),
  );
}

Ink SuccessButtonChild2(String ButtonText) {
  return Ink(
    decoration: BoxDecoration(
        color: purpal, borderRadius: BorderRadius.circular(8)),
    child: Container(
      height: 45,
      alignment: Alignment.center,
      child: Text(
        ButtonText,
        style: ButtonTextStyle(whit, 17, FontWeight.w600),
      ),
    ),
  );
}

// TextField Decoration
InputDecoration AppInputDecoration(label) {
  return InputDecoration(
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
      labelText: label,
      labelStyle: robotostyle(textinputcolor, 16, FontWeight.w400));
}


// PinCodeTheme
PinTheme AppOTPStyle(){
  return  PinTheme(
    inactiveColor: pinkish,
    inactiveFillColor: pinkish,
    selectedColor: pinkish,
    activeColor: whit,
    selectedFillColor: pinkish,
    shape: PinCodeFieldShape.box,
    borderRadius: BorderRadius.circular(5),
    fieldHeight: 50,
    borderWidth: 0.5,
    fieldWidth: 58,
    activeFillColor: Colors.white,
  );
}
