import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:photo_tracker/business_logic/blocs/loadingCoverScreen/loadingCoverScreenBloc.dart';
import 'package:photo_tracker/business_logic/blocs/loadingCoverScreen/loadingCoverScreenEvent.dart';
import 'package:photo_tracker/data/saveProfilePicture.dart';
import 'package:photo_tracker/data/firebase/firebaseUser.dart';
import 'package:photo_tracker/db/dbManager.dart';

class TrackerGoogleSignIn {
  final BuildContext context;
  DBManager db = DBManager();

  TrackerGoogleSignIn(this.context);

  Future<GoogleSignInAccount?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      String picPath =
          await SaveProfilePicture(googleUser?.photoUrl).savePicture();

      await FirebaseAuth.instance.signInWithCredential(credential);

      db.insertIntoUserInfo(googleUser?.displayName, googleUser?.email, picPath,
          FirebaseAuth.instance.currentUser!.uid);

      /// Create firebase user based on user google info
      await FirebaseUser().createUser(
          googleUser?.displayName, googleUser?.email, googleUser?.photoUrl);

      return googleUser;
    } catch (error) {
      print(error);
      return null;
    }
  }
}
