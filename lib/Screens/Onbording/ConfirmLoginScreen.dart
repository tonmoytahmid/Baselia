import 'package:baseliae_flutter/Component/OnbordingAppbar.dart';

import 'package:baseliae_flutter/Style/AppStyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class Confirmloginscreen extends StatefulWidget {
  const Confirmloginscreen({super.key});

  @override
  State<Confirmloginscreen> createState() => _ConfirmloginscreenState();
}

class _ConfirmloginscreenState extends State<Confirmloginscreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whit,
      appBar: OnbordingAppbar(context, "Verified"),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20,),
             Center(child: Image.asset("assets/images/Group 1000001840.png")),
        SizedBox(height: 20,),
         Center(child: Text("You are all Set",style:TextStyle(color: purpal,fontSize: 24,fontWeight: FontWeight.w500,fontFamily: 'roboto') ,)),
         SizedBox(height: 20,),
          Center(child: Text("Your account has been created",style:TextStyle(color: semigray,fontSize: 14,fontWeight: FontWeight.w400,fontFamily: 'roboto') ,)),
         Center(child: Text("Successfully",style:TextStyle(color: semigray,fontSize: 14,fontWeight: FontWeight.w400,fontFamily: 'roboto') ,)),
        
        
          SizedBox(height: 20,),
          ElevatedButton(
            style: AppButtonStyle(purpal),
            onPressed: (){
               Get.offAllNamed('dashboard');
            }, child: SuccessButtonChild2("Go to Home"))
          ],
        ),
      ),
    );
  }
}