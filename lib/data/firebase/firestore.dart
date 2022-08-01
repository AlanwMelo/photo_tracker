import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class FirestoreManager {
  final _storageRef = FirebaseStorage.instance.ref();

  uploadImageAndGetURL(String postID, String imageID, String imagePath) async {
    final imageRef = _storageRef.child('posts/$postID/$imageID.jpg');
    try {
      await imageRef.putFile(File(imagePath));
      return imageRef.getDownloadURL();
    } catch (e) {
      print(e);
    }
  }
}
