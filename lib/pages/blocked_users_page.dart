/*
  BLOCKED USERS PAGE

  - this page displays the list of users that the user blocked.
  - you can unblock the users from here.

 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter_clone_v/services/database/database_provider.dart';

class BlockedUsersPage extends StatefulWidget {
  const BlockedUsersPage({super.key});

  @override
  State<BlockedUsersPage> createState() => _BlockedUsersPageState();
}

class _BlockedUsersPageState extends State<BlockedUsersPage> {

  // providers
  late final _listeningProvider =
    Provider.of<DatabaseProvider>(context);
  late final _dbProvider =
    Provider.of<DatabaseProvider>(context, listen: false);

  
  @override
  void initState(){
    super.initState();
  
    _loadBlockedUsers();
  }

  Future<void> _loadBlockedUsers() async {
    await _dbProvider.loadBlockedUsers();
  }

  // show unblock alert dialog
  void _showUnblockAlertBox(String blockedUserId){
    showDialog(
      context: context,
      builder: (context)=>
      AlertDialog(
        title: const Text('Unblock User'),
        content: const Text('Are you sure, you want to Unblock this User'),
        actions: [
          // cancel button
          TextButton(
            onPressed: (){
              _toPop();
            },
            child: const Text('Cancel')
          ),

          // Unblock button
          TextButton(
            onPressed: () async {
              // repott the user
              await _dbProvider.unblockUser(blockedUserId: blockedUserId);
              _toPop();

              // let the user know that successfully reported
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('User Unblocked!'))
              );

            },
            child: const Text('Unblock')
          )
        ],
      )
    );
  }

  void _toPop(){
    Navigator.pop(context);
  }


  @override
  Widget build(BuildContext context) {
    // get the list of blocked users from the listening
    final blockedUsers = _listeningProvider.blockedUsers;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blocked Users',),
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),

      body: blockedUsers.isEmpty
      ? const Center(
        child: Text('No blocked users found')
      )
      : ListView.builder(
        itemCount: blockedUsers.length,
        itemBuilder: (context, index) {
          // get the each blocked user
          final user = blockedUsers[index];

          return ListTile(
            title: Text(user.name),
            subtitle: Text('@${user.userName}'),
            trailing: IconButton(
              onPressed: () => _showUnblockAlertBox(user.uid),
              icon: const Icon(Icons.block)
            ),
          );
        }
      )
      ,

    );
  }
}