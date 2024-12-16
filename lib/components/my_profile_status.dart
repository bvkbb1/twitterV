/*
  PROFILE STATS

  This will be displayed on the profile page of every user
  ______________________________________________________________________________

  Number of :
  - posts
  - followers
  - following
 */

import 'package:flutter/material.dart';

class MyProfileStatus extends StatelessWidget {
  final int postCount;
  final int followingCount;
  final int folowersCount;
  final Function()? onTap;

  const MyProfileStatus({
    super.key,
    required this.postCount,
    required this.followingCount,
    required this.folowersCount,
    required this.onTap
  });

  @override
  Widget build(BuildContext context) {
    // count text style (common)
    final countStyle = TextStyle(
      fontSize: 18, color: Theme.of(context).colorScheme.inversePrimary
    );

    final textStyle = TextStyle(
      color: Theme.of(context).colorScheme.primary
    );
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children:[
          // posts
          SizedBox(
            width: 100,
            child: Column(
              children: [
                Text(postCount.toString(), style: countStyle,),
                Text('Posts', style: textStyle,),
              ],
            ),
          ),
      
          // followers
          SizedBox(
            width: 100,
            child: Column(
              children: [
                Text(folowersCount.toString(), style: countStyle,),
                Text('Followers',  style: textStyle,),
              ],
            ),
          ),
      
          // following
          SizedBox(
            width: 100,
            child: Column(
              children: [
                Text(followingCount.toString(), style: countStyle,),
                Text('Following',  style: textStyle,),
              ],
            ),
          ),
      
        ]
      ),
    );
  }
}