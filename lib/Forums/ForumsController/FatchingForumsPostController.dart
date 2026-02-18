import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class FetchingForumController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final int pageSize = 10;

  DocumentSnapshot? lastDocument;
  RxBool isFetching = false.obs;
  RxList<Map<String, dynamic>> forums = <Map<String, dynamic>>[].obs;

  // This will be updated when user selects a category from dropdown
 

  /// Fetch initial forums for the selected category
  Future<void> fetchInitialForums({required String category}) async {
    if (isFetching.value || category. isEmpty) return;
    isFetching.value = true;

    try {
      QuerySnapshot snapshot = await _firestore
          .collection('Forums')
          .where('category', isEqualTo: category)
          .orderBy('timestamp', descending: true)
          .limit(pageSize)
          .get();

      if (snapshot.docs.isNotEmpty) {
        lastDocument = snapshot.docs.last;
      }

      List<Map<String, dynamic>> newForums = await _fetchUserData(snapshot.docs);
      forums.assignAll(newForums); // replace old
    } catch (e) {
      print("Error fetching forums: $e");
    } finally {
      isFetching.value = false;
    }
  }

  /// Fetch more forums
  Future<void> fetchMoreForums({required String category}) async {
    if (isFetching.value || lastDocument == null || category.isEmpty) return;
    isFetching.value = true;

    try {
      QuerySnapshot snapshot = await _firestore
          .collection('Forums')
          .where('category', isEqualTo: category)
          .orderBy('timestamp', descending: true)
          .startAfterDocument(lastDocument!)
          .limit(pageSize)
          .get();

      if (snapshot.docs.isNotEmpty) {
        lastDocument = snapshot.docs.last;
      }

      List<Map<String, dynamic>> newForums = await _fetchUserData(snapshot.docs);
      forums.addAll(newForums); // append
    } catch (e) {
      print("Error fetching more forums: $e");
    } finally {
      isFetching.value = false;
    }
  }

  /// Fetch user info for forum posts
  Future<List<Map<String, dynamic>>> _fetchUserData(List<QueryDocumentSnapshot> docs) async {
    List<Map<String, dynamic>> forumList = [];

    for (var doc in docs) {
      Map<String, dynamic> forum = doc.data() as Map<String, dynamic>;
      forum['postId'] = doc.id;

      try {
        DocumentSnapshot userSnapshot = await _firestore.collection('Users').doc(forum['userId']).get();

        if (userSnapshot.exists) {
          Map<String, dynamic> user = userSnapshot.data() as Map<String, dynamic>;
          forum['userName'] = user['fullName'];
          forum['userProfileImage'] = user['profileImage'];
          forum['accountType'] = user['accountType'];
          forum['bio'] = user['bio'];
        } else {
          forum['userName'] = "Unknown";
          forum['userProfileImage'] = "";
        }
      } catch (e) {
        print("Error fetching user data: $e");
        forum['userName'] = "Unknown";
        forum['userProfileImage'] = "";
      }

      forumList.add(forum);
    }

    return forumList;
  }

  /// Update category and fetch forums
  void updateCategory(String category) {
   
    lastDocument = null;
    fetchInitialForums(category: category);
  }
}
