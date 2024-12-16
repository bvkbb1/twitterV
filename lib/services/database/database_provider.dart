/*
  DATABASE PROVIDER
  This provider user to seperate the firestore data handling and the UI of our app.
    
    - The DatabaseService class is responsible for handling data the data FROM & TO the firebase DB.
    - The DatabaseProvider is responsible for processing the firebase data inorder to display in our UI.
  
  This class (DatabaseProvider) makes our code much modular, cleaner, easier to read and test.
  PArticularly, as the no. of pages increases, we need this provider to properly manage the 
  different states of the app.

  NOTE :
    - Also, if one day we decided to change the backend (from firebase to something else)
      then it's easier to manage and switch out different databases.
 */

import 'package:flutter/material.dart';
import 'package:twitter_clone_v/models/comments.dart';
import 'package:twitter_clone_v/models/post.dart';
import 'package:twitter_clone_v/models/user.dart';
import 'package:twitter_clone_v/services/auth/auth_service.dart';
import 'package:twitter_clone_v/services/database/database_service.dart';

class DatabaseProvider extends ChangeNotifier{
  /*
    SERVICES
   */

  // get the DB & auth services
  final _auth = MyAuthService();
  final _db = DatabaseService();

  /*
    USER PROFILE
   */
  // get the user profile based on the "uid"
  Future<UserProfile?> userProfile(uid) => _db.getUsersFromFirebaseByUid(firebaseUid: uid);


  // get all users from firebase service
  Future<List<UserProfile?>> getAllUsers() => _db.getAllUsersFromFirebase();

  Future<void> updateBio({required String bio}) async {
    try{
      await _db.updateUserBioInFirebase(bio: bio);
    } catch(e){
      print(e);
    }
  }


  /*
      POSTS


   */

  // local list of posts
  List<Post> _allPosts = [];
  List<Post> _followingPosts = [];


  // get posts
  List<Post> get allPosts => _allPosts;
  List<Post> get followingPosts => _followingPosts;

  // post message
  Future<void> postMessage({required String message}) async {
    // post message into firebase
    await _db.postMessageIntoFirebase(message: message);

    // load all the posts
    await loadAllPosts();
  }

  // fetch all posts
  Future<void> loadAllPosts() async {
    // get all posts from firebase
    final allPosts = await _db.getAllPostsFromFirebase();

    // get the blocked user ids
    final blockedUserIds = await _db.getBlockedUsersFromFirebase();

    // filter the blocked users posts
    final filteredPosts = allPosts.where((post) => !blockedUserIds.contains(post.uid)).toList();
      
    // update the local data variable
    // _allPosts = allPosts;
    _allPosts = filteredPosts;

    await loadFollowingPosts();

    // initialise/sync the local likes data with firebase data
    initialiseLikeMap();

    // update the UI
    notifyListeners();
  }

  // load all following posts
  Future<void> loadFollowingPosts() async {
    // get teh current user id
    final currentUserId = _auth.getFirebaseUid();

        // load for following posts
    //get following ids
    final followingUIds = await _db.getUsersFollowingUidsFromFirebase(userId: currentUserId);

    List<Post> followingPOsts = _allPosts.where((post)=> followingUIds.contains(post.uid)).toList();
    
    // update the variable
    _followingPosts = followingPOsts;

    // update UI
    notifyListeners();
  }


  // filter and return the posts given by database uid
  List<Post> getPostsByUid({required  String dbUid}) {
    return _allPosts.where((post) => post.uid == dbUid).toList();
  }

  // delete the post
  Future<void> deletePost({required String postId}) async {
    // delete the post from firebase
    await _db.deletePostFromFirebase(postId: postId);

    // reload the posts again
    await loadAllPosts();
  }


  /*
    LIKES SECTION
   */

  // local track to get the likes count for each post
  Map<String, int> _likesCounts = {};

  // local list to track posts liked by the current user
  List<String> _likedPosts = [];

  // does current user like this post?
  bool isPostLikedByCurrentUser({required String postId}) => _likedPosts.contains(postId);

  // get likes count of the post
  int getLikeCount({required String postId}) => _likesCounts[postId] ?? 0;


  // initialise like map locally
  void initialiseLikeMap(){
    // get the current user id
    final currentUserId = _auth.getFirebaseUid();

    // clear liked posts (NOTE : when new user signs in clear local data)
    _likedPosts.clear();

    // for each post get the likes data
    for (var post in _allPosts){
      // update like count map
      _likesCounts[post.id] = post.likesCount;

      // if the current user already liked this post
      if (post.likedBy.contains(currentUserId)){
        // add this post id to the local list
        _likedPosts.add(post.id);
      }
    }
  }


  // toggle like
  Future<void> toggleLike({required String postId}) async {
    /*
      initially update the local variable first, then in firebase.
      because, of feel and fast UI. we will update the UI optimistically, and revert back if anything
      goes wrong while writing to the database.
      Optimistically updating the local values like this is important because :
      reading and writing will takes some time (1-2 seconds, depending on the internet connection).
      So we don't want to give the user to slow lagged
     */

    // Store original values incase it fails
    final likedCountOriginal = _likesCounts;
    final likedPostsOriginal = _likedPosts;

    //perform like/unlike
    if (_likedPosts.contains(postId)){
      _likedPosts.remove(postId);
      _likesCounts[postId] = (_likesCounts[postId] ?? 0) - 1;
    }
    else{
      _likedPosts.add(postId);
      _likesCounts[postId] = (_likesCounts[postId] ?? 0) + 1;
    }

    //update the UI locally
    notifyListeners();

    /*
      Now try to update in firebase database
     */

    // try storing in database
    try{
      await _db.toggleLikeInFirebase(postId: postId);
    }
    // revert back to initial state if update fails
    catch (e){
      _likedPosts = likedPostsOriginal;
      _likesCounts = likedCountOriginal;

      // update ui
      notifyListeners();
    }
  }


  /*
    ------------  COMMENTS -----------------
   */

  // local list of comments
  final Map<String, List<Comment>> _comments = {};

  // getter for comments locally
  List<Comment> getComments({required String postId}) => _comments[postId] ?? <Comment>[];

  // fetch comments from the firebase for the respective post
  Future<void> loadAllComments({required String postId}) async {
    // get all comments
    final allComments = await _db.getAllComments(postId: postId);

    _comments[postId] = allComments;

    // update the UI
    notifyListeners();
  }


  // add comment
  Future<void> addComment({required String postId, required String message}) async {
    // add the comment
    await _db.addCommentInFirebase(postId: postId, message: message);

    // re-load all the comments
    await loadAllComments(postId: postId);
  }

  // delete comment
  Future<void> deleteComment({required String commentId, required String postId}) async {
    // delete the comment
    await _db.deleteCommentFromFirebase(commentId: commentId);

    // reload the comments
    await loadAllComments(postId: postId);
  }


  /*
    ----------------------------  ACCOUNT STUFF  -------------------------------
   */

  // local list of blocked users
  List<UserProfile> _blockedUsers = [];

  // getter for list of blocked users
  List<UserProfile> get blockedUsers => _blockedUsers;

  // load all the blocked users
  Future<void> loadBlockedUsers() async {
    // get the list of blocked users id's
    final blockedUsersIds = await _db.getBlockedUsersFromFirebase();

    // get the full users details using the UID
    final blockedUsersData = await Future.wait(
      blockedUsersIds.map((blockedUserId) => _db.getUsersFromFirebaseByUid(firebaseUid: blockedUserId))
    );

    List<UserProfile> blockedUsers = blockedUsersData.whereType<UserProfile>().toList();

    // assign to local variable
    _blockedUsers = blockedUsers;

    // Update UI
    notifyListeners();
  }

  // block the user
  Future<void> blockUser({required String userId}) async {
    // perform block in firebase
    await _db.blockUserInFirebase(userId: userId);

    // load blocked users
    await loadBlockedUsers();

    // reload the data
    await loadAllPosts();

    // and update the UI
    notifyListeners();
  }

  // unblock user
  Future<void> unblockUser({required String blockedUserId}) async {
    // perform unblock
    await _db.unblockUserInFirebase(blockedUserId: blockedUserId);

    // reload blocked users
    await loadBlockedUsers();

    // load all posts
    await loadAllPosts();

    // update UI
    notifyListeners();
  }


  /**
   * Report user and post
   */

  //
  Future<void> reportUser({required String postId, required String userId}) async {
    await _db.reportThePost(postId: postId, userId: userId);
  }




    /*
    ---------------------------------  FOLLOW and UNFOLLOW  --------------------------------

    Each user is should have list of:
      - followers uid's
      - following uid's

      Eg:
      {
        userId1 : [ list of user ids that are following/ followers ],
        userId2 : [ list of user ids that are following/ followers ],
        userId3 : [ list of user ids that are following/ followers ],
        userId4 : [ list of user ids that are following/ followers ],
        userId5 : [ list of user ids that are following/ followers ],
      }
   */

  // local variable for followers
  final Map<String, List<String>> _followers = {};
  final Map<String, List<String>> _following = {};
  final Map<String, dynamic> _followersCount = {};
  final Map<String, dynamic> _followingCount = {};

  // getters for count of : follower || following by given id
  int getFollowersCount({required String uid}) => _followersCount[uid] ?? 0;
  int getFollowingCount({required String uid}) => _followingCount[uid] ?? 0;

  

  // getter for list followers || following
  Map<String, List<String>> get followers => _followers;
  Map<String, List<String>> get following => _following;

  // load the followers
  Future<void> loadUserFollowers({required String userId}) async {
    // get the list of followers uids from firebase
    final listOfFollowersUids = await _db.getUsersFollowersUidsFromFirebase(userId: userId);
    _followers[userId] = listOfFollowersUids;
    _followersCount[userId] = listOfFollowersUids.length;

    // update UI
    notifyListeners();
  }

  //load following
  Future<void> loadUserFollowing({required String userId}) async {
    // get the list of followers uids from firebase
    final listOfFollowingUids = await _db.getUsersFollowingUidsFromFirebase(userId: userId);
    _following[userId] = listOfFollowingUids;
    _followingCount[userId] = listOfFollowingUids.length;

    // update UI
    notifyListeners();
  }

  // follow user
  Future<void> follow({required String targetUserId}) async {
    /*
      CURRENT LOGGEDIN USER WANTS OT FOLLOW THE TARGET USER
     */
    // get current user id
    final currentUserId = _auth.getFirebaseUid();

    // initialise with empty list id null
    _followers.putIfAbsent(currentUserId, () => []);
    _following.putIfAbsent(targetUserId, () => []);

    /*
      Optimistic UI changes :
        Update the local data and revert back if the database request fails

     */

    // follow if the current user is not one of the target user followers
    if (!_followers[targetUserId]!.contains(currentUserId)){
      // add the current user in target user followers list
      _followers[targetUserId]?.add(currentUserId);

      // update the follower count
      _followersCount[targetUserId] = (_followersCount[targetUserId] ?? 0) + 1;

      // then add target user in current user following list
      _following[currentUserId]?.add(targetUserId);

      // ipdate tghe following count
      _followingCount[currentUserId] = (_followersCount[targetUserId] ?? 0) + 1;

    }

    // update UI
    notifyListeners();


    /*
      UI HAS BEEN OPTIMISTICALLY UPDATED above with local data.
      Now let's try to make this request to our database
     */

    try{
      // follow the user in firebase
      await _db.followUserInFirebase(targetUserId: targetUserId);

      // reload current users followers
      await loadUserFollowers(userId: currentUserId);

      // reload current users following
      await loadUserFollowing(userId: currentUserId);
    }

    // any errors during following
    catch (e){
      // remove the current user from the target user followers
      _followers[targetUserId]?.remove(currentUserId);

      // update follower count
      _followersCount[targetUserId] = (_followersCount[targetUserId] ?? 0) - 1;

      //remove from current users following
      _following[currentUserId]?.remove(targetUserId);

      // update following count
      _followingCount[currentUserId] = (_followingCount[currentUserId] ?? 0) - 1;

      // update UI
      notifyListeners();
    }
  }

  // unfollow user
  Future<void> unFollow({required String targetUserId}) async {
    // await _db.followUserInFirebase(targetUserId: toUnFollowUserId);
    /*
      Current user wants to unfolloe the target user
     */

    // get current user id
    final currentFirebaseUserId = _auth.getFirebaseUid();

    // initialise list if doesnot exists
    _followers.putIfAbsent(currentFirebaseUserId, () => []);
    _following.putIfAbsent(targetUserId, () => []);


    /*
      OPTIMISTIC UI changes
        Update the local data first & revert back if database request fails
     */

    // unfollow if current user one of the target user's following
    if (_followers[targetUserId]!.contains(currentFirebaseUserId)){
      // remove current user from target user 's following collection
        _followers[targetUserId]?.remove(currentFirebaseUserId);

      // update follower's count
      _followersCount[targetUserId] = (_followersCount[targetUserId] ?? 1) - 1;

      // remove the target user from current user's following list
      _following[currentFirebaseUserId]?.remove(targetUserId);

      // update following count
      _followingCount[currentFirebaseUserId] = (_followersCount[targetUserId] ?? 1) - 1;

      print(_followersCount[targetUserId]);

    }

    // update UI
    notifyListeners();

    /*
      UI is updating optimistically with the local data above
      Now let's try make this request with the database
     */

    try{
      // unfollow the target user in firebase
      await _db.unfollowTheUserInFirebase(targetUserId: targetUserId);

      // reload the users followers
      await loadUserFollowers(userId: currentFirebaseUserId);

      // reload users following
      await loadUserFollowing(userId: currentFirebaseUserId);
    }

    catch(e){
      print(e);
      // if firebase request fails revert the local data
      // add current user in target users followers
      _followers[targetUserId]?.add(currentFirebaseUserId);

      // update follower count
      _followersCount[targetUserId] = (_followersCount[targetUserId] ?? 0) + 1;

      // add target user back into current user following
      _following[currentFirebaseUserId]?.add(targetUserId);

      // update following count
      _followingCount[currentFirebaseUserId] = (_followingCount[currentFirebaseUserId] ?? 0) + 1;

      // update UI
      notifyListeners();
    }
  }

  //  is current user following the target user
  bool isFollowing(String firebaseUid){
    // get the current user if
    final currentUserId = _auth.getFirebaseUid();

    // return the
    return _followers[firebaseUid]?.contains(currentUserId) ?? false;
  }

  /*
    MAP OF PROFILES
    for a given UID

    - list of followers
    - lost of following
   */

  final Map<String, List<UserProfile>> _followersProfile = {};
  final Map<String, List<UserProfile>> _followingProfile = {};

  // get the list of follower for a given user
  List<UserProfile> getListOfFollowersProfile({required String uid})
    => _followersProfile[uid] ?? <UserProfile>[];

  List<UserProfile> getListOfFollowingProfile({required String uid})
    => _followingProfile[uid] ?? <UserProfile>[];


  // load followers profiles for a given uid
  Future<void> loadUserFollowerProfile({required String uid}) async {
    try {
      // get list of followers uid from firebase
      final followerIds = await _db.getUsersFollowersUidsFromFirebase(userId: uid);

      // create list of user profile
      List<UserProfile> followersProfiles = [];

      // go thu each follower id
      for (String followerId in followerIds){
        UserProfile? followerProfile =
          await _db.getUsersFromFirebaseByUid(firebaseUid: followerId);
        
        if (followerProfile != null){
          followersProfiles.add(followerProfile);
        }
      }

      // update local data
      _followersProfile[uid] = followersProfiles;

      // update UI
      notifyListeners();
    }

    catch (e){
      print(e);
    }
  }

  // load following profiles for the given UId
  Future<void> loadUserFollowingProfile({required String uid}) async {
    try {
      // get list of followers uid from firebase
      final followingIds = await _db.getUsersFollowingUidsFromFirebase(userId: uid);

      // create list of user profile
      List<UserProfile> followingProfiles = [];

      // go thu each follower id
      for (String followingId in followingIds){
        UserProfile? followerProfile =
          await _db.getUsersFromFirebaseByUid(firebaseUid: followingId);
        
        if (followerProfile != null){
          // add following
          followingProfiles.add(followerProfile);
        }
      }

      // update local data
      _followingProfile[uid] = followingProfiles;

      // update UI
      notifyListeners();
    }

    catch (e){
      print(e);
    }
  }


  /*
    SEARCH
   */

  List<UserProfile> _searchResult = <UserProfile>[];

  List<UserProfile> get searchResult => _searchResult;

  // method to search for a user
  Future<void> searchUser({required String searchString}) async {
    try{
      // search user in firebase
      final result = await _db.searchUserInFirebase(searchString: searchString);

      // update local data
      _searchResult = result;

      // update UI
      notifyListeners();
    }

    catch(e){
      print(e);
    }
  }
}