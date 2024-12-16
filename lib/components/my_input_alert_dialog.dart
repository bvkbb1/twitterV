/*
  INPUT ALERT BOX

  This is an alert dialog box that has a text field where the user can type in.
  we will use htis for the things like editing bio,, posting a new message, etc
  ______________________________________________________________________________

  To use this widget you need
    - A text controller
    - a hint text
    - a function. (eg. to save bio())
    - a text for button label (e.g. "Save")


 */

import 'package:flutter/material.dart';

class MyInputAlertDialog extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final Function()? onClick;
  final String buttonLabel;
  const MyInputAlertDialog({
    super.key,
    required this.controller,
    required this.onClick,
    required this.buttonLabel,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10)
      ),
      content: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          fillColor: Theme.of(context).colorScheme.secondary,
          filled: true,
          hintStyle: TextStyle(
            color: Theme.of(context).colorScheme.primary
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
            enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.tertiary, // Primary color for enabled border
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary, // Primary color for focused border
              width: 2.0, // Optional: Make the border thicker when focused
            ),
          ),
        ),
        maxLength: 140,
        maxLines: 3,
      ),

      actions: [
        // cancel button
        TextButton(
          onPressed: (){
            // close the box
            Navigator.pop(context);
            // clear te controller
            controller.clear();
          },
          child: const Text('Cancel')
        ),

        // Yes button
        TextButton(
          onPressed: (){
            // close the box
            Navigator.pop(context);

            // update the bio
            onClick!();

            // clear the controller
            controller.clear();
          },
          child: Text(buttonLabel)
        )
      ],
    );
  }
}