import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_tracker/layouts/Widgets/appBar.dart';

class CommentsScreen extends StatefulWidget {
  final String title;
  final String location;
  final Function(bool) closeButton;

  const CommentsScreen({Key? key, required this.title, required this.location, required this.closeButton})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _CommentsScreesState();
}

class _CommentsScreesState extends State<CommentsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TrackerAppBar(
          mainScreen: false,
          title: widget.title,
          notificationCallback: (bool) {
            widget.closeButton(true);
          },
          location: widget.location),
    );
  }
}