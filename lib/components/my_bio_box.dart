import 'package:flutter/material.dart';

/*
  USER BIO BOX

  This is the simple box with text inside, we will use this for the each users 
  bio on their pages.

  ______________________________________________________________________________

  To use this widget, you just need :
    - text

 */

class MyBioBox extends StatelessWidget {
  final String text;
  const MyBioBox({
    super.key,
    required this.text
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Theme.of(context).colorScheme.secondary,
      ),
      padding: const EdgeInsets.symmetric(horizontal:  10, vertical: 20),
      child: Text(text, style: TextStyle(color: Theme.of(context).colorScheme.primary),),
    );
  }
}