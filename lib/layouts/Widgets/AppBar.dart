import 'package:flutter/material.dart';

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
        pictureContainer(),
      ],
    );
  }

  Container pictureContainer() {
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
            color: Colors.red,
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

  _notificationDrawer() {
    return IconButton(
        icon: Icon(Icons.notifications),
        onPressed: () {
          widget.notificationCallback(true);
        });
  }
}
