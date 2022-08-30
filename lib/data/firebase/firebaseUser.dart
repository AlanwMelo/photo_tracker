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

  getUserFollowers(String userID) async {
    QuerySnapshot thisUserFollowers =
        await _users.doc(userID).collection('followers').get();
    return thisUserFollowers;
  }

  getUserFollowing(String userID) async {
    QuerySnapshot thisUserFollowing =
        await _users.doc(userID).collection('following').get();
    return thisUserFollowing;
  }

  startFollowing({required String userID}) async {
    WriteBatch batch = FirebaseFirestore.instance.batch();

    if (await checkIfFollowingThisUSer(userID: userID) == false) {
      batch.set(
          _users
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .collection('following')
              .doc(),
          {'user': userID, 'date': DateTime.now()});

      batch.set(_users.doc(userID).collection('followers').doc(), {
        'user': FirebaseAuth.instance.currentUser!.uid,
        'date': DateTime.now()
      });
    }
    batch.commit();
  }

  stopFollowing({required String userID}) async {
    WriteBatch batch = FirebaseFirestore.instance.batch();

    if (await checkIfFollowingThisUSer(userID: userID)) {
      CollectionReference deleteFromFollowing = _users
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('following');

      CollectionReference deleteFromFollowers =
          _users.doc(userID).collection('followers');

      deleteFromFollowing.get().then((value) {
        value.docs.forEach((element) {
          if (element['user'] == userID) {
            batch.delete(deleteFromFollowing.doc(element.id));
          }
        });
      });

      deleteFromFollowers.get().then((value) {
        value.docs.forEach((element) {
          if (element['user'] == FirebaseAuth.instance.currentUser!.uid) {
            batch.delete(deleteFromFollowers.doc(element.id));
          }
        });
      });

      await Future.delayed(Duration(seconds: 2));
      batch.commit();
    }
  }

  checkIfFollowingThisUSer({required String userID}) async {
    bool result;

    QuerySnapshot userFollowers = await getUserFollowers(userID);
    int? followHelper = userFollowers.docs
        .where((element) =>
            element['user'] == FirebaseAuth.instance.currentUser!.uid)
        .length;

    followHelper > 0 ? result = true : result = false;

    return result;
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
