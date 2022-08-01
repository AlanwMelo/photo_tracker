import 'package:cloud_firestore/cloud_firestore.dart';

class FirebasePost {
  CollectionReference _posts = FirebaseFirestore.instance.collection('posts');

  getPostInfo(String postID) async {
    DocumentSnapshot thisPost = await _posts.doc('9o78LZXmSJhYUMpBAFqm').get();
    QuerySnapshot thisPostPictures =
        await _posts.doc('9o78LZXmSJhYUMpBAFqm').collection('images').get();
    print(thisPost.data());
    thisPostPictures.docs.forEach((element) {
      print(element.data());
    });
  }

  getPostImages(String postID) async {
    QuerySnapshot thisPostPictures =
        await _posts.doc('9o78LZXmSJhYUMpBAFqm').collection('images').get();

    return thisPostPictures;
  }

  createPost({
    required List<String> collaborators,
    required String description,
    required String mainLocation,
    required String ownerID,
    required String title,
    required List thisPostPicturesList2,
  }) async {
    List thisPostPicturesList = [1, 2, 3, 4, 5];
    DocumentReference thisPost = _posts.doc();
    CollectionReference thisPostPicturesCollection =
        _posts.doc(thisPost.id).collection('images');

    /// Create post
    thisPost.set({
      'collaborators': collaborators,
      'description': description,
      'mainLocation': mainLocation,
      'ownerID': ownerID,
      'postID': thisPost.id,
      'title': title
    });

    /// Add post images
    for (var element in thisPostPicturesList) {
      DocumentReference postPicture = thisPostPicturesCollection.doc();

      postPicture.set({
        'firestorePath': 'aa',
        'imageID': postPicture.id,
        'latLong': '00',
        'locationError': false,
        'timeError': false,
        'timestamp': '000000854',
        'locationText': '000000854'
      });
    }

    return true;
  }
}
