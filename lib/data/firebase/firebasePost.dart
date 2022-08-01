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
}
