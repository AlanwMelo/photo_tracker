import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:photo_tracker/data/firebase/firestore.dart';
import 'package:photo_tracker/data/imageCompressor.dart';
import 'package:http/http.dart' as http;

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
          CollectionReference thisPostPicturesCollection = FirebaseFirestore
              .instance
              .collection('posts')
              .doc(map['post'])
              .collection('images');

          List<String> imgURLs;

          newLocation = await imageCompressor.compress(queue.first);
          imgURLs = await _uploadCompressedFile(
              queue.first, newLocation, thisPostPicturesCollection);
          createImgDocument(imgURLs, thisPostPicturesCollection);
          queue.removeFirst();
          await Future.delayed(Duration(seconds: 2));
        } catch (e) {}
      }
      queueRunning = false;
    }
  }

  _uploadCompressedFile(Map map, String newLocation,
      CollectionReference thisPostPicturesCollection) async {
    DocumentReference postPicture = thisPostPicturesCollection.doc();

    List<String> imgURL = await firestoreManager.uploadImageAndGetURL(
        firestorePath: 'posts/${map['post']}/${postPicture.id}.jpg',
        imagePath: newLocation);

    return imgURL;
  }

  createImgDocument(
      List imgURLs, CollectionReference thisPostPicturesCollection) async {
    DocumentReference postPicture = thisPostPicturesCollection.doc();
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

    postPicture.set({
      'firestorePath': imgURLs[0],
      'imageID': postPicture.id,
      'latLong': geoPoint,
      'locationError': locationError,
      'timeError': timeError,
      'timestamp': dateTime,
      'locationText': 'Ainda nao'
    });
  }
}
