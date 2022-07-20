import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:photo_tracker/layouts/Widgets/pictureContainer.dart';
import 'package:photo_tracker/layouts/screens/login/signIn.dart';
import 'package:photo_tracker/layouts/screens/login/signUp.dart';

class TrackerAppBar extends StatefulWidget with PreferredSizeWidget {
  final String title;
  final bool mainScreen;
  final String? location;
  final bool? actionTwo;
  final bool? actionThree;
  final Widget? appBarAction;

  const TrackerAppBar(
      {Key? key,
      required this.title,
      this.actionTwo,
      this.actionThree,
      required this.mainScreen,
      this.location,
      this.appBarAction})
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
      actions: [
        widget.appBarAction == null
            ? GestureDetector(
                onTap: () {
                  _testGoogle();
                },
                child: PictureContainer())
            : widget.appBarAction!,
      ],
    );
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

  Future<void> _testGoogle() async {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => TrackerSignInPage()));
  }
}
