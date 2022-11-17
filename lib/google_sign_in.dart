import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:nextwatch/global.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GoogleSignInProvider extends ChangeNotifier {

  final googleSignIn = GoogleSignIn();

  GoogleSignInAccount? _user;

  GoogleSignInAccount get user => _user!;

  Future googleLogin() async {

    try {

      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) return;
      _user = googleUser;

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

    } catch (e) {
      print(e.toString());
    }

   notifyListeners();
  }

  Future logout() async {
    await googleSignIn.disconnect();
    FirebaseAuth.instance.signOut();
    uid = "";
    isMoviesLoaded = false;
    isDataLoaded = false;
  }

  Future deleteUser() async {

    try {

      var collection = FirebaseFirestore.instance.collection(uid);
      var snapshots = await collection.get();
      for (var doc in snapshots.docs) {
        await doc.reference.delete();
      }

      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
          accessToken: googleAuth.accessToken);

      await FirebaseAuth.instance.signInWithCredential(credential);

      await FirebaseAuth.instance.currentUser?.delete();

      await googleSignIn.disconnect();
      //await googleSignIn.signOut();


      uid = "";
      isMoviesLoaded = false;
      isDataLoaded = false;

    } catch (e) {
      print(e.toString());
    }

  }


}