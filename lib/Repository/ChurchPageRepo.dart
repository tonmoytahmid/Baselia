import 'package:baseliae_flutter/Models/ChargePageModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


Stream<List<ChurchPageModel>> fetchChurchPagesFromUserGroups(String userId) async* {
  final userDoc =
      await FirebaseFirestore.instance.collection('Users').doc(userId).get();

  if (userDoc.exists) {
    final groupIds = List<String>.from(userDoc.data()?['groups'] ?? []);

    yield* Stream.fromFuture(Future.wait(groupIds.map((pageId) async {
      final pageDoc = await FirebaseFirestore.instance
          .collection('ChurchPages')
          .doc(pageId)
          .get();

      if (pageDoc.exists) {
        return ChurchPageModel.fromMap(pageId, pageDoc.data()!);
      } else {
        return ChurchPageModel(
          churchPageId: pageId,
          churchName: 'Unknown',
          churchLocation: '',
          profileImage: '',
          coverImage: '',
          ownersName: '',
        );
      }
    }).toList()));
  } else {
    yield [];
  }
}
