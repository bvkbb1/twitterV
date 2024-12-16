/*
  COMMENTS

    - this is what that every comment should have
 */

import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id; // id for this comment
  final String postId; // id for the respective post
  final String uid; // user id of the commenter
  final String name; // name of the commenter
  final String userName; // user name of the commenter
  final String message; // comment message by the commenter
  final Timestamp timeStamp; // time stamp for the comment when commented

  Comment({
    required this.id,
    required this.postId,
    required this.uid,
    required this.name,
    required this.userName,
    required this.message,
    required this.timeStamp,
  });

  // convert the firebase map/document to model object
  factory Comment.fromDocument(DocumentSnapshot doc){
    return Comment(
      id: doc.id,
      postId: doc['postId'],
      uid: doc['uid'],
      name: doc['name'],
      userName: doc['userName'],
      message: doc['message'],
      timeStamp: doc['timeStamp']
    );
  }

  // convert the model object to map
  Map<String, dynamic> toMap(){
    return {
      'id': id,
      'postId' : postId,
      'uid': uid,
      'name': name,
      'userName': userName,
      'message': message,
      'timeStamp': timeStamp
    };
  }


}