
import 'package:baseliae_flutter/Style/AppStyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';



class Welcomescreen extends StatefulWidget {
  const Welcomescreen({super.key});

  @override
  State<Welcomescreen> createState() => _WelcomescreenState();
}

class _WelcomescreenState extends State<Welcomescreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whit,
      body: Stack(
        clipBehavior: Clip.none,
        children: [
      
Stack(
  children: [
    Image.asset("assets/images/T1.png",height: 440,width:MediaQuery.of(context).size.width ,fit: BoxFit.fitHeight,),
    Container(
      height: 440,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Color(0XFFFFFFFF),
            Colors.white.withOpacity(0)
          ,
          ],
        ),
      ),
    )
  ],
),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Spacer(),
               Center(
                    child:  Text("Welcome",style: robotostyle(purpal, 34, FontWeight.w500),)),
                SizedBox(
                  height: 10,
                ),
                Center(
                    child: Text(
                      textAlign: TextAlign.center,
                  "It is a long established fact that a reader will be distracted by the when looking at its layout. ",
                  style: robotostyle(semigray, 16, FontWeight.w400),
                )),
                 SizedBox(height: 120,),
                  ElevatedButton(
                    style: AppButtonStyle(purpal),
                    onPressed: (){
                      Get.toNamed('login');
                    }, child: SuccessButtonChild2("Log In")),
                     SizedBox(
                  height: 10,
                ),
                     ElevatedButton(
                    style: AppButtonStyle(whit),
                    onPressed: (){
                          Get.toNamed('creataccount');
                    }, child: SuccessButtonChild("Sign Up")),
                     SizedBox(height: 20,),
            ],
          ),
        )
        ],
      ),
    );
  }
}

