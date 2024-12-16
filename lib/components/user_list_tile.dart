/*
  USER LIST TILE
  This is to display the each user as a nice tile. we will use this when we need
  to display a list of users, for eg. in the user search result or viewing the
  follower of a user

  ______________________________________________________________________________

  Th use this widget we need :
  - a user

 */

import 'package:flutter/material.dart';
import 'package:twitter_clone_v/models/user.dart';
import 'package:twitter_clone_v/pages/profile_page.dart';

class MyUserTile extends StatelessWidget {
  final UserProfile user;
  const MyUserTile({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5) ,
      decoration: BoxDecoration(
        // color of the tile
        color: Theme.of(context).colorScheme.secondary,

        // curve the corners
        borderRadius: BorderRadius.circular(10)
      ),
      child: ListTile(

        textColor: Theme.of(context).colorScheme.primary,
        // priofile pic
        leading: Icon(Icons.person, color: Theme.of(context).colorScheme.primary,),
        title: Text(user.name),
        titleTextStyle: TextStyle(
          color: Theme.of(context).colorScheme.inversePrimary
        ),

        subtitle: Text('@${user.userName}'),
        subtitleTextStyle: TextStyle(
          color: Theme.of(context).colorScheme.primary
        ),

        onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (context)=> ProfilePage(uid: user.uid))),

        trailing: Icon(Icons.arrow_right),
      ),
    );
  }
}