import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:photo_tracker/data/firebase/firestore.dart';
import 'package:photo_tracker/data/listItem.dart';

class FirebasePost {
  CollectionReference _posts = FirebaseFirestore.instance.collection('posts');

  getPostInfo(String postID) async {
    DocumentSnapshot thisPost = await _posts.doc(postID).get();

    return thisPost;
  }

  getNewPostId() {
    return _posts.doc();
  }

  getPostsForFeed() async {
    QuerySnapshot a = await _posts.get();
    return a.docs;
  }

  getPostImages(String postID) async {
    QuerySnapshot thisPostPictures =
        await _posts.doc(postID).collection('images').get();

    return thisPostPictures;
  }

  createPost({
    required List<String> collaborators,
    required String description,
    required String mainLocation,
    required String ownerID,
    required String title,
    required List<ListItem> thisPostPicturesList,
    required DocumentReference thisPost,
  }) async {
    CollectionReference thisPostPicturesCollection =
        _posts.doc(thisPost.id).collection('images');

    /// Create post
    thisPost.set({
      'collaborators': collaborators,
      'description': description,
      'mainLocation': mainLocation,
      'ownerID': ownerID,
      'postID': thisPost.id,
      'title': title,
      'created': DateTime.now()
    });

    /// Add post images
    for (var element in thisPostPicturesList) {
      DocumentReference postPicture = thisPostPicturesCollection.doc();

      String imgURL = await FirestoreManager().uploadImageAndGetURL(
          firestorePath: 'posts/${thisPost.id}/${postPicture.id}.jpg',
          imagePath: element.imgPath);

      postPicture.set({
        'firestorePath': imgURL,
        'imageID': postPicture.id,
        'latLong': GeoPoint(element.latLng.latitude, element.latLng.longitude),
        'locationError': element.locationError,
        'timeError': element.timeError,
        'timestamp': element.timestamp.millisecondsSinceEpoch,
        'locationText': 'Ainda nao'
      });
    }

    return true;
  }
}
