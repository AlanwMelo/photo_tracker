import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class FirestoreManager {
  final Reference _storageRef = FirebaseStorage.instance.ref();

  uploadImageAndGetURL(
      {required String imagePath, required String firestorePath}) async {
    List<String> result = [];
    // firestorePath example: 'posts/${thisPost.id}/${postPicture.id}.jpg'

    final imageRef = _storageRef.child(firestorePath);
    try {
      await imageRef.putFile(File(imagePath));
      result = [await imageRef.getDownloadURL(), imageRef.fullPath];
      return result;
    } catch (e) {
      print(e);
    }
  }

  deleteFolder(String path) async {
    final folderRef = _storageRef.child(path);
    try {
      ListResult postItems = await folderRef.list();
      postItems.items.forEach((item) {
        item.delete();
      });
    } catch (e) {
      print(e);
    }
  }

  deleteFiles({required List<String> filesPaths}){

  }
}
