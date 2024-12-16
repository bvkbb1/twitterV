import 'package:flutter/material.dart';
import 'package:twitter_clone_v/components/my_button.dart';
import 'package:twitter_clone_v/components/my_pre_loader.dart';
import 'package:twitter_clone_v/components/my_text_field.dart';
import 'package:twitter_clone_v/services/auth/auth_service.dart';

import '../components/show_dialog_with_message.dart';

class LoginPage extends StatefulWidget {
  final Function()? onPageSwitch;
  const LoginPage({
    super.key,
    required this.onPageSwitch
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  // get the my auth service class instance
  final _myAuthService = MyAuthService();

  // controllers for login credentials
  final TextEditingController _emailCOntroller = TextEditingController();
  final TextEditingController _passwordCOntroller = TextEditingController();

  void _login() async {

    if (_emailCOntroller.text.isNotEmpty && _passwordCOntroller.text.isNotEmpty){
      // start the preloader
      startPreLoader(context);
      try {
        // try to login
        await _myAuthService.loginEmailPassword(
          email: _emailCOntroller.text.trim(),
          password: _passwordCOntroller.text.trim()
        );
        
        // stop the pre loader
        if (mounted) {
          stopPreLoader(context);
        }
      } catch (e){
        // stop the pre loader
        if (mounted) stopPreLoader(context);
        print(e);
        if (mounted) showMsgDialog(context, e.toString());
      }
    } else{
      if (mounted) showMsgDialog(context, 'Credentials should not be empty');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
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
              
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                  const SizedBox(height: 15,),
              
                  MyButton(
                    onTap: _login,
                    label: 'Login'
                  ),
                  const SizedBox(height: 15,),
              
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Not a member?',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          // fontWeight: FontWeight.bold
                        ),
                      ),
                      const SizedBox(width: 5,),
                      GestureDetector(
                        onTap: (){
                          widget.onPageSwitch!();
                          // Navigator.push(context, MaterialPageRoute(builder: (context)=> RegisterPage()));
                        },
                        child: Text(
                          'Register Now',
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