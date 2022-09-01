import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:photo_tracker/data/firebase/firebaseUser.dart';

class EditProfile extends StatefulWidget {
  final DocumentSnapshot user;

  const EditProfile({Key? key, required this.user}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _EditProfile();
}

class _EditProfile extends State<EditProfile> {
  TextEditingController nameController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  late String picURL;

  @override
  void initState() {
    _loadUSerInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _body(),
    );
  }

  _body() {
    return Container(
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
              child:
                  true ? Image.network(picURL, fit: BoxFit.fill) : Container()),
        ),
        Container(
            margin: EdgeInsets.only(top: 8),
            child: InkWell(
              onTap: () {},
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
        onPressed: () {
          FirebaseUser().updateUserProfile(
              updateName: true,
              updateBio: true,
              updatePicture: false,
              newName: nameController.text,
              newBio: bioController.text,
              userID: widget.user.id);
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
}
