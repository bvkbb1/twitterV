/*
  USER PROFILE
  This is what every user shoud have for their profile

  ---------------------------------------------------------

  -uid
  - name
  - email
  - userName
  - bio
  - profile photo ( we will do at last, we need to do some extra stuff)

 */

import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile{
  final String uid;
  final String name;
  final String email;
  final String userName;
  final String bio;

  UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    required this.userName,
    required this.bio,
  });


  /*
    firebase -> app
    convert the UserProfile to firebase document format
  */

  factory UserProfile.fromDocument(DocumentSnapshot doc){
    return UserProfile(
      uid: doc['uid'] ?? '',
      name: doc['name'] ?? '',
      email: doc['email'] ?? '',
      userName: doc['userName'] ?? '',
      bio: doc['bio'] ?? ''
    );
  }

  /*
    app -> firebase
    convert the UserProfile to map<String, dynamic>
   */

  Map<String, dynamic> toMap(){
    return {
      'uid' : uid,
      'name' : name,
      'email' : email,
      'userName' : userName,
      'bio' : bio,
    };
  }

}