import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:photo_tracker/business_logic/posts/addPhotos/addPhotosListItem.dart';
import 'package:photo_tracker/business_logic/processingFilesStream.dart';
import 'package:photo_tracker/data/firebase/firestore.dart';
import 'package:http/http.dart' as http;

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

  getPostsFromProfile(String userID) async {
    QuerySnapshot posts =
        await _posts.where('ownerID', isEqualTo: userID).get();
    return posts.docs;
  }

  getPostImages(String postID) async {
    QuerySnapshot thisPostPictures = await _posts
        .doc(postID)
        .collection('images')
        .orderBy('timestamp')
        .get();

    return thisPostPictures;
  }

  createImgDocument(List imgURLs, DocumentReference postPicture,
      String fileName, String collaborator) async {
    final uri = Uri.parse(
        'https://us-central1-photo-tracker-fa162.cloudfunctions.net/readImageData');
    final body = {
      'image': imgURLs[1],
    };
    final jsonString = json.encode(body);

    final response = await http.post(uri, body: jsonString);
    var convertedResponse = jsonDecode(response.body);

    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(0);
    bool timeError = false;
    bool locationError = false;
    GeoPoint geoPoint = GeoPoint(0, 0);

    try {
      dateTime = DateTime.parse(convertedResponse['dateTime']);
    } catch (e) {
      timeError = true;
    }

    try {
      geoPoint = GeoPoint(
          convertedResponse['latitude'], convertedResponse['longitude']);
    } catch (e) {
      locationError = true;
    }

    await postPicture.set({
      'firestorePath': imgURLs[0],
      'imageID': postPicture.id,
      'latLong': geoPoint,
      'locationError': locationError,
      'timeError': timeError,
      'timestamp': dateTime,
      'collaborator': collaborator,
      'locationText': 'Ainda nao'
    });

    return postPicture;
  }

  setPostAsReady({required String post}) {
    DocumentReference doc = _posts.doc(post);
    doc.update({'postReady': true});
  }

  createPost({
    required List<String> collaborators,
    required String description,
    required String mainLocation,
    required String ownerID,
    required String title,
    required ProcessingFilesStream processingFiles,
    bool? updating,
    String? updatingID,
    DocumentReference? thisPost,
  }) async {
    if (updating != null && updating) {
      /// Update post
      await _posts.doc(updatingID).update({
        'collaborators': collaborators,
        'description': description,
        'mainLocation': mainLocation,
        'ownerID': ownerID,
        'title': title,
      });

      Map<String, dynamic> mapA = {"posting": true, "post": thisPost};
      processingFiles.addToQueue(mapA);
    } else {
      /// Create post
      await thisPost?.set({
        'collaborators': collaborators,
        'description': description,
        'mainLocation': mainLocation,
        'ownerID': ownerID,
        'postID': thisPost.id,
        'title': title,
        'created': DateTime.now(),
        'postReady': false
      });

      Map<String, dynamic> mapA = {"posting": true, "post": thisPost};
      processingFiles.addToQueue(mapA);
    }

    return true;
  }

  deletePost({required DocumentReference thisPost}) async {
    try {
      WriteBatch batch = FirebaseFirestore.instance.batch();
      QuerySnapshot imagesToDelete = await thisPost.collection('images').get();

      imagesToDelete.docs.forEach((image) {
        batch.delete(image.reference);
      });
      for (var image in imagesToDelete.docs) {
        await thisPost.collection('images').doc(image.id).delete();
      }
      await firestoreManager.deleteFolder('/posts/${thisPost.id}/');
      batch.delete(thisPost);

      batch.commit();
    } catch (e) {
      print(e);
    }
    return true;
  }

  deleteImages(List<AddPhotosListItem> images, {String? post}) {
    WriteBatch batch = FirebaseFirestore.instance.batch();

    images.forEach((image) {
      late DocumentReference doc;

      if (image.fromFirebase) {
        doc =
            FirebaseFirestore.instance.doc('posts/$post/images/${image.name}');
        batch.delete(doc);
      } else {
        doc = FirebaseFirestore.instance.doc(image.firebasePath!);
      }

      batch.delete(doc);
    });
    batch.commit();
    firestoreManager.deleteFiles(images: images, post: post);
  }
}
