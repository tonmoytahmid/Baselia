import 'package:baseliae_flutter/Helper/SnackbarHelper.dart';
import 'package:flutter/material.dart';
import 'package:baseliae_flutter/Component/OnbordingAppbar.dart';
import 'package:baseliae_flutter/Style/AppStyle.dart';
import 'package:get/get.dart';

class Creataccountscreen extends StatefulWidget {
  const Creataccountscreen({super.key});

  @override
  State<Creataccountscreen> createState() => _LoginscreenState();
}

class _LoginscreenState extends State<Creataccountscreen> {
  List<String> Value = [
    'Basic User',
    'Celebrities / VIPs',
    'Church Leader',
    'Church Page'
  ];

  String _selectedValue = ''; // Variable to store selected item

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whit,
      appBar: OnbordingAppbar(context, "Sign in"),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 40),
            Center(
                child: Text(
              "Create an account as",
              style: robotostyle(purpal, 24, FontWeight.w500),
            )),
            SizedBox(height: 10),
            Center(
                child: Text(
              textAlign: TextAlign.center,
              "We are lorem ipsum team dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
              style: robotostyle(semigray, 14, FontWeight.w400).copyWith(),
            )),
            SizedBox(height: 40),
            for (var item in Value) ...[
              GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedValue = item;
                  });
                },
                child: Container(
                  width: 150,
                  height: 40,
                  decoration: BoxDecoration(
                    color:
                        _selectedValue == item ? Colors.purpleAccent : pinkish,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Color(0XFFDCDCDC)),
                  ),
                  child: Center(
                    child: Text(
                      item,
                      style: robotostyle(black, 14, FontWeight.w400),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 40),
            ],
            ElevatedButton(
              style: AppButtonStyle(purpal),
              onPressed: () {
                print("Selected: $_selectedValue");
                if (_selectedValue.isEmpty) {
                  SnackbarHelper.showErrorSnackbar("Please select an option");
                } else {
                  Get.toNamed('choseauth',
                      arguments: {'accountType': _selectedValue});
                }
              },
              child: SuccessButtonChild2("Next"),
            ),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Already have an account? ",
                  style: robotostyle(semigray, 14, FontWeight.w400),
                ),
                GestureDetector(
                  onTap: () {
                    Get.toNamed(
                      'login',
                    );
                  },
                  child: Text(
                    "Sign In!",
                    style: robotostyle(purpal, 14, FontWeight.w400),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
