import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:photo_tracker/presentation/screens/homePage.dart';
import 'package:photo_tracker/presentation/screens/login/signIn.dart';

handleAuthState() {
  return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (BuildContext context, snapshot) {
        if (snapshot.hasData) {
          return TrackerHomePage(title: 'Photo Tracker');
        }
        else {
          return TrackerSignInPage();
        }
      });
}
