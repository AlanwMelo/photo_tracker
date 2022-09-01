import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/src/file_picker_result.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_tracker/business_logic/posts/addPhotos/addPhotosListItem.dart';
import 'package:photo_tracker/business_logic/posts/addPhotos/getFilesFromPickerResult.dart';
import 'package:photo_tracker/business_logic/processingFilesStream.dart';
import 'package:photo_tracker/classes/filePicker.dart';
import 'package:photo_tracker/data/firebase/firebasePost.dart';
import 'package:photo_tracker/data/firebase/firestore.dart';
import 'package:photo_tracker/presentation/Widgets/appBar.dart';
import 'package:photo_tracker/presentation/Widgets/editPhotoListItem.dart';
import 'package:photo_tracker/presentation/Widgets/loadingCoverScreen.dart';
import 'package:photo_tracker/presentation/Widgets/trackerSimpleButton.dart';

class AddPhotosScreen extends StatefulWidget {
  final Function(List<AddPhotosListItem>) confirm;
  final ProcessingFilesStream processingFilesStream;
  final String postID;
  final List<AddPhotosListItem> receivedList;

  const AddPhotosScreen(
      {Key? key,
      required this.confirm,
      required this.processingFilesStream,
      required this.receivedList,
      required this.postID})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _AddPhotosScreen();
}

class _AddPhotosScreen extends State<AddPhotosScreen> {
  List<AddPhotosListItem> imagesList = [];
  List<AddPhotosListItem> filesToBeDeleted = [];
  FirestoreManager firestoreManager = FirestoreManager();
  FirebasePost firebasePost = FirebasePost();

  //late StreamSubscription stream;
  bool loading = false;
  bool processingFiles = false;

  @override
  void dispose() {
    //stream.cancel();
    super.dispose();
  }

  @override
  void initState() {
    imagesList = widget.receivedList;
    /*stream = widget.processingFilesStream.stream.listen((event) {
      String location = 'error';
      if (event.toString().contains('location')) {
        if (event['location'] != 'error') {
          GeoPoint geoPoint = event['location'];
          location =
              '${geoPoint.latitude.toStringAsFixed(8)}, ${geoPoint.longitude.toStringAsFixed(8)}';
        }
        var x =
            imagesList.indexWhere((element) => element.name == event['file']);
        try {
          imagesList[x] = AddPhotosListItem(
              name: imagesList[x].name,
              path: imagesList[x].path,
              location: location,
              processing: false,
              collaborator: imagesList[x].collaborator);
        } catch (e) {
          print(e);
        }
      }
    });*/
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _willPop(),
      child: Stack(
        children: [
          Scaffold(
            appBar: TrackerAppBar(
              mainScreen: false,
              implyLeading: false,
              title: '    Add Photos',
              appBarAction: _appBarAction(),
            ),
            body: _body(),
          ),
          loading ? LoadingCoverScreen() : Container(),
        ],
      ),
    );
  }

  _body() {
    return Container(
      color: Colors.blueGrey.withOpacity(0.15),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(child: _listView()),
          _bottomBar(),
        ],
      ),
    );
  }

  _listView() {
    return Container(
      child: ListView.builder(
          itemCount: imagesList.length,
          itemBuilder: (context, index) {
            return Container(
                margin: EdgeInsets.only(top: 2),
                child: GestureDetector(
                  onLongPress: () => _removeItemFromPost(index),
                  child: EditPhotoListItem(
                    fromFirebase: imagesList[index].fromFirebase,
                    user: FirebaseAuth.instance.currentUser!.uid,
                    imagePath: imagesList[index].path,
                    imageName: imagesList[index].name,
                    location: imagesList[index].location,
                    collaborator: imagesList[index].collaborator,
                    processing: imagesList[index].processing,
                    firebasePath: imagesList[index].firebasePath,
                    // name
                  ),
                ));
          }),
    );
  }

  _bottomBar() {
    return processingFiles
        ? Container(
            height: 45,
            width: MediaQuery.of(context).size.width,
            child: ElevatedButton(
              onPressed: () {},
              child: Text('Processando...'),
            ),
          )
        : Container(
            height: 45,
            width: MediaQuery.of(context).size.width,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  loading = true;
                });
                MyFilePicker(pickedFiles: (filePickerResult) async {
                  if (filePickerResult != null) {
                    _addImagesToList(filePickerResult);
                  } else {
                    loading = false;
                    setState(() {});
                  }
                }).pickFiles(allowMultiple: true);
              },
              child: Text('Add More'),
            ),
          );
  }

  _addImagesToList(FilePickerResult filePickerResult) async {
    List<AddPhotosListItem> result =
        await GetFilesFromPickerResult(filePickerResult)
            .getFilesPathAndNames(tempDir: widget.postID);
    for (var element in result) {
      if (!imagesList.any((e) => e.name == element.name)) {
        imagesList.add(element);
      }
    }
    setState(() {
      loading = false;
    });
  }

  Future<bool> _willPop() async {
    if (!processingFiles && !loading) {
      List<AddPhotosListItem> finalList = imagesList
          .where((element) => element.location != 'not processed')
          .toList();
      await widget.confirm(finalList);
      if (filesToBeDeleted.isNotEmpty) {
        try {
          firebasePost.deleteImages(filesToBeDeleted, post: widget.postID);
        } catch (e) {
          print('Erro ao deletar arquivos (add_photos 197): $e');
        }
      }
      return true;
    } else {
      return false;
    }
  }

  _removeItemFromPost(int index) {
    if (!processingFiles) {
      if (imagesList[index].location == 'not processed') {
        imagesList.removeAt(index);
      } else {
        filesToBeDeleted.add(imagesList[index]);
        imagesList.removeAt(index);
      }
    }
    setState(() {});
  }

  _appBarAction() {
    if (imagesList.isEmpty) {
      return Container();
    } else if (processingFiles) {
      return Container();
    } else if (imagesList
        .any((element) => element.location == 'not processed')) {
      return TrackerSimpleButton(
          text: 'Processar',
          pressed: (_) async {
            processingFiles = true;
            print('so funciona por causa desse print add_photos 230');

            for (var element in imagesList) {
              if (element.location == 'not processed') {
                int index =
                    imagesList.indexWhere((helper) => element == helper);
                imagesList[index] = AddPhotosListItem(
                    fromFirebase: false,
                    name: imagesList[index].name,
                    path: imagesList[index].path,
                    location: imagesList[index].location,
                    collaborator: imagesList[index].collaborator,
                    processing: true);
                setState(() {});

                DocumentReference postPicture = FirebaseFirestore.instance
                    .collection('posts')
                    .doc(widget.postID)
                    .collection('images')
                    .doc();

                List<String> imgURLs =
                    await firestoreManager.uploadImageAndGetURL(
                  imagePath: element.path,
                  firestorePath: 'posts/${widget.postID}/${postPicture.id}.jpg',
                );

                DocumentReference imageDoc =
                    await firebasePost.createImgDocument(imgURLs, postPicture,
                        element.name, element.collaborator);

                GeoPoint? geoPoint;
                bool? locationError;

                await imageDoc.get().then((value) {
                  geoPoint = value['latLong'];
                  locationError = value['locationError'];
                });

                imagesList[index] = AddPhotosListItem(
                    fromFirebase: false,
                    name: imagesList[index].name,
                    path: imagesList[index].path,
                    location: locationError!
                        ? 'error'
                        : '${geoPoint?.latitude.toStringAsFixed(6)}, ${geoPoint?.longitude.toStringAsFixed(6)}',
                    collaborator: imagesList[index].collaborator,
                    processing: false,
                    firebasePath: imageDoc.path);
                setState(() {});
              }
            }
            processingFiles = false;
            setState(() {});
          });
    } else {
      return TrackerSimpleButton(
          text: 'Confirmar',
          pressed: (_) async {
            if (await _willPop()) {
              Navigator.of(context).pop();
            }
          });
    }
  }
}
