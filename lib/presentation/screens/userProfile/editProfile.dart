import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:photo_tracker/presentation/Widgets/loginScreen/loginFormField.dart';
import 'package:photo_tracker/presentation/Widgets/pictureContainer.dart';

class EditProfile extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _EditProfile();
}

class _EditProfile extends State<EditProfile> {
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
              child: true
                  ? Image.network(
                      'https://lh3.googleusercontent.com/a-/AFdZucp2juMBhxTq35bUeKVAdDKng3qwJ-hkyoK5qDb2=s96-c',
                      fit: BoxFit.fill)
                  : Container()),
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
        decoration: InputDecoration(hintText: 'Display name'),
      ),
    );
  }

  _changeDescription() {
    return Container(
      height: 100,
      margin: EdgeInsets.only(right: 8, left: 8, top: 8),
      child: TextFormField(
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
        onPressed: () {},
        child: Text('Salvar'),
      ),
    );
  }
}
