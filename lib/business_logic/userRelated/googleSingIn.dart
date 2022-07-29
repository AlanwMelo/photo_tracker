import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:photo_tracker/classes/saveProfilePicture.dart';
import 'package:photo_tracker/db/dbManager.dart';

class TrackerGoogleSignIn {
  DBManager db = DBManager();

  Future<GoogleSignInAccount?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      String picPath = await SaveProfilePicture(googleUser?.photoUrl).savePicture();

      db.insertIntoUserInfo(googleUser?.displayName, googleUser?.email, picPath);

      await FirebaseAuth.instance.signInWithCredential(credential);
      return googleUser;
    } catch (error) {
      print(error);
      return null;
    }
  }
}
