import 'package:flutter/material.dart';


void startPreLoader(BuildContext context){
    showDialog(
      context: context,
      builder: (context) => const AlertDialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        content: Center(child: CircularProgressIndicator()),
      )
    );
  }

  void stopPreLoader(BuildContext context) {
    Navigator.pop(context);
  }