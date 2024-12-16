

/*
  All USERS

  This is the main page of the app: It displays the list of all posts.

 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter_clone_v/components/my_drawer.dart';
import 'package:twitter_clone_v/models/user.dart';
import 'package:twitter_clone_v/services/database/database_provider.dart';

class AllUsers extends StatefulWidget {
  const AllUsers({super.key});

  @override
  State<AllUsers> createState() => _AllUsersState();
}

class _AllUsersState extends State<AllUsers> {
  // instances of providers
  late final listeningDbProvider =
    Provider.of<DatabaseProvider>(context);
  late final _databaseProvider =
    Provider.of<DatabaseProvider>(context, listen: false);


  // on start up
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // let's load all the posts
    _loadAllPosts();
  }

  // load all the posts
  Future<void> _loadAllPosts() async {
    await _databaseProvider.getAllUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('H O M E', style: TextStyle(fontWeight: FontWeight.bold),),
        centerTitle: true,
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),
      drawer: MyDrawer(),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Text('hello'),
      ),
    );
  }


  // build posts list
  Widget _buildAllUsers({required List<UserProfile?> users}){
    return users.isEmpty
      ?
      // show the empty list
      const Center(
        child: Text("No posts Yet...!"),
      )

      :
      // if the post list is not empty
      ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          // get each individual post object
          final user = users[index];

          // return the my post tile
          return Card(
            child: Text(user!.name),
          );
        }
      );
  }
}