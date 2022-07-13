import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_tracker/layouts/Widgets/pictureContainer.dart';

class EditPhotoListItem extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _EditPhotoListItem();
}

class _EditPhotoListItem extends State<EditPhotoListItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }

  _image() {
    return Container(
      width: 115,
      height: 100,
      child: Image.network(
        'https://www.melhoresdestinos.com.br/wp-content/uploads/2021/02/torre-eiffel-paris-reforma.jpg',
        fit: BoxFit.fill,
      ),
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
              'Image title',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            child: Row(
              children: [

                Text(
                  '27.173891, 78.042068',
                  style: TextStyle(fontSize: 12, color: Colors.lightBlue),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _picture() {
    return Container(
      width: 35,
      child: PictureContainer(),
    );
  }
}
