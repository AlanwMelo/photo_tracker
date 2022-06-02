import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PictureContainer extends StatelessWidget {
  const PictureContainer({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    /// Container com os layouts para a imagem circular

    return Container(
      height: 70,
      width: 70,
      child: Center(
        child: Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.redAccent,
            boxShadow: [
              BoxShadow(
                blurRadius: 2,
                spreadRadius: 2,
                color: Colors.black26,
              ),
            ],
          ),
        ),
      ),
    );
  }
}