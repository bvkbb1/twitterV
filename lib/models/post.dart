/*
  POST MODEL
  For every post the common fields are

  ______________________________________________________________________________

    - id
    - uid


 */

import 'package:cloud_firestore/cloud_firestore.dart';


class Post{
  final String id;  // id for thr respective post
  final String uid; // uid of the poster/user
  final String name; // name of the user
  final String userName; // user name
  final String message;
  final Timestamp timeStamp; // wime whe we upload the post
  final int likesCount;
  final List likedBy;

  Post({
    required this.id,
    required this.uid,
    required this.name,
    required this.userName,
    required this.message,
    required this.timeStamp,
    required this.likesCount,
    required this.likedBy,
  });


  // converting into a firestore document
  factory Post.fromDocument({required DocumentSnapshot doc}){
    return Post(
      id: doc.id,
      uid:  doc['uid'] ?? '',
      name:  doc['name'] ?? '',
      userName:  doc['userName'] ?? '',
      message:  doc['message'] ?? '',
      timeStamp:  doc['timeStamp'] ?? '',
      likesCount:  doc['likesCount'] ?? '',
      likedBy:  doc['likedBy'] ?? <String>[]
    );
  }


  // converting a post object to a Map<> to store in firebase
  Map<String, dynamic> toMap(){
    return {
      'id':id,
      'uid':uid,
      'name':name,
      'userName':userName,
      'message':message,
      'timeStamp':timeStamp,
      'likesCount':likesCount,
      'likedBy':likedBy,
    };
  }
}