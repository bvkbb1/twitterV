/*
  ACCOUNT SETTINGS PAGE
  This page contains various settings related to user user account
  - delete own account (this feature is required if you want to publish to production)
 */

import 'package:flutter/material.dart';
import 'package:twitter_clone_v/services/auth/auth_service.dart';

class AccountSettingsPage extends StatefulWidget {
  const AccountSettingsPage({super.key});

  @override
  State<AccountSettingsPage> createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends State<AccountSettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Settings'),
      ),

      body: Column(
        children: [
          GestureDetector(
            onTap: ()=> _confirmDeleteAlertBox(context),
            child: Card(
              color: Colors.red,
              child: ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Delete Account',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),)
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  // confirm the deletion
  void _confirmDeleteAlertBox(BuildContext context){
    showDialog(context: context, builder: (context){
      return AlertDialog(
        title: const Text('Delete Account!'),
        content: const Text('Are you sure, you want to Delete your Account Permanently?'),
        actions: [
          // cancel button
          TextButton(
            onPressed: (){
              _toPop();
            },
            child: const Text('Cancel')
          ),

          // report button
          TextButton(
            onPressed: () async {
              // repott the user
              await MyAuthService().deleteAccount();
              _toPop();
              // let the user know that successfully reported
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Deleted Account Success!'))
              );

              Navigator.pushNamedAndRemoveUntil(
                context,
                '/',
                (route)=> false
              );
            },
            child: const Text('Delete')
          )
        ],
      );
    });
  }

  void _toPop(){
    Navigator.pop(context);
  }
}