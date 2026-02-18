import 'package:baseliae_flutter/Controller/PostController/UploadprofileImage.dart';
import 'package:baseliae_flutter/Style/AppStyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Uploadprofilescreen extends StatefulWidget {
  const Uploadprofilescreen({super.key});

  @override
  State<Uploadprofilescreen> createState() => _UploadprofilescreenState();
}

class _UploadprofilescreenState extends State<Uploadprofilescreen> {
   final Uploadprofileimage uploadprofileimage = Get.put(Uploadprofileimage());
    String uid = Get.arguments['uid'];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whit,
      appBar: AppBar(
        
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.purple),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Preview Profile Picture", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric( vertical: 20),
          child: Column(
            children: [
        
               GetBuilder<Uploadprofileimage>(
              builder: (controller) {
                return Container(
                  height: 334,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color:Color(0XFF111112),
                   
                  ),
                  child: Center(
                    child: CircleAvatar(
                      radius: 200,
                      backgroundImage: controller.selectedFile != null
                          ? FileImage(controller.selectedFile!)
                          : null,
                      child: controller.selectedFile == null
                          ? Icon(Icons.person, size: 50, color: Colors.grey)
                          : null,
                    ),
                  ),
                );
              },
            ),
              
           
        
              SizedBox(height: 30),
        
             
              Padding(
                padding:  EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: uploadprofileimage.captionController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    
                    hintText: "Write a caption.....",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.purple),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 70),
        
              
              Padding(
                 padding:  EdgeInsets.symmetric(horizontal: 20),
                child: ElevatedButton(
                  onPressed:()=> uploadprofileimage.pickSingleImage(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0XFFF2F3F5),
                    foregroundColor: Colors.black,
                    minimumSize: Size(double.infinity, 50),
                  ),
                  child: Text("Select Another Photo"),
                ),
              ),
              SizedBox(height: 20),
        
             
              Padding(
                 padding:  EdgeInsets.symmetric(horizontal: 20),
                child: ElevatedButton(
                  onPressed:()=> uploadprofileimage.uploadAndUpdateProfile(uid, ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: purpal,
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 50),
                  ),
                  child: Text("Confirm"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    
    // Scaffold(
    //   body: Column(
    //     mainAxisAlignment: MainAxisAlignment.center,
    //     children: [
    //          Center(child: GestureDetector(
    //           onTap: () => uploadprofileimage.pickSingleImage(),
    //           child: Text("Select image"))),

          //   GetBuilder<Uploadprofileimage>(
          //   // Update UI when selectedFiles change
          //   builder: (_) => uploadprofileimage.buildSelectedMedia(),
          // ),

    //       Center(child: GestureDetector(
    //         onTap: () => uploadprofileimage.uploadAndUpdateProfile(uid, ),
    //         child: Text("Upload Screen"))),
    //     ],
    //   ),
    // );
  }
}