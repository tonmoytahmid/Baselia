import 'package:baseliae_flutter/Screens/Story/UploadStoryController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';

class StoryUploadScreen extends StatelessWidget {
  final StoryUploadingController controller =
      Get.put(StoryUploadingController());

   StoryUploadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upload Story")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: controller.pickMedia,
              icon: const Icon(Icons.photo),
              label: const Text("Select Media"),
            ),
            const SizedBox(height: 10),
            Obx(() => controller.selectedFiles.isEmpty
                ? const Text("No media selected")
                : SizedBox(
                    height: 300,
                    child: GridView.builder(
                      itemCount: controller.selectedFiles.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 6,
                        mainAxisSpacing: 6,
                      ),
                      itemBuilder: (context, index) {
                        File file = controller.selectedFiles[index];
                        return Stack(
                          children: [
                            file.path.endsWith('.mp4')
                                ? const Icon(Icons.videocam, size: 60)
                                : Image.file(file, fit: BoxFit.cover),
                            Positioned(
                              top: 2,
                              right: 2,
                              child: GestureDetector(
                                onTap: () {
                                  controller.selectedFiles.removeAt(index);
                                },
                                child: const CircleAvatar(
                                  radius: 10,
                                  backgroundColor: Colors.red,
                                  child: Icon(Icons.close,
                                      size: 14, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  )),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: controller.uploadStory,
              icon: const Icon(Icons.upload),
              label: const Text("Upload Story"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
            )
          ],
        ),
      ),
    );
  }
}

// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';

// class Creatstoryscreen extends StatefulWidget {
//   const Creatstoryscreen({super.key});

//   @override
//   State<Creatstoryscreen> createState() => _CreatstoryscreenState();
// }

// class _CreatstoryscreenState extends State<Creatstoryscreen> {
//   final TextEditingController _captionController = TextEditingController();
//   File? _pickedImage;

//   Future<void> _pickImage() async {
//     final pickedFile =
//         await ImagePicker().pickImage(source: ImageSource.gallery);

//     if (pickedFile != null) {
//       setState(() {
//         _pickedImage = File(pickedFile.path);
//       });
//     }
//   }

//   void _uploadStory() {
//     if (_pickedImage != null || _captionController.text.isNotEmpty) {
//       // You can upload to Firebase or any backend here
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Story uploaded successfully!')),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please add an image or caption')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Upload Story'),
//         centerTitle: true,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             GestureDetector(
//               onTap: _pickImage,
//               child: _pickedImage != null
//                   ? Image.file(_pickedImage!,
//                       height: 200, width: double.infinity, fit: BoxFit.cover)
//                   : Container(
//                       height: 200,
//                       width: double.infinity,
//                       color: Colors.grey[300],
//                       child: const Icon(Icons.add_a_photo,
//                           size: 50, color: Colors.grey),
//                     ),
//             ),
//             const SizedBox(height: 16),
//             TextField(
//               controller: _captionController,
//               decoration: const InputDecoration(
//                 labelText: 'Write a caption...',
//                 border: OutlineInputBorder(),
//               ),
//               maxLines: 2,
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton.icon(
//               onPressed: _uploadStory,
//               icon: const Icon(Icons.upload),
//               label: const Text('Upload Story'),
//               style: ElevatedButton.styleFrom(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
