import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter_clone_v/components/user_list_tile.dart';
import 'package:twitter_clone_v/services/database/database_provider.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  // search text controller
  final _searchController = TextEditingController();



  @override
  Widget build(BuildContext context) {
    // provider
    final dbProvider = Provider.of<DatabaseProvider>(context, listen: false);
    final listeningProvider = Provider.of<DatabaseProvider>(context, listen: true);
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search here...',
            hintStyle: TextStyle(
              color: Theme.of(context).colorScheme.primary
            ),
            border: InputBorder.none
          ),

          onChanged: (value){
            // / search users
            if (value.isNotEmpty){
              dbProvider.searchUser(searchString: value);
            }else{
              dbProvider.searchUser(searchString: "");
            }
          },
        ),
      ),



      body: listeningProvider.searchResult.isEmpty
      ? 
      // handle no users found
      const Center(
        child: Text('No users found')
      )
      // handle found users
      :
      ListView.builder(
        itemCount: listeningProvider.searchResult.length,
        itemBuilder: (context, index){
          // get the each user
          final user = listeningProvider.searchResult[index];

          // return the user tile
          return MyUserTile(user: user);
        }
      )
      ,
    );
  }
}