import 'package:flutter/material.dart';
import 'package:twitter_clone_v/pages/login_page.dart';
import 'package:twitter_clone_v/pages/register_page.dart';

/*
  
  LOGIN OR REGISTER PAGE

  switching/toggling between login and register page

 */


class LoginOrRegister extends StatefulWidget {
  const LoginOrRegister({super.key});

  @override
  State<LoginOrRegister> createState() => _LoginOrRegisterState();
}

class _LoginOrRegisterState extends State<LoginOrRegister> {
  // initially, show login page
  bool isLoginPage = true;

  // toggle between login and register
  void togglePages(){
    setState(() {
      isLoginPage = !isLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return
    isLoginPage
      ? LoginPage(onPageSwitch: togglePages,) 
      : RegisterPage(onPageSwitch: togglePages,);
  }
}