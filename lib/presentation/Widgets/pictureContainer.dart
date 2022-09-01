import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_tracker/presentation/screens/userProfile/userProfile.dart';

class PictureContainer extends StatelessWidget {
  final String imgPath;
  final String profileID;

  /// True == PATH / False == URL
  final bool pathOrURl;

  const PictureContainer({
    Key? key,
    required this.imgPath,
    required this.pathOrURl,
    required this.profileID,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    /// Container com os presentation para a imagem circular

    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => UserProfile(userID: profileID))),
      child: Container(
        height: 70,
        width: 70,
        child: Center(
          child: Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  blurRadius: 2,
                  spreadRadius: 2,
                  color: Colors.black26,
                ),
              ],
            ),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(100.0), child: _image()),
          ),
        ),
      ),
    );
  }

  _image() {
    if (pathOrURl) {
      return imgPath == ''
          ? Image.asset('lib/assets/Icon.png')
          : Image.file(File(imgPath), fit: BoxFit.cover);
    } else {
      return Image.network(imgPath, fit: BoxFit.cover);
    }
  }
}
