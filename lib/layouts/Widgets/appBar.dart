import 'package:flutter/material.dart';
import 'package:photo_tracker/layouts/Widgets/pictureContainer.dart';

class TrackerAppBar extends StatefulWidget with PreferredSizeWidget {
  final String title;
  final bool mainScreen;
  final String? location;
  final bool? actionTwo;
  final bool? actionThree;
  final Function(bool) notificationCallback;

  const TrackerAppBar(
      {Key? key,
      required this.title,
      this.actionTwo,
      this.actionThree,
      required this.mainScreen,
      required this.notificationCallback,
      this.location})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _AppBar();

  @override
  // TODO: implement preferredSize
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class _AppBar extends State<TrackerAppBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      title: _title(),
      titleSpacing: 0,
      leading: _leading(),
      actions: [
        PictureContainer(),
      ],
    );
  }

  _leading() {
    return widget.mainScreen
        ? null
        : IconButton(
            icon: Icon(Icons.arrow_back_rounded),
            onPressed: () {
              widget.notificationCallback(true);
            });
  }

  _title() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
              margin: widget.mainScreen
                  ? EdgeInsets.only(left: 20)
                  : EdgeInsets.only(left: 0),
              child: Text(widget.title)),
          widget.location != null
              ? Text(
                  widget.location!,
                  style: TextStyle(color: Colors.white, fontSize: 13),
                )
              : Container(),
        ],
      ),
    );
  }
}
