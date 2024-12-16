/*
  AUTHTNTICATION SERVICE

  This file handles the Authentication in Firebase
  ______________________________________________________________________

  - Login
  - Register
  - Logout
  - Delete Account (required if you want to publish to app store)

 */


import 'package:firebase_auth/firebase_auth.dart';
import 'package:twitter_clone_v/services/database/database_service.dart';

class MyAuthService {

  //get Firebase Auth instance
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // getters for current user and UId
  User? getCurrentUser() => _auth.currentUser;
  String getCurrentUserUid() => _auth.currentUser!.uid;

  String getFirebaseUid() => '${_auth.currentUser!.email!.split('@')[0]}_${_auth.currentUser!.uid}';

  // Login -> email & Password
  Future<UserCredential> loginEmailPassword({required String email, required String password}) async {
    // attempt login
    try{
      final userCredentials = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password
      );
    return userCredentials;
    } // catch any errors during login
    on FirebaseAuthException catch(e){
      print('Login Failed : ${e}');
      throw Exception(e.code);
    }
  }

  // new user register method
  Future<UserCredential> registerEmailPassword({required String email, required String password}) async {
    // attempt register
    try{
      final userCredentials = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password
      );
    return userCredentials;
    } // catch any errors during register
    on FirebaseAuthException catch(e){
      print('Registration Failed : ${e}');
      throw Exception(e.code);
    }
  }

  // Logout
  Future<void> logout() async {
    // attempt to logout
    try{
      _auth.signOut();
    } catch (e){
      print('Logout Failed : $e');
    }
  }

  // DELETE ACCOUNT
  Future<void> deleteAccount() async {
    // get the current user
    User? user = getCurrentUser();
    final String currentUserId = MyAuthService().getFirebaseUid();

    if (user != null){
      // delete the users data from the firestore
      await DatabaseService().deleteUserInfoFromFirebase(currentUserId: currentUserId);

      // delete the users auth record
      await user.delete();
    }
  }
}