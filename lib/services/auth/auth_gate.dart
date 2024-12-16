/* 
  AUTH GATE

  * This will check wheather the user logged in or not.

  -------------------------------------------------------------
  * If the user logged -> open Home PAGE
  * else -> open Login or Register page

*/


import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:twitter_clone_v/pages/home_page.dart';
import 'package:twitter_clone_v/services/auth/login_or_register.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData){
            return HomePage();
          } else{
            return LoginOrRegister();
          }
        },
      ),
    );
  }
}