import 'dart:async';
import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:photo_tracker/data/firebase/firestore.dart';
import 'package:photo_tracker/data/imageCompressor.dart';

class ProcessingFilesStream {
  StreamController<String> controller = StreamController<String>();
  ImageCompressor imageCompressor = ImageCompressor();
  FirestoreManager firestoreManager = FirestoreManager();
  late Stream stream;
  final queue = Queue<Map>();
  bool queueRunning = false;

  initStream() {
    stream = controller.stream.asBroadcastStream();
    stream.listen((event) {
      print('from stream $event');
    });
    return stream;
  }

  addToQueue(Map map) async {
    String newLocation;

    controller.add(map['fileToProcess']);
    if (map.toString().contains('fileToProcess')) {
      queue.add(map);
    }
    if (!queueRunning) {
      queueRunning = true;
      while (queue.isNotEmpty) {
        try {
          newLocation = await imageCompressor.compress(queue.first);
          await _uploadCompressedFile(queue.first, newLocation);
          queue.removeFirst();
          await Future.delayed(Duration(seconds: 2));
        } catch (e) {}
      }
      queueRunning = false;
    }
  }

  _uploadCompressedFile(Map map, String newLocation) async {
    CollectionReference thisPostPicturesCollection = FirebaseFirestore.instance
        .collection('posts')
        .doc(map['post'])
        .collection('images');

    DocumentReference postPicture = thisPostPicturesCollection.doc();

    String imgURL = await firestoreManager.uploadImageAndGetURL(
        firestorePath: 'posts/${map['post']}/${postPicture.id}.jpg',
        imagePath: newLocation);

    return imgURL;
  }
}
