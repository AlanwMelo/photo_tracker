import 'package:flutter/material.dart';
import 'package:photo_tracker/layouts/Widgets/pictureContainer.dart';

class TrackerAppBar extends StatefulWidget with PreferredSizeWidget {
  final String title;
  final bool showDrawer;
  final bool? actionTwo;
  final bool? actionThree;
  final Function(bool) notificationCallback;

  const TrackerAppBar(
      {Key? key,
      required this.title,
      this.actionTwo,
      this.actionThree,
      required this.showDrawer,
      required this.notificationCallback})
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
      title: Text(widget.title),
      titleSpacing: 0,
      leading: widget.showDrawer ? _notificationDrawer() : Container(),
      actions: [
        PictureContainer(),
      ],
    );
  }


  _notificationDrawer() {
    return IconButton(
        icon: Icon(Icons.notifications),
        onPressed: () {
          widget.notificationCallback(true);
        });
  }
}
