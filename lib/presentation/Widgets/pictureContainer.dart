import 'dart:io';

import 'package:flutter/material.dart';

class PictureContainer extends StatelessWidget {
  final String imgPath;

  const PictureContainer({
    Key? key,
    required this.imgPath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    /// Container com os presentation para a imagem circular

    return Container(
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
              borderRadius: BorderRadius.circular(100.0),
              child: imgPath == ''
                  ? Image.asset('lib/assets/Icon.png')
                  : Image.file(File(imgPath))),
        ),
      ),
    );
  }
}
