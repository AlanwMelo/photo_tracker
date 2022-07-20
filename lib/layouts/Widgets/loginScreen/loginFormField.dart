import 'package:flutter/material.dart';

class TrackerLoginFormField extends StatefulWidget {
  final IconData icon;
  final String hint;

  const TrackerLoginFormField(
      {Key? key, required this.icon, required this.hint})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _TrackerLoginFormField();
}

class _TrackerLoginFormField extends State<TrackerLoginFormField> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      margin: EdgeInsets.only(left: 18, right: 18, bottom: 6),
      child: TextFormField(
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          fillColor: Colors.white,
          prefixIcon: Icon(
            widget.icon,
            color: Colors.white70,
          ),
          hintText: widget.hint,
          hintStyle: TextStyle(color: Colors.white),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.yellow, width: 1)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.white, width: 1)),
        ),
      ),
    );
  }
}
