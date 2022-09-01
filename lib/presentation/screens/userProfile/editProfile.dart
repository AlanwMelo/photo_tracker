import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:photo_tracker/classes/filePicker.dart';
import 'package:photo_tracker/data/firebase/firebaseUser.dart';
import 'package:photo_tracker/presentation/Widgets/loadingCoverScreen.dart';

class EditProfile extends StatefulWidget {
  final DocumentSnapshot user;
  final Function(bool) updated;

  const EditProfile({Key? key, required this.user, required this.updated})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _EditProfile();
}

class _EditProfile extends State<EditProfile> {
  TextEditingController nameController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  PlatformFile? newPic;
  late String picURL;
  bool localImage = false;
  bool loading = false;

  @override
  void initState() {
    _loadUSerInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _canPop(),
      child: Scaffold(
        body: _body(),
      ),
    );
  }

  _body() {
    return Stack(
      children: [
        Container(
          margin: EdgeInsets.only(top: 50),
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              _pic(),
              _changeName(),
              _changeDescription(),
              Expanded(child: Container()),
              _save(),
            ],
          ),
        ),
        loading ? LoadingCoverScreen() : Container(),
      ],
    );
  }

  _pic() {
    return Column(
      children: [
        Container(
          height: 150,
          width: 150,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
          ),
          child: ClipRRect(
              borderRadius: BorderRadius.circular(100.0),
              child: !localImage
                  ? Image.network(picURL, fit: BoxFit.cover)
                  : Image.file(File(picURL), fit: BoxFit.cover)),
        ),
        Container(
            margin: EdgeInsets.only(top: 8),
            child: InkWell(
              onTap: () {
                MyFilePicker(pickedFiles: (filePickerResult) async {
                  if (filePickerResult != null) {
                    print(filePickerResult.files.first);
                    localImage = true;
                    newPic = filePickerResult.files.first;
                    picURL = filePickerResult.files.first.path!;
                    setState(() {});
                  }
                }).pickFiles(allowMultiple: false);
              },
              child: Text(
                'Change photo',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.blue,
                ),
              ),
            )),
      ],
    );
  }

  _changeName() {
    return Container(
      margin: EdgeInsets.only(right: 8, left: 8, top: 8),
      child: TextFormField(
        controller: nameController,
        decoration: InputDecoration(hintText: 'Display name'),
      ),
    );
  }

  _changeDescription() {
    return Container(
      height: 100,
      margin: EdgeInsets.only(right: 8, left: 8, top: 8),
      child: TextFormField(
        controller: bioController,
        maxLines: 50,
        keyboardType: TextInputType.multiline,
        maxLength: 150,
        decoration: InputDecoration(hintText: 'Description'),
      ),
    );
  }

  _save() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 50,
      child: ElevatedButton(
        onPressed: () async {
          loading = true;
          setState(() {});

          if (await FirebaseUser().updateUserProfile(
              updateName: true,
              updateBio: true,
              updatePicture: localImage,
              newName: nameController.text,
              newBio: bioController.text,
              newPic: newPic,
              userID: widget.user.id)) {
            widget.updated(true);
            Navigator.pop(context);
          } else {
            loading = false;
            setState(() {});
          }
        },
        child: Text('Salvar'),
      ),
    );
  }

  _loadUSerInfo() {
    Map userInfo = widget.user.data() as Map;
    nameController.text = userInfo['name'];
    bioController.text = userInfo['userBio'];
    picURL = userInfo['profilePicURL'];
  }

  Future<bool> _canPop() async {
    if (loading) {
      return false;
    } else {
      return true;
    }
  }
}
