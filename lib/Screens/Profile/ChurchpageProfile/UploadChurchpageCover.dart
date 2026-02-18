import 'package:baseliae_flutter/Controller/PostController/UploadPageCoverImage.dart';
import 'package:baseliae_flutter/Controller/PostController/UploadcoverImage.dart';
import 'package:baseliae_flutter/Style/AppStyle.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UploadCoveronPage extends StatefulWidget {
  const UploadCoveronPage({super.key});

  @override
  State<UploadCoveronPage> createState() => _UploadCoveronPageState();
}

class _UploadCoveronPageState extends State<UploadCoveronPage> {
  final Uploadpagecoverimage uploadcoverImage = Get.put(Uploadpagecoverimage());
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
        title: Text("Preview Cover Picture",
            style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              GetBuilder<UploadcoverImage>(
                builder: (controller) {
                  return Container(
                    height: 334,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Color(0XFF111112),
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
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: uploadcoverImage.captionController,
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
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: ElevatedButton(
                  onPressed: () => uploadcoverImage.pickSingleImage(),
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
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: ElevatedButton(
                  onPressed: () => uploadcoverImage.uploadAndUpdateCover(
                    uid,
                  ),
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
  }
}
