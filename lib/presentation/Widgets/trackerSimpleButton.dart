import 'package:flutter/material.dart';

class TrackerSimpleButton extends StatefulWidget {
  final String text;
  final Function(bool) pressed;

  const TrackerSimpleButton(
      {Key? key, required this.text, required this.pressed})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _TrackerSimpleButton();
}

class _TrackerSimpleButton extends State<TrackerSimpleButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.all(7),
        decoration: _myDecoration(),
        width: 100,
        child: InkWell(
          onTap: () {
            widget.pressed(true);
          },
          child: Center(
              child: Text(widget.text,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white))),
        ));
  }

  _myDecoration() {
    return BoxDecoration(
      border: Border.all(
        width: 1.0,
        color: Colors.white,
      ),
      borderRadius: BorderRadius.all(Radius.circular(5.0)),
    );
  }
}
