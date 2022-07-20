import 'package:flutter/material.dart';

class TrackerSignButton extends StatelessWidget {
  final String text;
  final String imgURL;

  const TrackerSignButton({Key? key, required this.text, required this.imgURL})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      decoration: new BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 1,
              spreadRadius: 1,
              color: Colors.black12,
            )
          ],
          borderRadius: new BorderRadius.all(Radius.circular(15))),
      height: 60,
      width: 180,
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 20,
              width: 20,
              child: Image.network(imgURL),
            ),
            SizedBox(width: 8),
            Text(text)
          ],
        ),
      ),
    );
  }
}
