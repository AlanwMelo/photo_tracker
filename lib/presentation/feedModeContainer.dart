import 'package:flutter/material.dart';

class FeedModeContainer extends StatelessWidget {
  final String text;
  final bool selected;

  const FeedModeContainer(
      {Key? key, required this.text, required this.selected})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: selected
              ? Border(
                  bottom: BorderSide(width: 3.5, color: Colors.lightBlue),
                )
              : Border()),
      child: Center(
        child: Container(
          child: Text(
            text,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: selected ? Colors.lightBlue : Colors.blueGrey),
          ),
        ),
      ),
    );
  }
}
