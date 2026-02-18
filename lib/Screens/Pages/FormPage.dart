import 'package:baseliae_flutter/Style/AppStyle.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class FormPage extends StatefulWidget {
  final String selectedCategory;
  const FormPage({super.key, required this.selectedCategory});

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  String? selectedCategory;

  final List<String> categories = [
    "Need to talk to someone",
    "Need prayer",
    "Urgent need",
  ];

  @override
  void initState() {
    super.initState();
    selectedCategory = widget.selectedCategory;
    _loadUserNameFromFirestore();
  }

  Future<void> _loadUserNameFromFirestore() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        final doc =
            await FirebaseFirestore.instance.collection("Users").doc(uid).get();
        if (doc.exists) {
          final userData = doc.data();
          if (userData != null && userData["fullName"] != null) {
            setState(() {
              nameController.text = userData["fullName"];
            });
          }
        }
      }
    } catch (e) {
      debugPrint("Error loading user name: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whit,
      appBar: AppBar(
        iconTheme: IconThemeData(color: purpal),
        title: const Text("Submit Request"),
        centerTitle: true,
        backgroundColor: whit,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Background decoration
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Colors.purple.shade100],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Form card
          Align(
            alignment: Alignment.center,
            child: SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Text(
                        "Submit Your Request",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: purpal,
                        ),
                      ),
                      const SizedBox(height: 25),

                      // Name field
                      TextFormField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: "Your Name",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.person),
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? "Enter your name"
                            : null,
                      ),
                      const SizedBox(height: 20),

                      // Dropdown for category
                      DropdownButtonFormField<String>(
                        initialValue: selectedCategory,
                        decoration: InputDecoration(
                          labelText: "Select Problem",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.category),
                        ),
                        items: categories
                            .map(
                              (e) => DropdownMenuItem(
                                value: e,
                                child: Text(e),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedCategory = value;
                          });
                        },
                      ),
                      const SizedBox(height: 20),

                      // Description
                      TextFormField(
                        controller: descriptionController,
                        maxLines: 5,
                        decoration: InputDecoration(
                          labelText: "Description",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.description),
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? "Enter description"
                            : null,
                      ),
                      const SizedBox(height: 30),

                      // Submit button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: purpal,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              EasyLoading.show(status: 'Submitting...');
                              try {
                                final currentUser =
                                    FirebaseAuth.instance.currentUser!;
                                final category = selectedCategory!;
                                final description = descriptionController.text;

                                // Fixed SOS Room ID
                                const sosChatId =
                                    "HGeZT0lcmlgItIKks8J4uhtBgXD2-DBu8ya3Be5RMUZYNHOtxbuhv2We2";

                                final sosDocRef = FirebaseFirestore.instance
                                    .collection("chats")
                                    .doc(sosChatId);

                                // Check if the SOS room exists
                                final sosDoc = await sosDocRef.get();
                                if (!sosDoc.exists) {
                                  // Create SOS room if it doesn't exist
                                  List<Map<String, dynamic>> groupMembers = [
                                    {
                                      'id': currentUser.uid,
                                      'fullName':
                                          currentUser.displayName ?? "You",
                                      'profileImage':
                                          currentUser.photoURL ?? "",
                                    },
                                    // You can add predefined admins here if needed
                                  ];

                                  String groupName = "SOS Room";

                                  await sosDocRef.set({
                                    'chatId': sosChatId,
                                    'groupName': groupName,
                                    'members': groupMembers,
                                    'membersIds': groupMembers
                                        .map((m) => m['id'])
                                        .toList(),
                                    'createdBy': currentUser.uid,
                                    'createdAt': FieldValue.serverTimestamp(),
                                    'lastMessage': "",
                                    'lastMessageTime':
                                        FieldValue.serverTimestamp(),
                                    'isGroup': true,
                                  });
                                }

                                // Add the SOS message to messages subcollection
                                await sosDocRef.collection("messages").add({
                                  "read": false,
                                  "receiverId": sosChatId,
                                  "senderId": currentUser.uid,
                                  "text": "$category: $description",
                                  "timestamp": FieldValue.serverTimestamp(),
                                  "type": "text",
                                });

                                // Update last message in chat document
                                await sosDocRef.update({
                                  "lastMessage": "$category: $description",
                                  "lastMessageTime":
                                      FieldValue.serverTimestamp(),
                                });

                                EasyLoading.dismiss();

                                Navigator.pop(context); // Close the form page
                              } catch (e) {
                                debugPrint("Error sending SOS message: $e");

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text("Failed to send request")),
                                );
                              }
                            }
                          },
                          child: const Text(
                            "Submit",
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
