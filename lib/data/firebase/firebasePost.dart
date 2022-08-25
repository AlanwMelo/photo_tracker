import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:photo_tracker/business_logic/processingFilesStream.dart';
import 'package:photo_tracker/data/firebase/firestore.dart';
import 'package:photo_tracker/data/listItem.dart';

class FirebasePost {
  CollectionReference _posts = FirebaseFirestore.instance.collection('posts');
  FirestoreManager firestoreManager = FirestoreManager();

  getPostInfo(String postID) async {
    DocumentSnapshot thisPost = await _posts.doc(postID).get();

    return thisPost;
  }

  getNewPostId() {
    return _posts.doc();
  }

  getPostsForFeed() async {
    QuerySnapshot posts =
        await _posts.orderBy('created', descending: true).get();
    return posts.docs;
  }

  getPostImages(String postID) async {
    QuerySnapshot thisPostPictures =
        await _posts.doc(postID).collection('images').get();

    return thisPostPictures;
  }

  createPost(
      {required List<String> collaborators,
      required String description,
      required String mainLocation,
      required String ownerID,
      required String title,
      required DocumentReference thisPost,
      required ProcessingFilesStream processingFiles}) async {
    Map<String, dynamic> mapA = {"posting": true};
    processingFiles.addToQueue(mapA);

    /// Create post
    await thisPost.set({
      'collaborators': collaborators,
      'description': description,
      'mainLocation': mainLocation,
      'ownerID': ownerID,
      'postID': thisPost.id,
      'title': title,
      'created': DateTime.now()
    });
    return true;
  }

  deletePost({required DocumentReference thisPost}) {
    print('lost id ${thisPost.id}');
    firestoreManager.deleteFolder('posts/${thisPost.id}/');
    thisPost.delete();
  }
}
