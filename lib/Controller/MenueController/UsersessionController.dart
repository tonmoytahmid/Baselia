import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class UserSessionController extends GetxController {
  var isPageProfile = false.obs; // true if switched to church page
  var activeUid = ''.obs; // either FirebaseAuth.uid or churchPageId
  var currentProfileData = <String, dynamic>{}.obs;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void onInit() {
    super.onInit();
    initializeSession(); // Automatically run on controller creation
  }

  void initializeSession() {
    final user = _auth.currentUser;
    if (user != null) {
      // Default to user profile when app starts
      activeUid.value = user.uid;
      isPageProfile.value = false;
      // You can fetch the currentProfileData if needed:
      // e.g., from Firestore
    }
  }

  void switchToUser(String uid, Map<String, dynamic> userData) {
    isPageProfile.value = false;
    activeUid.value = uid;
    currentProfileData.value = userData;
  }

  void switchToChurchPage(String churchPageId, Map<String, dynamic> pageData) {
    isPageProfile.value = true;
    activeUid.value = churchPageId;
    currentProfileData.value = pageData;
  }

  void clearSession() {
    isPageProfile.value = false;
    activeUid.value = '';
    currentProfileData.clear();
  }
}

// import 'package:get/get.dart';

// class UserSessionController extends GetxController {
//   var isPageProfile = false.obs; // true if switched to church page
//   var activeUid = ''.obs; // either FirebaseAuth.uid or churchPageId
//   var currentProfileData = <String, dynamic>{}.obs;

//   // Set user mode
//   void switchToUser(String uid, Map<String, dynamic> userData) {
//     isPageProfile.value = false;
//     activeUid.value = uid;
//     currentProfileData.value = userData;
//   }

//   // Set page mode
//   void switchToChurchPage(String churchPageId, Map<String, dynamic> pageData) {
//     isPageProfile.value = true;
//     activeUid.value = churchPageId;
//     currentProfileData.value = pageData;
//   }

//   void clearSession() {
//     isPageProfile.value = false;
//     activeUid.value = '';
//     currentProfileData.clear();
//   }
// }
