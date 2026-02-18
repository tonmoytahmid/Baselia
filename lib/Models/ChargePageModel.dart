class ChurchPageModel {
  final String churchPageId;
  final String churchName;
  final String churchLocation;
  final String profileImage;
  final String coverImage;
  final String ownersName;

  // ✅ Newly added fields
  final String? about;
  final String? dob;
  final String? gender;

  final int followersCount;
  final int followingCount;
  final int postCount;
  final int commentcount;

  final List<String> followers;
  final List<String> following;
  final List<String> pendingRequests;

  ChurchPageModel({
    required this.churchPageId,
    required this.churchName,
    required this.churchLocation,
    required this.profileImage,
    required this.coverImage,
    required this.ownersName,
    this.about,
    this.dob,
    this.gender,
    this.followersCount = 0,
    this.followingCount = 0,
    this.postCount = 0,
    this.commentcount = 0,
    List<String>? followers,
    List<String>? following,
    List<String>? pendingRequests,
  })  : followers = followers ?? [],
        following = following ?? [],
        pendingRequests = pendingRequests ?? [];

  factory ChurchPageModel.fromMap(String id, Map<String, dynamic> map) {
    return ChurchPageModel(
      churchPageId: id,
      churchName: map['churchName'] ?? '',
      churchLocation: map['churchLocation'] ?? '',
      profileImage: map['profileImage'] ?? '',
      coverImage: map['coverImage'] ?? '',
      ownersName: map['Ownersname'] ?? '',
      about: map['about'],
      dob: map['dob'],
      gender: map['gender'],
      followersCount: map['followersCount'] ?? 0,
      followingCount: map['followingCount'] ?? 0,
      postCount: map['postCount'] ?? 0,
      commentcount: map['commentcount'] ?? 0,
      followers: (map['followers'] as List<dynamic>?)?.cast<String>() ?? [],
      following: (map['following'] as List<dynamic>?)?.cast<String>() ?? [],
      pendingRequests:
          (map['pendingRequests'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'churchName': churchName,
      'churchLocation': churchLocation,
      'profileImage': profileImage,
      'coverImage': coverImage,
      'Ownersname': ownersName,
      'about': about,
      'dob': dob,
      'gender': gender,
      'followersCount': followersCount,
      'followingCount': followingCount,
      'postCount': postCount,
      'commentcount': commentcount,
      'followers': followers,
      'following': following,
      'pendingRequests': pendingRequests,
    };
  }
}

// class ChurchPageModel {
//   final String churchPageId;
//   final String churchName;
//   final String churchLocation;
//   final String profileImage;
//   final String coverImage;
//   final String ownersName;

//   ChurchPageModel({
//     required this.churchPageId,
//     required this.churchName,
//     required this.churchLocation,
//     required this.profileImage,
//     required this.coverImage,
//     required this.ownersName,
//   });

//   factory ChurchPageModel.fromMap(String id, Map<String, dynamic> map) {
//     return ChurchPageModel(
//       churchPageId: id,
//       churchName: map['churchName'] ?? '',
//       churchLocation: map['churchLocation'] ?? '',
//       profileImage: map['profileImage'] ?? '',
//       coverImage: map['coverImage'] ?? '',
//       ownersName: map['Ownersname'] ?? '',
//     );
//   }
// }
