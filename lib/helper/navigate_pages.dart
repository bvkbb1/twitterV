import 'package:flutter/material.dart';
import 'package:twitter_clone_v/models/post.dart';
import 'package:twitter_clone_v/pages/account_settings_page.dart';
import 'package:twitter_clone_v/pages/blocked_users_page.dart';
import 'package:twitter_clone_v/pages/home_page.dart';
import 'package:twitter_clone_v/pages/post_page.dart';
import 'package:twitter_clone_v/pages/profile_page.dart';

// go to the users page based on the uid
void goToTheUserPage({required BuildContext context, required String uid}){
  // let's navigate to the respective user page
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ProfilePage(uid: uid)
    )
  );
}

// go to the post page
void goToThePostPage({required BuildContext context, required Post post}){
  // let's navigate to the respective user page
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => PostPage(post: post,)
    )
  );
}

// go to blocked users page
void goToBlockedUsersPage({required BuildContext context}){
  // let's navigate to the respective user page
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => BlockedUsersPage()
    )
  );
}

void goToAccountSettingsPage({required BuildContext context}){
  // let's navigate to the respective user page
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => AccountSettingsPage()
    )
  );
}

// go to hoem page
void toToHomePage({required BuildContext context}){
  // let's navigate to the respective user page
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(
      builder: (context) => HomePage()
    ),

    // keep the first page auth route
    (route)=> route.isFirst
  );
}