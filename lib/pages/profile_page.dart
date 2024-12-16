import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter_clone_v/components/my_bio_box.dart';
import 'package:twitter_clone_v/components/my_follow_button.dart';
import 'package:twitter_clone_v/components/my_input_alert_dialog.dart';
import 'package:twitter_clone_v/components/my_post_tile.dart';
import 'package:twitter_clone_v/components/my_profile_status.dart';
import 'package:twitter_clone_v/models/user.dart';
import 'package:twitter_clone_v/services/auth/auth_service.dart';
import 'package:twitter_clone_v/services/database/database_provider.dart';

import '../helper/navigate_pages.dart';
import 'follow_list_page.dart';

/*
  PROFILE PAGE
  This is a profile page
 */


class ProfilePage extends StatefulWidget {
  // user id
  final String uid;
  const ProfilePage({
    super.key,
    required this.uid
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // get the services instance
  final _auth = MyAuthService();
  //get the database provider instance
  late final _listeningProvider =
      Provider.of<DatabaseProvider>(context);
  late final _databaseProvider =
      Provider.of<DatabaseProvider>(context, listen: false);

  // controller for bio editing
  final _bioController = TextEditingController();

  // user info
  UserProfile? user;
  final String _currentUserId = MyAuthService().getCurrentUserUid();

  final String _currentFirebaseUserId = MyAuthService().getFirebaseUid();

  // loading...?
  bool _isLoading = true;
  // if following
  bool _isFollowing = false;

  // on startup
  @override
  void initState() {
    super.initState();

    // load the user details
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    // get the user profile info
    user = await _databaseProvider.userProfile(widget.uid);

    // load followers and following
    await _databaseProvider.loadUserFollowers(userId: widget.uid);
    await _databaseProvider.loadUserFollowing(userId: widget.uid);


    _isFollowing = _databaseProvider.isFollowing(widget.uid);


    // finish loading
    if(mounted)
    setState(() {
      _isLoading = false;
    });
  }

  // bio dialog
  void _showDioDialog(){
    showDialog(context: context, builder: (context){
      return MyInputAlertDialog(
        controller: _bioController,
        hintText: 'Empty Bio...',
        buttonLabel: 'Save',
        onClick: () => _saveBio(),
      );
    });
  }

  // save update
  Future<void> _saveBio() async {
    // start loading
    setState(() {
      _isLoading = true;
    });

    // update the bio
    await _databaseProvider.updateBio(bio: _bioController.text);

    // reload the user
    await _loadUserInfo();

    setState(() {
      _isLoading = false;
    });

    print('saving....!');
  }

  // toggle ethod for follow/unfollw button
  Future<void> _toggleFollow() async {
    // unfollw
    if (_isFollowing){
      showDialog(
        context: context,
        builder: (context){
          return  AlertDialog(
            title: Text('Unfollw'),
            content: Text('Are youn sure you want to unfollow?'),
            actions: [
              // cancel the operation
              TextButton(
                onPressed: (){
                  Navigator.pop(context);
                },
                child: Text('Cancel'),
              ),

              // do the action
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await _databaseProvider.unFollow(targetUserId: widget.uid);
                },
                child: Text('Yes'),
              )
            ],
          );
        }
      );
    }

    // else follow the user
    else{
      await _databaseProvider.follow(targetUserId: widget.uid);
    }

    // update the following state
    if (mounted)
    setState(() {
      _isFollowing = !_isFollowing;
    });
  }

  @override
  Widget build(BuildContext context) {

    // get the all the posts based on the uid
    // these posts will bo shown in the user profile section
    final myPosts = _listeningProvider.getPostsByUid(dbUid: widget.uid);

    // listen the following & followers count
    final followingCount = _listeningProvider.getFollowingCount(uid: widget.uid);
    final folowersCount = _listeningProvider.getFollowersCount(uid: widget.uid);


    // listen the is following and update accordingly
    _isFollowing = _listeningProvider.isFollowing(widget.uid);
    

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text( _isLoading ? '' : user!.userName),
        foregroundColor: Theme.of(context).colorScheme.primary,

        leading: IconButton(onPressed: ()=> toToHomePage(context: context), icon: Icon(Icons.arrow_back)),

      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // user name handle
            Text(
              _isLoading ? '' : '@${user!.userName}',
              style: TextStyle(color: Theme.of(context).colorScheme.primary,),
            ),
        
            const SizedBox(height: 10,),
        
            // profile picture
            // we will display the user profile photo later
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(25)
              ),
              child: Icon(Icons.person, size: 70, color: Theme.of(context).colorScheme.primary,),
            ),
            const SizedBox(height: 10,),
        
        
            // profile status -> no. of followers / posts / following
            if (!_isLoading)
            MyProfileStatus(
              postCount: myPosts.length,
              followingCount: followingCount,
              folowersCount: folowersCount,
              onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (context)=> FollowListPage(uid: widget.uid,))),
            ),

            const SizedBox(height: 10,),

        
            // follow / unfollow button
            if (user != null && user!.uid != _currentFirebaseUserId)
            MyFollowButton(onTapped: _toggleFollow, isFollowing: _isFollowing),
        
            // bio section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // bio text
                Text('Bio', style: TextStyle(color: Theme.of(context).colorScheme.primary),),

                // bio update button
                if (user != null && user!.uid == _currentFirebaseUserId)
                GestureDetector(
                  onTap: () => _showDioDialog(),
                  child: Icon(Icons.settings, color: Theme.of(context).colorScheme.primary,)
                )
              ]
            ),
            
            const SizedBox(height: 10,),
            // MyBioBox(text: user!.bio),
            MyBioBox(text: _isLoading ?  '' : user!.bio.isNotEmpty ? user!.bio : "Bio not updated yet...!"),
            const SizedBox(height: 10,),


            // my posts starts
            Row(
              children: [
                const Text('My Posts'),
              ],
            ),
        
            // list of posts from user
            myPosts.isEmpty
            ?
            // display empty data
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.sentiment_dissatisfied,
                      color: Theme.of(context).colorScheme.primary,
                      size: 50,
                    ),
                    Text(
                      'No Posts yet...!',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 18
                      ),
                    ),
                  ],
                ),
              ),
            )
            :
            // display the user posts
            Expanded(
              child: ListView.builder(
                itemCount: myPosts.length,
                itemBuilder: (context, index) {
                  // get the each post
                  final post = myPosts[index];
                  return MyPostTile(
                    post: post,
                    onUserTap: (){},
                    onPostTap: (){},
                  );
                }
                ,
              ),
            )
          ],
        ),
      ),
    );
  }
}