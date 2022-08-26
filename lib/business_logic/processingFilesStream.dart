import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:photo_tracker/data/firebase/firebasePost.dart';
import 'package:photo_tracker/data/firebase/firestore.dart';
import 'package:photo_tracker/data/imageCompressor.dart';
import 'package:http/http.dart' as http;

class ProcessingFilesStream {
  StreamController<Map> controller = StreamController<Map>();
  ImageCompressor imageCompressor = ImageCompressor();
  FirestoreManager firestoreManager = FirestoreManager();
  FirebasePost firebasePost = FirebasePost();
  late Stream stream;
  final queue = Queue<Map>();
  bool queueRunning = false;

  initStream() {
    stream = controller.stream.asBroadcastStream();
    return stream;
  }

  getStream() {
    return stream;
  }

  addToStream(Map map) {
    controller.add(map);
  }

  addToQueue(Map map) async {
    bool fileToProcess = map.toString().contains('fileToProcess');
    bool posting = map.toString().contains('posting');
    bool deletePost = map.toString().contains('deletePost');
    bool deleteFiles = map.toString().contains('filesToBeDeleted');

    if (deletePost || deleteFiles) {
      while (queueRunning) {
        await Future.delayed(Duration(seconds: 2));
      }
      queue.add(map);
    }
    if (fileToProcess || posting) {
      queue.add(map);
    }
    if (!queueRunning) {
      queueRunning = true;

      while (queue.isNotEmpty) {
        if (deletePost) {
          await firebasePost.deletePost(thisPost: map['deletePost']);
        }
        if(deleteFiles){
          firebasePost.deleteImages(queue.first['filesToBeDeleted']);
        }
        if (fileToProcess) {
          try {
            Map<String, dynamic> processMap = {
              "processingFile": queue.first['fileName'],
              "posting": true,
              "post": queue.first['post']
            };

            controller.add(processMap);
            CollectionReference thisPostPicturesCollection = FirebaseFirestore
                .instance
                .collection('posts')
                .doc(processMap['post'])
                .collection('images');

            List<String> imgURLs;
            imgURLs = await uploadCompressedFile(
                queue.first, queue.first['fileToProcess'], thisPostPicturesCollection);
            await createImgDocument(imgURLs, thisPostPicturesCollection,
                queue.first['fileName'], queue.first['collaborator']);
          } catch (e) {}
        }
        queue.removeFirst();
      }
      try {
        firebasePost.setPostAsReady(post: map['post'].id);
      } catch (e) {
        print(e);
      }

      Map<String, dynamic> conclusionMap = {"posting": false};
      controller.add(conclusionMap);
      queueRunning = false;
    }
  }

  uploadCompressedFile(Map map, String newLocation,
      CollectionReference thisPostPicturesCollection) async {
    DocumentReference postPicture = thisPostPicturesCollection.doc();

    List<String> imgURL = await firestoreManager.uploadImageAndGetURL(
        firestorePath: 'posts/${map['post']}/${postPicture.id}.jpg',
        imagePath: newLocation);

    return imgURL;
  }

  createImgDocument(
      List imgURLs,
      CollectionReference thisPostPicturesCollection,
      String fileName,
      String collaborator) async {
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
      Map<String, dynamic> map = {"location": geoPoint, "file": fileName};
      addToStream(map);
    } catch (e) {
      Map<String, dynamic> map = {"location": "error", "file": fileName};
      addToStream(map);
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

    return true;
  }
}
