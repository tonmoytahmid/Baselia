import 'package:baseliae_flutter/Component/OnbordingAppbar.dart';
import 'package:baseliae_flutter/Component/PasswordTextfield.dart';
import 'package:baseliae_flutter/Controller/AuthController/EmailsignUpController.dart';
import 'package:baseliae_flutter/Screens/Onbording/ChargePageCreatScreen.dart';

import 'package:baseliae_flutter/Style/AppStyle.dart';


import 'package:flutter/material.dart';
import 'package:get/get.dart';


import '../../Helper/SnackbarHelper.dart';

class Chargeleaderscreen extends StatefulWidget {
  const Chargeleaderscreen({super.key});

  @override
  State<Chargeleaderscreen> createState() => _ChargeleaderscreenState();
}

class _ChargeleaderscreenState extends State<Chargeleaderscreen> {
  TextEditingController? fullnamecontroller = TextEditingController();
  TextEditingController? emailcontroller = TextEditingController();
  TextEditingController? passwordcontroller = TextEditingController();
  TextEditingController? cpasswordcontroller = TextEditingController();
  final String accountType = Get.arguments["accountType"];
   final String? churchPageId = Get.arguments["churchPageId"]?? "";


  final Emailsignupcontroller emailsignupcontroller =
      Get.put(Emailsignupcontroller());



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whit,
      appBar: OnbordingAppbar(context, "Sign UP"),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 40,
              ),
              Center(
                  child: Text(
                "Register",
                style: robotostyle(purpal, 32, FontWeight.w500).copyWith(),
              )),
              SizedBox(
                height: 10,
              ),
              Center(
                  child: Text(
                "Create your new account",
                style: robotostyle(semigray, 16, FontWeight.w400),
              )),
              SizedBox(
                height: 30,
              ),
              TextFormField(
                controller: fullnamecontroller,
                decoration: AppInputDecoration(
                  "Full Name",
                ),
              ),
              SizedBox(
                height: 15,
              ),
              
                   TextFormField(
                      controller: emailcontroller,
                      decoration: AppInputDecoration(
                        "Email",
                      ),
                     
                    ),
              SizedBox(
                height: 15,
              ),
              Obx(
                () => Passwordtextfield(
                  controller: passwordcontroller,
                  obscureText: emailsignupcontroller.isvisiblep.value,
                  labelText: "Password",
                  suffixIcon: GestureDetector(
                      onTap: () {
                        emailsignupcontroller.isvisiblep.toggle();
                      },
                      child: emailsignupcontroller.isvisiblep.value
                          ? Icon(
                              Icons.visibility_off,
                              color: sufficsicon,
                            )
                          : Icon(
                              Icons.visibility,
                              color: sufficsicon,
                            )),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Obx(
                () => Passwordtextfield(
                  controller: cpasswordcontroller,
                  obscureText: emailsignupcontroller.isvisiblec.value,
                  labelText: "Confirm Password",
                  suffixIcon: GestureDetector(
                      onTap: () {
                        emailsignupcontroller.isvisiblec.toggle();
                      },
                      child: emailsignupcontroller.isvisiblec.value
                          ? Icon(
                              Icons.visibility_off,
                              color: sufficsicon,
                            )
                          : Icon(
                              Icons.visibility,
                              color: sufficsicon,
                            )),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.check_box,
                      color: purpal,
                    )),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          "I agree to your ",
                          style: robotostyle(semigray, 12, FontWeight.w400),
                        ),
                        Text(
                          "privacy policy ",
                          style: robotostyle(purpal, 12, FontWeight.w400),
                        ),
                        Text(
                          "and",
                          style: robotostyle(semigray, 12, FontWeight.w400),
                        ),
                      ],
                    ),
                    Text(
                      textAlign: TextAlign.left,
                      "terms & Condition ",
                      style: robotostyle(purpal, 12, FontWeight.w400),
                    )
                  ],
                ),
              ]),
              SizedBox(
                height: 40,
              ),
              ElevatedButton(
                  style: AppButtonStyle(purpal).copyWith(),
                  onPressed: () async {
                   if(fullnamecontroller!.text.isEmpty|| emailcontroller!.text.isEmpty||passwordcontroller!.text.isEmpty||cpasswordcontroller!.text.isEmpty){
                     SnackbarHelper.showErrorSnackbar("Please fill all fields, Thank you", );
                     
                   }else{
                    Get.to(()=>Chargepagecreatscreen(),arguments: {
                      "accountType": accountType,
                      "fullname": fullnamecontroller!.text,
                      "email": emailcontroller!.text,
                      "password": passwordcontroller!.text,
                      "cpassword": cpasswordcontroller!.text,
                      "churchPageId": churchPageId
                    });
                   }
                  },
                  child: SuccessButtonChild2("Creat Page")),
              SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account? ",
                    style: robotostyle(semigray, 14, FontWeight.w400),
                  ),
                  GestureDetector(
                      onTap: () {
                        Get.toNamed('login');
                      },
                      child: Text(
                        "Login!",
                        style: robotostyle(purpal, 14, FontWeight.w400),
                      )),
                ],
              ),
              SizedBox(
                height: 40,
              ),

               
              Column(
                children: [
                  Text(
                    "Protected by reCAPTCHA and subject to the",
                    style: robotostyle(semigray, 12, FontWeight.w400),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Rhombus",
                        style: robotostyle(semigray, 12, FontWeight.w400),
                      ),
                      Text(
                        "Privacy Policy",
                        style: robotostyle(purpal, 12, FontWeight.w400),
                      ),
                      Text(
                        " and ",
                        style: robotostyle(semigray, 12, FontWeight.w400),
                      ),
                      Text(
                        "Terms of Service.",
                        style: robotostyle(purpal, 12, FontWeight.w400),
                      ),
                    ],
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  
}








// import 'package:baseliae_flutter/Component/OnbordingAppbar.dart';
// import 'package:baseliae_flutter/Screens/Onbording/ChargePageCreatScreen.dart';
// import 'package:baseliae_flutter/Screens/Onbording/RegistrationWithemailScreen.dart';
// import 'package:baseliae_flutter/Style/AppStyle.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class Chargeleaderscreen extends StatefulWidget {
//   const Chargeleaderscreen({super.key});

//   @override
//   State<Chargeleaderscreen> createState() => _ChargeleaderscreenState();
// }

// class _ChargeleaderscreenState extends State<Chargeleaderscreen> {
//   final String accountType = Get.arguments["accountType"];

//   final TextEditingController _searchController = TextEditingController();
//   List<DocumentSnapshot> searchResults = [];

//   void _searchChurchPage(String query) async {
//     if (query.isEmpty) {
//       setState(() {
//         searchResults = [];
//       });
//       return;
//     }

//     QuerySnapshot snapshot = await FirebaseFirestore.instance
//         .collection('ChurchPages') // Make sure this collection exists
//         .where('churchName', isGreaterThanOrEqualTo: query)
//         .where('churchName', isLessThanOrEqualTo: query + '\uf8ff')
//         .get();

//     setState(() {
//       searchResults = snapshot.docs;
//     });
//   }

//   void _selectChurchPage(DocumentSnapshot doc) {
//     String churchPageId = doc.id;
//     // Store this churchPageId somewhere (maybe pass it to next screen or controller)
//     Get.snackbar('Selected', 'Church Page Selected: ${doc['churchName']}',
//         backgroundColor: Colors.green, colorText: Colors.white);

//     // Example: Pass to next screen
//     Get.to(() => RegistrationWithEmailscreen(), arguments: {
//       "accountType": accountType,
//       "churchPageId": churchPageId,
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: OnbordingAppbar(context, "Select Church Page"),
//       body: Column(
//         children: [

//            Center(
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Text(
//                 "If you have a church page, then select it",
//                 style: robotostyle(purpal, 18, FontWeight.w600),
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: TextField(
//               controller: _searchController,
//               decoration: InputDecoration(
//                 hintText: 'Search Church Page',
//                 suffixIcon: IconButton(
//                   icon: Icon(Icons.search, color: purpal),
//                   onPressed: () => _searchChurchPage(_searchController.text),
//                 ),
//                 border: OutlineInputBorder(),
//               ),
//               onChanged: _searchChurchPage,
//             ),
//           ),
//           Expanded(
//             child: searchResults.isEmpty
//                 ? Center(child: Text("No results found."))
//                 : ListView.builder(
//                     itemCount: searchResults.length,
//                     itemBuilder: (context, index) {
//                       var doc = searchResults[index];
//                       return ListTile(
//                         title: Text(doc['churchName'], style: robotostyle(Colors.black, 16, FontWeight.w500)),
//                         subtitle: Text(doc['churchLocation'] ?? ''),
//                         onTap: () => _selectChurchPage(doc),
//                       );
//                     },
//                   ),
//           ),
//           // Divider(),
        
//         ],
//       ),
//     );
//   }
// }
