/*
  FOLLOW BUTTON
  This is a follow or unfolloe button, depending on whose profile page we are
  currently viewing

  ______________________________________________________________________________

  To use this widget we need:
  - a function (wheather the user can follow or unfollow)
  - a boolean (wheagther the current user following or not)

 */

import 'package:flutter/material.dart';

class MyFollowButton extends StatelessWidget {
  final Function()? onTapped;
  final bool isFollowing;
  const MyFollowButton({
    super.key,
    required this.onTapped,
    required this.isFollowing
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: ElevatedButton(
        onPressed: onTapped,
        style: ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(isFollowing ? Theme.of(context).colorScheme.primary : Colors.blue),
          foregroundColor: const WidgetStatePropertyAll(Colors.white),
          elevation: const WidgetStatePropertyAll(5),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10), // Set your desired border radius here
            ),
          ),
        ),
        child: Text(
          isFollowing
          ? 'Unfollow'
          : 'Follow',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}