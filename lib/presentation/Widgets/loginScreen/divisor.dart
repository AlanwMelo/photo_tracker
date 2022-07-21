import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TrackerDivisor extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      margin: EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 1.25,
              color: Colors.white70,
            ),
          ),
          Container(
              margin: EdgeInsets.only(left: 8, right: 8),
              child: Text('or', style: TextStyle(color: Colors.white))),
          Expanded(
            child: Container(
              height: 1.25,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}