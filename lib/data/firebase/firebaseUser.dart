import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseUser {
  CollectionReference _users = FirebaseFirestore.instance.collection('users');

  createUser(String? userName, String? userEmail, String? profilePicURL) async {
    String? userID = FirebaseAuth.instance.currentUser?.uid;

    bool userAlreadyCreated = await checkIfUserExistsByID(userID);

    if (!userAlreadyCreated) {
      await _users.doc(userID).set({
        'name': userName,
        'email': userEmail,
        'userID': userID,
        'userBio': '',
        'profilePicURL': profilePicURL
      });
    }

    return true;
  }

  getUserInfo(String userID) async {
    DocumentSnapshot thisUser = await _users.doc(userID).get();
    return thisUser;
  }

  checkIfUserExistsByID(String? userID) async {
    DocumentSnapshot user = await _users.doc(userID).get();

    return user.exists;
  }

  getUserInfoByEmail(String? userEmail) async {
    QuerySnapshot userWithThisEmail =
        await _users.where("email", isEqualTo: userEmail).get();

    for (var user in userWithThisEmail.docs) {
      print(user.data());
    }
    return userWithThisEmail.docs.length == 0 ? false : true;
  }
}
