import 'package:cloud_firestore/cloud_firestore.dart';

class Usermodel {
  static const String defaultProfileImage = "https://cdn-icons-png.flaticon.com/512/847/847969.png";
  static const String defaultCoverImage = "https://cdn-icons-png.flaticon.com/512/847/847969.png";

  final String uid;
  final String email;
  final String fullName;
  final String accountType;
  final String phone;
  final String? password;
  final String? bio;
  final String? deviceToken;
  final String profileImage;
  final String coverImage;
  final DateTime createdAt;
  final List<String> groups;
  final String? location;
  final String? about;
  final String? dob;
  final String? gender;
 
  // ✅ Added follower and following counters
  final int followersCount;
  final int followingCount;
  final int postCount;
  final int commentcount;

  final List<String> followers;
  final List<String> following;
  final List<String> pendingRequests;

  Usermodel({
    required this.uid,
    required this.email,
    required this.fullName,
    required this.accountType,
    required this.phone,
    required this.dob,
    required this.gender,
    this.password,
    this.bio,
    
    this.deviceToken,
    String? profileImage,
    String? coverImage,
    required this.createdAt,
    List<String>? groups,
    this.location,
    this.about,
    List<String>? followers,
    List<String>? following,
    List<String>? pendingRequests,
    // ✅ Initialize counter values
    int? followersCount,
    int? followingCount,
    this.postCount = 0,
    this.commentcount=0,
  })  : profileImage = profileImage ?? defaultProfileImage,
        coverImage = coverImage ?? defaultCoverImage,
        groups = groups ?? [],
        followers = followers ?? [],
        following = following ?? [],
        pendingRequests = pendingRequests ?? [],
        followersCount = followers?.length ?? 0,
        followingCount = following?.length ?? 0;

  factory Usermodel.fromMap(Map<String, dynamic> json) {
    return Usermodel(
      uid: json['uid'] as String? ?? '',
      email: json['email'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      accountType: json['accountType'] as String? ?? 'regular',
      phone: json['phone'],
      password: json['password'] as String?,
      bio: json['bio'] as String?,
      deviceToken: json['deviceToken'] as String?,
      profileImage: json['profileImage'] as String?,
      coverImage: json['coverImage'] as String?,
      createdAt: _parseDateTime(json['createdAt']),
      groups: (json['groups'] as List<dynamic>?)?.cast<String>() ?? [],
      location: json['location'] as String?,
      about: json['about'] as String?,
      followers: (json['followers'] as List<dynamic>?)?.cast<String>() ?? [],
      following: (json['following'] as List<dynamic>?)?.cast<String>() ?? [],
      pendingRequests:
          (json['pendingRequests'] as List<dynamic>?)?.cast<String>() ?? [],
      followersCount: json['followersCount'] as int? ?? 0,
      followingCount: json['followingCount'] as int? ?? 0,
      dob: json['dob'] as String?,
      gender: json['gender'] as String?,
      postCount: json['postCount'] as int? ?? 0,
      commentcount: json['commentcount'] as int? ?? 0,
    
    );
  }

  static DateTime _parseDateTime(dynamic timestamp) {
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    }
    if (timestamp is String) {
      return DateTime.parse(timestamp);
    }
    return DateTime.now();
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'fullName': fullName,
      'accountType': accountType,
      'phone': phone,
      'password': password,
      'bio': bio,
      'deviceToken': deviceToken,
      'profileImage': profileImage,
      'coverImage': coverImage,
      'createdAt': Timestamp.fromDate(createdAt),
      'groups': groups,
      'location': location,
      'about': about,
      'followers': followers,
      'following': following,
      'pendingRequests': pendingRequests,
      'dob': dob,
      'gender': gender,
      'followersCount': followers.length, // ✅ Update count
      'followingCount': following.length, // ✅ Update count
      'postCount': postCount,
      'commentcount': commentcount,
     
    };
  }
}













// import 'package:cloud_firestore/cloud_firestore.dart';

// class Usermodel {
//   static const String defaultProfileImage = '';
//   static const String defaultCoverImage = '';

//   final String uid;
//   final String email;
//   final String fullName;
//   final String accountType;
//   final String phone;
//   final String? password;
//   final String? bio;
//   final String? deviceToken;
//   final String profileImage;
//   final String coverImage;
//   final DateTime createdAt;
//   final List<String> groups;
//   final String? location;
//   final String? about;
//   final String? dob;
//   final String? gender;
//   final int followersCount;
//   final int followingCount;

 
//   final List<String> followers; 
//   final List<String> following; 
//   final List<String> pendingRequests; 
//   Usermodel({
//     required this.uid,
//     required this.email,
//     required this.fullName,
//     required this.accountType,
//     required this.phone,
//     required this.dob,
//     required this.gender,
//     this.password,
//     this.bio,
//     this.deviceToken,
//     String? profileImage,
//     String? coverImage,
//     required this.createdAt,
//     List<String>? groups,
//     this.location,
//     this.about,
//     List<String>? followers,
//     List<String>? following,
//     List<String>? pendingRequests,
//      int? followersCount,
//      int? followingCount,
//   })  : profileImage = profileImage ?? defaultProfileImage,
//         coverImage = coverImage ?? defaultCoverImage,
//         groups = groups ?? [],
//         followers = followers ?? [],
//         following = following ?? [],
//         pendingRequests = pendingRequests ?? [];
//          followersCount = followers?.length ?? 0,
//         followingCount = following?.length ?? 0;


//   factory Usermodel.fromMap(Map<String, dynamic> json) {
//     return Usermodel(
//       uid: json['uid'] as String? ?? '',
//       email: json['email'] as String? ?? '',
//       fullName: json['fullName'] as String? ?? '',
//       accountType: json['accountType'] as String? ?? 'regular',
//       phone: json['phone'] as String? ?? '',
//       password: json['password'] as String?,
//       bio: json['bio'] as String?,
//       deviceToken: json['deviceToken'] as String?,
//       profileImage: json['profileImage'] as String?,
//       coverImage: json['coverImage'] as String?,
//       createdAt: _parseDateTime(json['createdAt']),
//       groups: (json['groups'] as List<dynamic>?)?.cast<String>() ?? [],
//       location: json['location'] as String?,
//       about: json['about'] as String?,
//       followers: (json['followers'] as List<dynamic>?)?.cast<String>() ?? [],
//       following: (json['following'] as List<dynamic>?)?.cast<String>() ?? [],
//       pendingRequests:
//           (json['pendingRequests'] as List<dynamic>?)?.cast<String>() ?? [],
//           dob: json['dob'] as String?,
//           gender: json['gender'] as String,
//           followersCount: json['followersCount'] as int? ?? 0,
//       followingCount: json['followingCount'] as int? ?? 0,
//     );
//   }

//   static DateTime _parseDateTime(dynamic timestamp) {
//     if (timestamp is Timestamp) {
//       return timestamp.toDate();
//     }
//     if (timestamp is String) {
//       return DateTime.parse(timestamp);
//     }
//     return DateTime.now();
//   }

//   Map<String, dynamic> toMap() {
//     return {
//       'uid': uid,
//       'email': email,
//       'fullName': fullName,
//       'accountType': accountType,
//       'phone': phone,
//       'password': password,
//       'bio': bio,
//       'deviceToken': deviceToken,
//       'profileImage': profileImage,
//       'coverImage': coverImage,
//       'createdAt': Timestamp.fromDate(createdAt),
//       'groups': groups,
//       'location': location,
//       'about': about,
//       'followers': followers,
//       'following': following,
//       'pendingRequests': pendingRequests,
//       'dob':dob,
//       'gender':gender,
//       'followersCount': followers.length,
//       'followingCount': following.length,
//     };
//   }
// }
