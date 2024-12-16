import 'package:flutter/material.dart';

/*
  TEXT FIELD

  A box where the user can type into.
  ---------------------------------------------

  To use this widget you need :
  - text controller (to access what the user entered)
  - hint text (e.g. "Enter Password" )
  - obscure text (e.g. true hides the password)

*/

class MyTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  const MyTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
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
    );
  }
}