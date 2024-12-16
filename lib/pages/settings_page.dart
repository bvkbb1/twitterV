import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter_clone_v/components/settings_tile.dart';
import 'package:twitter_clone_v/theming/theme_provider.dart';

import '../helper/navigate_pages.dart';

class MySettings extends StatefulWidget {
  const MySettings({super.key});

  @override
  State<MySettings> createState() => _MySettingsState();
}

class _MySettingsState extends State<MySettings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('S E T T I N G S', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),

      body: Column(
        children:[
          MySettingsTile(
            leading: 'Dark Mode',
            action: CupertinoSwitch(
              activeColor: Colors.green,
              value: Provider.of<MyThemeProvider>(context, listen: false).isDarkMode,
              onChanged: (value) => Provider.of<MyThemeProvider>(context, listen: false).toggleTheme()
            ),
          ),

          MySettingsTile(
            leading: 'Blocked Users',
            action: IconButton(
              onPressed: ()=> goToBlockedUsersPage(context: context),
              icon: const Icon(Icons.arrow_right))
          ),

          MySettingsTile(
            leading: 'Account Settings',
            action: IconButton(
              onPressed: ()=> goToAccountSettingsPage(context: context),
              icon: const Icon(Icons.arrow_right)
            )
          ),
        ]
      ),
    );
  }
}