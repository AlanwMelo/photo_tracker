import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_tracker/presentation/Widgets/pictureContainer.dart';

class EditPhotoListItem extends StatefulWidget {
  final String imagePath;
  final String imageName;
  final String location;
  final String collaborator;
  final String? firebasePath;
  final bool processing;
  final bool fromFirebase;
  final String user;

  const EditPhotoListItem(
      {Key? key,
      required this.imagePath,
      required this.imageName,
      required this.user,
      required this.location,
      required this.collaborator,
      required this.processing,
      required this.fromFirebase,
      this.firebasePath})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _EditPhotoListItem();
}

class _EditPhotoListItem extends State<EditPhotoListItem> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 70,
          width: MediaQuery.of(context).size.width,
          color: Colors.white,
          child: Row(
            children: [
              _image(),
              _info(),
              _picture(),
            ],
          ),
        ),
        widget.processing
            ? Container(
                height: 70,
                width: MediaQuery.of(context).size.width,
                color: Colors.white54,
                child: Center(child: CircularProgressIndicator()),
              )
            : Container()
      ],
    );
  }

  _image() {
    return Container(
      width: 115,
      height: 100,
      child: widget.fromFirebase
          ? Image.network(widget.firebasePath!, fit: BoxFit.cover)
          : Image.file(File(widget.imagePath),
              fit: BoxFit.cover, filterQuality: FilterQuality.low),
    );
  }

  _info() {
    return Container(
      padding: EdgeInsets.only(left: 12),
      width: MediaQuery.of(context).size.width * 0.6,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            child: Text(
              widget.imageName,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            child: Row(
              children: [
                _locationText(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _picture() {
    return widget.collaborator == widget.user
        ? Container()
        : Container(
            width: 35,
            child: PictureContainer(
              imgPath: '',
              pathOrURl: true,
              profileID: '',
            ),
          );
  }

  _locationText() {
    String text;
    Color? color;

    switch (widget.location) {
      case 'not processed':
        text = 'Aguardando processamento';
        color = Colors.orange;
        break;
      case 'error':
        text = 'Não foi possivel localizar a imagem';
        color = Colors.redAccent;
        break;
      default:
        text = widget.location;
        color = Colors.lightBlue;
        break;
    }

    return Text(
      text,
      style: TextStyle(fontSize: 12, color: color),
    );
  }
}
