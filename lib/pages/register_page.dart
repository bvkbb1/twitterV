import 'package:flutter/material.dart';
import 'package:twitter_clone_v/components/my_button.dart';
import 'package:twitter_clone_v/components/my_pre_loader.dart';
import 'package:twitter_clone_v/components/my_text_field.dart';
import 'package:twitter_clone_v/components/show_dialog_with_message.dart';
import 'package:twitter_clone_v/services/auth/auth_service.dart';
import 'package:twitter_clone_v/services/database/database_service.dart';

/*
  REGISTER PAGE

  on this page, a new user can fill out form and create an account.
  The data will want from user as:

  - User name
  - email
  - paswsword
  - confirm password
  ----------------------------------------------

  Once the user successfully creates an account -> they will be redirected to home page

  Also, If the user already has an account , they can go to login page from here.

 */

class RegisterPage extends StatefulWidget {
  final Function()? onPageSwitch;
  const RegisterPage({
    super.key,
    required this.onPageSwitch
  });

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  // instance of my auth service
  final _auth = MyAuthService();
  final _db = DatabaseService();

  // controller for user entries
  final TextEditingController _userNameCOntroller = TextEditingController();
  final TextEditingController _emailCOntroller = TextEditingController();
  final TextEditingController _passwordCOntroller = TextEditingController();
  final TextEditingController _confirmPasswordCOntroller = TextEditingController();

  // this method is called when the user click on the register button
  void _onRegisterBtnClicked() async {

    // checking if the password & confirm passwords are same or not
    if (_passwordCOntroller.text == _confirmPasswordCOntroller.text){
      final String name = _userNameCOntroller.text.trim();
      final String email = _emailCOntroller.text.trim();
      final String password = _passwordCOntroller.text.trim();

      // start preloader
      startPreLoader(context);
      // try attempt to register
      try {
        await _auth.registerEmailPassword(
          email: email,
          password: password
        );

        // stop loading
        if (mounted) stopPreLoader(context);

        // after register success store the userDetails in firebase db
        _db.saveUserInfoInFirebase(name: name, email: email);
      } catch(e){

        // stop loading
        if (mounted) stopPreLoader(context);
        print(e);

        // show the error in dialog box
        if (mounted) showMsgDialog(context, e.toString());
      }
    } else{
      print('Password verification failed');
    }
    
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      // appBar: AppBar(
      // ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lock_open,
                    size: 80,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 35,),
              
                  Text(
                    'Welcom back, You have been missed...!',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16
                    ),
                  ),
                  const SizedBox(height: 30,),
              
                  MyTextField(
                    controller: _userNameCOntroller,
                    hintText: 'User Name',
                    obscureText: false
                  ),
                  const SizedBox(height: 15,),
              
                  MyTextField(
                    controller: _emailCOntroller,
                    hintText: 'Email',
                    obscureText: false
                  ),
                  const SizedBox(height: 15,),
              
                  MyTextField(
                    controller: _passwordCOntroller,
                    hintText: 'Password',
                    obscureText: true
                  ),
                  const SizedBox(height: 15,),
              
                  MyTextField(
                    controller: _confirmPasswordCOntroller,
                    hintText: 'Confirm Password',
                    obscureText: true
                  ),
                  const SizedBox(height: 15,),
              
                  // Align(
                  //   alignment: Alignment.centerRight,
                  //   child: Text(
                  //     'Forgot Password?',
                  //     style: TextStyle(
                  //       color: Theme.of(context).colorScheme.primary,
                  //       fontWeight: FontWeight.bold
                  //     ),
                  //   ),
                  // ),
                  // const SizedBox(height: 15,),
              
                  MyButton(onTap: _onRegisterBtnClicked, label: 'Register'),
                  const SizedBox(height: 15,),
              
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already a member!',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          // fontWeight: FontWeight.bold
                        ),
                      ),
                      const SizedBox(width: 5,),
                      GestureDetector(
                        onTap: widget.onPageSwitch!,
                        child: Text(
                          'Login Now',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                    ],
                  ),
                ]
              ),
            ),
          ),
        ),
      ),
    );
  }
}