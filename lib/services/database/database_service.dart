/*
  DATA BASE
  This class handles all the data from & to the firebase

  ______________________________________________________________

  - User Profile
  - Post message
  - Likes
  - Comments
  - Account Stuff (report / block / delete account)
  - Follow / Un-Follow
  - Search User

 */


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:twitter_clone_v/models/comments.dart';
import 'package:twitter_clone_v/models/post.dart';
import 'package:twitter_clone_v/models/user.dart';
import 'package:twitter_clone_v/services/auth/auth_service.dart';

class DatabaseService {
  // get instance of firebase database & Auth
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  final _myAuthService = MyAuthService();



  /*
    ------------------------------  USER PROFILE  ------------------------------


    whet a new user creates their account, we need to store that in the database,
    and when the logged in need to display the user data in the user profile secton
  */


  // save the user info
  Future<void> saveUserInfoInFirebase({
    required String name, required String email}) async {
    // get the current user
    String uid = _auth.currentUser!.uid;

    // extract userNAme from email
    String userName = email.split('@')[0];

    // build the user id
    String userId = userName+'_'+uid;


    // create user profile object
    UserProfile userProfile = UserProfile(
      uid: userId,
      name: name,
      email: email,
      userName: userName,
      bio: ''
    );

    // convert the user profile obj into a map
    final userMap = userProfile.toMap();

    // try store it into firebase
    try{
      await _db.collection('Users').doc(userId).set(userMap);
    }
    // catch any exceptions
    catch(e){
      print(e);
    }
  }

  // get the users data from firebase db
  Future<UserProfile?> getUsersFromFirebaseByUid({required String firebaseUid}) async {
    try{
      // get the user from firebase db
      DocumentSnapshot userDoc = await _db.collection('Users').doc(firebaseUid).get();

      // convert and return the User Profile object which is a model class
      return UserProfile.fromDocument(userDoc);
    } catch (e){
      print(e.toString());
      return null;
    }
  }

  // get the all users from firebase database
    Future<List<UserProfile?>> getAllUsersFromFirebase() async {
    try{
      // get the user from firebase db
      QuerySnapshot snapshot = await _db.collection('Users').get();

      List usersList = snapshot.docs;

      List<UserProfile> usersModelList = usersList.map<UserProfile>((user) => UserProfile.fromDocument(user)).toList();

      // convert and return the User Profile object which is a model class
      return usersModelList;
    } catch (e){
      print(e.toString());
      return <UserProfile>[];
    }
  }


  // update user bio
  Future<void> updateUserBioInFirebase({required String bio}) async {
    // get user id
    final String uid = MyAuthService().getFirebaseUid();

    // attempt to update in firebaswe
    try {
      await _db.collection('Users').doc(uid).update({'bio': bio});
    }
    catch (e){
      print(e);
    }
  }


  // delete user info from firebase
  Future<void> deleteUserInfoFromFirebase({required String currentUserId}) async {
    WriteBatch batch = _db.batch();

    // delete user document
    DocumentReference userDoc = _db.collection('Users').doc(currentUserId);
    batch.delete(userDoc);

    // delete user posts
    QuerySnapshot userPosts =
      await _db.collection('Posts').where('uid', isEqualTo: currentUserId).get();
    for (var post in userPosts.docs){
      batch.delete(post.reference);
    }

    // delete user comments
    QuerySnapshot userComments =
      await _db.collection('Comments').where('uid', isEqualTo: currentUserId).get();
    for (var comment in userComments.docs){
      batch.delete(comment.reference);
    }

    // delete likes
    QuerySnapshot allPosts = await _db.collection('Posts').get();

    for (QueryDocumentSnapshot post in allPosts.docs){
      Map<String, dynamic> postData = post.data() as Map<String, dynamic>;

      var likedBy = postData['likedBy'] as List<dynamic> ?? [];
      if (likedBy.contains(currentUserId)){
        batch.update(post.reference,{
          'likedBy': FieldValue.arrayRemove([currentUserId]),
          'likesCount': FieldValue.increment(-1)
        });
      }

    }

    // update follower & following records accordingly

    // commit batch
    await batch.commit();
  }





  /*
  ------------------------------------  POSTS ----------------------------------
        POST MESSAGE
        1) post a message
        2) delete the post
        3) get all posts from firebase
        4) get individual posts
   */

  // post a message
  Future<void> postMessageIntoFirebase({required String message}) async {
    try {
      // get the current uid
      String firebaseUid = _myAuthService.getFirebaseUid();

      // use this uid to get the user's profile
      UserProfile? user = await getUsersFromFirebaseByUid(firebaseUid: firebaseUid);

      // create a new post
      Post newPost = Post(
        id: '',
        uid: firebaseUid,
        name: user!.name,
        userName: user.userName,
        message: message,
        timeStamp: Timestamp.now(),
        likesCount: 0,
        likedBy: []
      );

      // convert the model class object into map
      Map<String, dynamic> newPostMap = newPost.toMap();

      // add to firebase
      await _db.collection('Posts').add(newPostMap);
    }

    // catch any errors
    catch (e){
      print(e);
    }
  }

  // get all posts from firebase
  Future<List<Post>> getAllPostsFromFirebase() async {
    // try getting the posts from firebase
    try{
      QuerySnapshot snapshot = await _db

        // go to collection
        .collection('Posts')

        // chronological order
        .orderBy('timeStamp', descending: true)
        .get();
      
      // return as a list of posts
      List<Post> allPosts = snapshot.docs.map(
        (doc) => Post.fromDocument(doc: doc))
        .whereType<Post>()
        .toList();
      return allPosts;
    } catch(e){
      print(e);
      return [];
    }
  }

  // delete the post
  Future<void> deletePostFromFirebase({required String postId}) async {
    // try deleting
    try{
      await _db
      .collection('Posts')
      .doc(postId)
      .delete();
    }
    catch (e){
      print(e);
    }
  }




  /*
    -------------------------------  LIKES  ------------------------------------
   */

  // when the user clicks on the like button,
  Future<void> toggleLikeInFirebase({required String postId}) async {
    try {
      // get the current uid
      final currentUserId = _myAuthService.getFirebaseUid();

      // go to document reference for this post
      DocumentReference postDoc = _db.collection('Posts').doc(postId);

      // execute like
      await _db.runTransaction((transaction) async {
        // Fetch the post data within the transaction
        DocumentSnapshot postSnapshot = await transaction.get(postDoc);

        if (!postSnapshot.exists) {
          throw Exception("Post does not exist");
        }

        // Get the current likes list and count
        List<String> likedBy = List<String>.from(postSnapshot.get('likedBy') ?? <String>[]);
        int currentLikesCount = postSnapshot.get('likesCount') ?? 0;

        // Check if the user has already liked the post
        bool hasLiked = likedBy.contains(currentUserId);

        // Update the likes list and count based on the user's action
        if (hasLiked) {
          likedBy.remove(currentUserId);
          currentLikesCount--;
        } else {
          likedBy.add(currentUserId);
          currentLikesCount++;
        }

        // Update the post document in Firestore
        transaction.update(postDoc, {
          'likesCount': currentLikesCount,
          'likedBy': likedBy,
        });
      });

      // await _db.runTransaction((transaction) async {
      //   // identify the post data and get it
      //   DocumentSnapshot postSnapshot = await transaction.get(postDoc);

      //   // get the likes list
      //   List<String> likedBy = List<String>.from(postSnapshot['likedBy'] ?? <String>[]);

      //   // get the likes count
      //   int currentLikesCount = postSnapshot['likesCount'];

      //   // if the user has't liked this post -> then allow to like it
      //   if (!likedBy.contains(currentUserId)){
      //     // add the user to likes list
      //     likedBy.add(currentUserId);

      //     // increment the likes count
      //     currentLikesCount++;
      //   }
      //   // if the user already liked this post, Unlike the post
      //   else {
      //     // add the user to likes list
      //     likedBy.remove(currentUserId);

      //     // increment the likes count
      //     currentLikesCount--;
      //   }

      //   // update in firebase
      //   transaction.update(
      //     postDoc, {
      //       'likesCount': currentLikesCount,
      //       'likedBy': likedBy
      //     }
      //   );
      // });
    }

    // catch any errors
    catch (e){
      print(e);
    }
  }
  
  


  /*
    -----------------------------  COMMENTS  -----------------------------------
   */

  // add a comment to the post
  Future<void> addCommentInFirebase({required String postId, required String message}) async {
    // try adding a comment
    try{
      // get the current user
      final String currentUserId = _myAuthService.getFirebaseUid();
      UserProfile? user = await getUsersFromFirebaseByUid(firebaseUid: currentUserId);

      // create a new comment
      Comment newComment = Comment(
        id: '',
        postId: postId,
        uid: user!.uid,
        name: user.name,
        userName: user.userName,
        message: message,
        timeStamp: Timestamp.now()
      );

      // convert comment to map
      Map<String, dynamic> newCommentMap = newComment.toMap();

      // add to the comment in Comments collection
      await _db.collection('Comments').add(newCommentMap);
    }
    

    // catch any errors
    catch(e){
      print(e);
    }
  }
  // delete the comment for the post

  Future<void> deleteCommentFromFirebase({required String commentId}) async {
    // try deleting the comment
    try{
      await _db.collection('Comments').doc(commentId).delete();
      // comment deleted success
    }
    // catch any errors during the deleting the comment
    catch(e){
      print(e);
    }
  }

  //fetch the comments for the respective post
  Future<List<Comment>> getAllComments({required String postId}) async {
    // try getting the all the comments from the firebase
    try{
      // get comments from the firebase
      QuerySnapshot snapshot = await _db.collection('Comments').where('postId', isEqualTo: postId).get();
      List<Comment> allComments = snapshot.docs.map<Comment>((commentDoc)=> Comment.fromDocument(commentDoc)).toList();
      return allComments;
    }

    catch(e){
      print(e);
      return <Comment>[];
    }
  }






  /*
    ------------------------------ ACCOUNT STUFF  ------------------------------

    These are the requiements if you wish to publish this app to app store!
   */

  // Repost the post
  Future<void> reportThePost({required String postId, required String userId}) async {
    // get the current userId
    final currentUserId = _myAuthService.getFirebaseUid();

    // create a report
    final report = {
      'reportBy' : currentUserId,
      'messageId' : postId,
      'messageOwnerId' : userId,
      'timeStamp': FieldValue.serverTimestamp()
    };

    // add post report to firebase
    await _db.collection('Reports').add(report);
  }

  // Block the user
  Future<void> blockUserInFirebase({required String userId}) async {
    // get the current user id
    final currentUserId = _myAuthService.getFirebaseUid();

    // add this user to the blocked list
    await _db.collection('Users')
    .doc(currentUserId)
    .collection('BlockedUsers')
    .doc(userId)
    .set({});
  }

  // Unblock the user
  Future<void> unblockUserInFirebase({required String blockedUserId}) async {
    // get the current user id
    final currentUserId = _myAuthService.getFirebaseUid();

    // add this user to the blocked list
    await _db.collection('Users')
    .doc(currentUserId)
    .collection('BlockedUsers')
    .doc(blockedUserId)
    .delete();
  }

  // get the list of blocked users
  Future<List<String>> getBlockedUsersFromFirebase() async {
    // get the current user id
    final currentUserId = _myAuthService.getFirebaseUid();

    final snapshot = await _db
      .collection('Users')
      .doc(currentUserId)
      .collection('BlockedUsers')
      .get();

    // return as a list
    List<String> blockedUsers = snapshot.docs.map((blockedUser) => blockedUser.id).toList();
    return blockedUsers;
  }



  /*
    FOLLOW / UNFOLLOW

    1. follow the user
    2. unfollow the user
    3. get the user's followers: list of uids
    4. get the user's following: list of uids
   */

  // 1. follow the user
  Future<void> followUserInFirebase({required String targetUserId}) async {
    // get the current user id
    final currentUserId = _myAuthService.getFirebaseUid();

    // add the target follower in current users Following collection
    await _db
      .collection('Users')
      .doc(currentUserId)
      .collection('Following')
      .doc(targetUserId)
      .set({});

    // add current user in target users followers collection
    await _db
      .collection('Users')
      .doc(targetUserId)
      .collection('Followers')
      .doc(currentUserId)
      .set({});
  }

  // 2. unfollow the user
  Future<void> unfollowTheUserInFirebase({required String targetUserId}) async {
    // delete the user from followers list of the current user
    // get the current users details/ firebase id
    final currentUserId = _myAuthService.getFirebaseUid();

    // remove the target user from the current user Following collection
    await _db
      .collection('Users')
      .doc(currentUserId)
      .collection('Following')
      .doc(targetUserId)
      .delete();

    // remove the current user from the target user Followers collection
    await _db
      .collection('Users')
      .doc(targetUserId)
      .collection('Followers')
      .doc(currentUserId)
      .delete();
  }

  //  3. get the user's followers: list of uids
  Future<List<String>> getUsersFollowersUidsFromFirebase({required String userId}) async {
    // get the followers from firebase
    final snapshot = await _db
      .collection('Users')
      .doc(userId)
      .collection('Followers')
      .get();
    
    final List<String> followersIdsList = snapshot.docs.map<String>((doc) => doc.id).toList();
    //return the list
    return followersIdsList;
  }

  // 4. get the user's following: list of uids
  Future<List<String>> getUsersFollowingUidsFromFirebase({required String userId}) async {

    // get the followers from firebase
    final snapshot = await _db
      .collection('Users')
      .doc(userId)
      .collection('Following')
      .get();
    
    final List<String> followingIdsList = snapshot.docs.map<String>((doc) => doc.id).toList();
    //return the list
    return followingIdsList;
  }



  /*
    SEARCH USERS
   */

  // Search user by name
  Future<List<UserProfile>> searchUserInFirebase({required String searchString}) async {
    try {
      QuerySnapshot snapshot = await _db
        .collection('Users')
        .where('userName', isGreaterThanOrEqualTo: searchString)
        .where('userName', isLessThanOrEqualTo: '${searchString}\uf8ff')
        .get();

      List<UserProfile> searchedUsersList =
        snapshot.docs.map<UserProfile>((user)=> UserProfile.fromDocument(user)).toList();

      // finally return the list
      return searchedUsersList;
    }

    catch (e){
      print(e);
      return <UserProfile>[];
    }
  }
}