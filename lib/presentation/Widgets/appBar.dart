import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:photo_tracker/business_logic/blocs/authentication/authenticationHandlerBloc.dart';
import 'package:photo_tracker/business_logic/blocs/loadingCoverScreen/loadingCoverScreenBloc.dart';
import 'package:photo_tracker/business_logic/blocs/loadingCoverScreen/loadingCoverScreenEvent.dart';
import 'package:photo_tracker/business_logic/blocs/loadingCoverScreen/loadingCoverScreenState.dart';
import 'package:photo_tracker/business_logic/blocs/userInfo/userInfoBloc.dart';
import 'package:photo_tracker/business_logic/blocs/userInfo/userInfoEvent.dart';
import 'package:photo_tracker/business_logic/blocs/userInfo/userInfoState.dart';
import 'package:photo_tracker/business_logic/firebase/firebasePost.dart';
import 'package:photo_tracker/business_logic/firebase/firebaseUser.dart';
import 'package:photo_tracker/presentation/Widgets/pictureContainer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class _AppBar extends State<TrackerAppBar> {
  late var prefs;
  String picPath = '';

  @override
  void initState() {
    // TODO: implement initState
    _loadPrefs();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
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
                  child: PictureContainer(imgPath: picPath))
              : widget.appBarAction!,
        ],
      );
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

  Future<void> _testGoogle() async {
    FirebasePost().getPostInfo('postID');

    //FirebaseAuth.instance.signOut();

    /*BlocProvider.of<BlocOfUserInfo>(context).add(UpdateUserEventChanged(
        UpdateUserInfoStatus.updateUserStatus, 'Alan', 'Email', 'Pic'));*/
  }

  _loadPrefs() async {
    prefs = await SharedPreferences.getInstance();
    picPath = prefs.getString('imgPath');
    setState(() {});
  }
}
