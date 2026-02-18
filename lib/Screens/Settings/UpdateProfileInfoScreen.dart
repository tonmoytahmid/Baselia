import 'package:baseliae_flutter/Style/AppStyle.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

class Updateprofileinfoscreen extends StatefulWidget {
  const Updateprofileinfoscreen({super.key});

  @override
  State<Updateprofileinfoscreen> createState() =>
      _UpdateprofileinfoscreenState();
}

class _UpdateprofileinfoscreenState extends State<Updateprofileinfoscreen> {
  TextEditingController? nameController = TextEditingController();

  TextEditingController? numberController = TextEditingController();
  TextEditingController dateofbirthController = TextEditingController();
  TextEditingController? emailController = TextEditingController();
  TextEditingController? addressController = TextEditingController();

  final List<String> items = [
    'Male',
    'Female',
  ];
  String? selectedItem;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

   @override
  void initState() {
    super.initState();
    fetchUserData();
   
 
    
  }

  Future<void> fetchUserData() async {
    String uid = auth.currentUser?.uid ?? "";
    if (uid.isEmpty) return;

    DocumentSnapshot userDoc =
        await firestore.collection('Users').doc(uid).get();
    if (userDoc.exists) {
      Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;

      setState(() {
        nameController?.text = data['fullName'] ?? "";

        numberController?.text = data['phone'] ?? "";
        dateofbirthController.text = data['dob'] ?? "";
        emailController?.text = data['email'] ?? "";
        addressController?.text = data['location'] ?? "";
        
      });
    }
  }
 

  Future<void> updateUserData() async {
    String uid = auth.currentUser?.uid ?? "";
    if (uid.isEmpty) return;
    EasyLoading.show(status: "Updating");
    await firestore.collection('Users').doc(uid).update({
      'fullName': nameController?.text,
      'phone': numberController?.text,
      'dob': dateofbirthController.text,
      'email': emailController?.text,
      'location': addressController?.text,
      'gender': selectedItem.toString(),
    });
    EasyLoading.dismiss();
    Get.snackbar("Success", "Profile updated successfully");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whit,
      appBar: AppBar(
        backgroundColor: whit,
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
        title: Text(
          "Personal Information",
          style: robotostyle(black, 16, FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 30,
              ),
              Text(
                textAlign: TextAlign.left,
                "User Name",
                style: robotostyle(purpal, 14, FontWeight.w600),
              ),
              SizedBox(
                height: 10,
              ),
              TextFormField(
                controller: nameController,
                onEditingComplete: () => FocusScope.of(context).unfocus(),
                onTapOutside: (event) => FocusScope.of(context).unfocus(),
                decoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 13, horizontal: 20),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: lightpinkish),
                        borderRadius: BorderRadius.all(Radius.circular(8)))),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                textAlign: TextAlign.left,
                "E-mail Address",
                style: robotostyle(purpal, 14, FontWeight.w600),
              ),
              SizedBox(
                height: 10,
              ),
              TextFormField(
                controller: emailController,
                readOnly: true,
                decoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 13, horizontal: 20),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: lightpinkish),
                        borderRadius: BorderRadius.all(Radius.circular(8)))),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                textAlign: TextAlign.left,
                "Contact Number",
                style: robotostyle(purpal, 14, FontWeight.w600),
              ),
              SizedBox(
                height: 10,
              ),
              TextFormField(
                controller: numberController,
                onEditingComplete: () => FocusScope.of(context).unfocus(),
                onTapOutside: (event) => FocusScope.of(context).unfocus(),
                decoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 13, horizontal: 20),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: lightpinkish),
                        borderRadius: BorderRadius.all(Radius.circular(8)))),
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        textAlign: TextAlign.left,
                        "Date of Birth",
                        style: robotostyle(purpal, 14, FontWeight.w600),
                      ),
                      Container(
                        width: 158,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          border: Border.all(color: lightpinkish),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            readOnly:
                                true, // Important: user cannot type manually
                            controller: dateofbirthController,
                            onTap: () async {
                              DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(1900), // Earliest date
                                lastDate: DateTime.now(), // Latest date
                              );
                              // Format the picked date
                              String formattedDate =
                                  "${pickedDate!.month}/${pickedDate.day}/${pickedDate.year}";
                              setState(() {
                                dateofbirthController.text =
                                    formattedDate; // Set the text
                              });
                                                        },
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderSide: BorderSide.none),
                              hintText: "MM/DD/YYYY",
                              hintStyle: TextStyle(fontSize: 12, color: black),
                              suffixIcon: Icon(
                                Icons.date_range,
                                color: lightpinkish,
                                size: 14,
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        textAlign: TextAlign.left,
                        "Gender",
                        style: robotostyle(purpal, 14, FontWeight.w600),
                      ),
                      Container(
                        width: 158,
                        height: 40,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            border: Border.all(color: lightpinkish)),
                        child: Center(
                          child: DropdownButton<String>(
                              value: selectedItem,
                              elevation: 0,
                              hint: const Text('Select'),
                              icon: const Icon(
                                Icons.arrow_downward_outlined,
                                color: semigray,
                              ),
                              onChanged: (newvalue) {
                                setState(() {
                                  selectedItem = newvalue;
                                });
                              },
                              items: items.map<DropdownMenuItem<String>>(
                                  (String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList()),
                        ),
                      )
                    ],
                  )
                ],
              ),
              SizedBox(
                height: 15,
              ),
              Text(
                textAlign: TextAlign.left,
                "Address",
                style: robotostyle(purpal, 14, FontWeight.w600),
              ),
              SizedBox(
                height: 10,
              ),
              TextFormField(
                maxLines: 2,
                controller: addressController,
                onEditingComplete: () => FocusScope.of(context).unfocus(),
                onTapOutside: (event) => FocusScope.of(context).unfocus(),
                decoration: InputDecoration(
                  hintText: "Country / City / Street",
                  hintStyle: TextStyle(fontSize: 12, color: semigray),
                    contentPadding: EdgeInsets.symmetric(horizontal: 20),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: lightpinkish),
                        borderRadius: BorderRadius.all(Radius.circular(8)))),
              ),
              SizedBox(
                height: 70,
              ),
              ElevatedButton(
                  style: AppButtonStyle(purpal),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return SizedBox(
                          height: 116,
                          width: 236,
                          child: AlertDialog(
                            elevation: 20,
                            backgroundColor: whit,
                            content: Text(
                              textAlign: TextAlign.center,
                              "Are you sure you want to save the changes made? the changes made?",
                              style: robotostyle(black, 14, FontWeight.w400),
                            ),
                            actions: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text(
                                      "Cancel",
                                      style: robotostyle(
                                          semigray, 16, FontWeight.w600),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      updateUserData();
                                    },
                                    child: Text(
                                      "Confirm",
                                      style: robotostyle(
                                          purpal, 16, FontWeight.w600),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  child: SuccessButtonChild2("Save Changes"))
            ],
          ),
        ),
      ),
    );
  }
}
