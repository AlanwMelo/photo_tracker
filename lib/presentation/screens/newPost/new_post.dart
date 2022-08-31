import 'dart:convert';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:photo_tracker/business_logic/posts/addPhotos/addPhotosListItem.dart';
import 'package:photo_tracker/business_logic/processingFilesStream.dart';
import 'package:photo_tracker/data/firebase/firebasePost.dart';
import 'package:photo_tracker/presentation/Widgets/appBar.dart';
import 'package:photo_tracker/presentation/Widgets/trackerSimpleButton.dart';
import 'package:photo_tracker/presentation/screens/newPost/add_photos.dart';

class NewPost extends StatefulWidget {
  final ProcessingFilesStream processingFilesStream;
  final String? postID;

  NewPost({required this.processingFilesStream, this.postID});

  @override
  State<StatefulWidget> createState() => _NewPostState();
}

class _NewPostState extends State<NewPost> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  List<AddPhotosListItem> imagesList = [];
  String title = 'New Post';
  late DocumentReference _thisPost;
  bool confirmPost = false;
  bool editingPost = false;
  bool loadingPost = true;
  FirebasePost firebasePost = FirebasePost();

  @override
  void initState() {
    _thisPost = firebasePost.getNewPostId();
    if (widget.postID != null) {
      title = 'Edit Post';
      _loadPostInfo();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _leavePage(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: TrackerAppBar(
          title: title,
          mainScreen: true,
          appBarAction: TrackerSimpleButton(
            text: 'Post',
            pressed: (_) {
              if (!editingPost) {
                _createPost();
              } else if (editingPost && !loadingPost) {
                _createPost(editingPost: editingPost);
              }
            },
          ),
        ),
        body: _body(),
      ),
    );
  }

  _body() {
    return Container(
      child: Column(
        children: [
          Container(
              height: MediaQuery.of(context).size.height * 0.06,
              child: _title()),
          Container(
            height: 1,
            color: Colors.black26,
          ),
          Container(
              height: MediaQuery.of(context).size.height * 0.330,
              child: _description()),
          Expanded(
            child: Container(child: _addPhotos()),
          ),
          Container(height: 45, color: Colors.lightBlue, child: _bottomBar()),
        ],
      ),
    );
  }

  _title() {
    return Container(
      margin: EdgeInsets.only(left: 6),
      child: TextFormField(
        controller: titleController,
        maxLength: 40,
        decoration: InputDecoration(
            hintText: 'Titulo da postagem',
            border: InputBorder.none,
            counter: Offstage()),
      ),
    );
  }

  _description() {
    return Container(
      margin: EdgeInsets.only(left: 6),
      child: TextFormField(
        controller: descriptionController,
        maxLines: 50,
        keyboardType: TextInputType.multiline,
        maxLength: 2500,
        decoration: InputDecoration(
            hintText: 'Write something about your post',
            border: InputBorder.none,
            counter: Offstage()),
      ),
    );
  }

  _bottomBar() {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Icon(Icons.add_location_alt_rounded, color: Colors.white),
          Icon(Icons.add_reaction_rounded, color: Colors.white),
        ],
      ),
    );
  }

  _addPhotos() {
    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            child: Image.network(
              'https://www.melhoresdestinos.com.br/wp-content/uploads/2021/02/torre-eiffel-paris-reforma.jpg',
              fit: BoxFit.fill,
            ),
          ),
        ),
        ClipRRect(
          // Clip it cleanly.
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: Colors.grey.withOpacity(0.1),
              alignment: Alignment.center,
            ),
          ),
        ),
        Container(
          child: Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AddPhotosScreen(
                              receivedList: imagesList,
                              postID: widget.postID != null
                                  ? widget.postID!
                                  : _thisPost.id,
                              processingFilesStream:
                                  widget.processingFilesStream,
                              confirm: (receivedImagesList) {
                                imagesList = receivedImagesList;
                              },
                            )));
              },
              child: Text('Add your pictures here!'),
            ),
          ),
        ),
      ],
    );
  }

  _createPost({bool editingPost = false}) {
    if (editingPost) {
      firebasePost.createPost(
          updating: true,
          updatingID: widget.postID,
          collaborators: [],
          description: descriptionController.text,
          mainLocation: '',
          ownerID: FirebaseAuth.instance.currentUser!.uid,
          title: titleController.text,
          processingFiles: widget.processingFilesStream);
    } else {
      firebasePost.createPost(
          collaborators: [],
          description: descriptionController.text,
          mainLocation: '',
          ownerID: FirebaseAuth.instance.currentUser!.uid,
          title: titleController.text,
          thisPost: _thisPost,
          processingFiles: widget.processingFilesStream);
    }

    confirmPost = true;
    Navigator.of(context).pop();
  }

  Future<bool> _leavePage() async {
    if (!confirmPost) {
      Map<String, dynamic> map = {
        "deletePost": _thisPost,
      };
      widget.processingFilesStream.addToQueue(map);
    }
    return true;
  }

  _loadPostInfo() async {
    DocumentSnapshot _post = await firebasePost.getPostInfo(widget.postID!);
    editingPost = true;

    Map postInfo = _post.data()! as Map<String, dynamic>;

    titleController.text = postInfo['title'];
    descriptionController.text = postInfo['description'];

    QuerySnapshot postImages = await firebasePost.getPostImages(widget.postID!);

    postImages.docs.forEach((image) {
      Map imageInfo = image.data() as Map<String, dynamic>;

      GeoPoint geoPoint = imageInfo['latLong'];

      imagesList.add(AddPhotosListItem(
          fromFirebase: true,
          name: imageInfo['imageID'],
          processing: false,
          path: 'firebase',
          firebasePath: imageInfo['firestorePath'],
          location:
              '${geoPoint.latitude.toStringAsFixed(6)}, ${geoPoint.longitude.toStringAsFixed(6)}',
          collaborator: imageInfo['collaborator']));
    });

    loadingPost = false;

    setState(() {});
  }
}
