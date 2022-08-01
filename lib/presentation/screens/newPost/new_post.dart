import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:photo_tracker/data/firebase/firebasePost.dart';
import 'package:photo_tracker/presentation/Widgets/appBar.dart';
import 'package:photo_tracker/presentation/Widgets/trackerSimpleButton.dart';
import 'package:photo_tracker/presentation/screens/newPost/add_photos.dart';

class NewPost extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _NewPostState();
}

class _NewPostState extends State<NewPost> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: TrackerAppBar(
        title: 'New Post',
        mainScreen: true,
        appBarAction: TrackerSimpleButton(
          text: 'Post',
          pressed: (_) {
            _createPost();
          },
        ),
      ),
      body: _body(),
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
                              confirm: (imagesList) {
                                print(imagesList.length);
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

  _createPost() {
    FirebasePost().createPost(
        collaborators: [],
        description: descriptionController.text,
        mainLocation: '',
        ownerID: FirebaseAuth.instance.currentUser!.uid,
        title: titleController.text,
        thisPostPicturesList2: []);
  }
}
