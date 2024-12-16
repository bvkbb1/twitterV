/*
  FOLLOW LIST PAGE

  This page displays the tab bar for
  - a list of followers
  - a list of following
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter_clone_v/components/user_list_tile.dart';
import 'package:twitter_clone_v/models/user.dart';
import 'package:twitter_clone_v/services/database/database_provider.dart';

class FollowListPage extends StatefulWidget {
  final String uid;
  const FollowListPage({
    super.key,
    required this.uid
  });

  @override
  State<FollowListPage> createState() => _FollowListPageState();
}

class _FollowListPageState extends State<FollowListPage> {

  // providers
  late final _listeningProvider = Provider.of<DatabaseProvider>(context);
  late final _dbProvider = Provider.of<DatabaseProvider>(context, listen: false);

  // on startup
  @override
  void initState(){
    super.initState();
  
    // load follower list
    _loadFollowersList();

    // load following list
    _loadFollowingList();
  }

  // load followers list initially
  Future<void> _loadFollowersList() async {
    await _dbProvider.loadUserFollowerProfile(uid : widget.uid);
  }

  // load following list initially
  Future<void> _loadFollowingList() async {
    await _dbProvider.loadUserFollowingProfile(uid: widget.uid);
  }

  


  @override
  Widget build(BuildContext context) {

    // get the folowers list
    final followers = _listeningProvider.getListOfFollowersProfile(uid: widget.uid);
    final following = _listeningProvider.getListOfFollowingProfile(uid: widget.uid);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            dividerColor: Colors.transparent,
            labelColor: Theme.of(context).colorScheme.inversePrimary,
            unselectedLabelColor: Theme.of(context).colorScheme.primary,
            indicatorColor: Theme.of(context).colorScheme.primary,
            tabs: [
              Tab(text: 'Following',),
              Tab(text: 'Followers',),
            ]
          ),
        ),

        body: TabBarView(
          children: [
            _buildUsersList(following, 'No Following found'),
            _buildUsersList(followers, 'No Followers found'),
            
          ]
        ),
      )
    );
  }

  Widget _buildUsersList(List<UserProfile> userList, String emptyMessage){
    return userList.isEmpty
    ?
    // return empty message
    Center(
      child: Text(emptyMessage),
    )

    // return the list
    : ListView.builder(
      itemCount: userList.length,
      itemBuilder: (context, index){
        // get the user
        final user = userList[index];

        // returnthe user list tile
        return MyUserTile(user: user);
      }
    )
    ;
  }
}