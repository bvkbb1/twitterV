import 'package:flutter/material.dart';
import 'package:twitter_clone_v/components/drawer_tile.dart';
import 'package:twitter_clone_v/pages/profile_page.dart';
import 'package:twitter_clone_v/pages/settings_page.dart';
import 'package:twitter_clone_v/services/auth/auth_service.dart';

class MyDrawer extends StatelessWidget {
  MyDrawer({super.key});

  final _myAuthService = MyAuthService();

  void _onLogoutClicked() async {
    // startPreLoader(context);
    await _myAuthService.logout();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width,
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 50),
              child: Icon(Icons.person, size: 72, color: Theme.of(context).colorScheme.primary,),
            ),
        
            Divider(color: Theme.of(context).colorScheme.secondary),
            const SizedBox(height: 10,),
        
            MyDrawerTile(
              icon: const Icon(Icons.home),
              label: 'H O M E',
              onTap: (){
                Navigator.pop(context);
              }
            ),
            MyDrawerTile(
              icon: const Icon(Icons.person),
              label: 'P R O F I L E',
              onTap: () {
                Navigator.pop(context);

                // get the user id
                String uid = _myAuthService.getFirebaseUid();

                Navigator.push(context, MaterialPageRoute(builder: (context)=> ProfilePage(uid: uid,)));
              }
            ),
            MyDrawerTile(
              icon: const Icon(Icons.settings),
              label: 'S E T T I N G S',
              onTap: (){
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context)=> MySettings())
                );
              }
            ),

            const Spacer(),

            MyDrawerTile(
              icon: const Icon(Icons.logout),
              label: 'L O G O U T',
              onTap:_onLogoutClicked
            ),
          ]
        ),
      ),
    );
  }
}