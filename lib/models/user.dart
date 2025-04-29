import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  String name;
  String profilePhoto;
  String email;
  String uid;

  AppUser({
    required this.name,
    required this.email,
    required this.uid,
    required this.profilePhoto,
  });

  // Convert AppUser to JSON format for Firestore storage
  Map<String, dynamic> toJson() => {
    "name": name,
    "profilePhoto": profilePhoto,
    "email": email,
    "uid": uid,
  };

  // Convert Firestore snapshot to AppUser
  static AppUser fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;
    return AppUser(
      email: snapshot['email'],
      profilePhoto: snapshot['profilePhoto'],
      uid: snapshot['uid'],
      name: snapshot['name'],
    );
  }
}
