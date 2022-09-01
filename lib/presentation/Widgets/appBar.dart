import 'dart:convert';

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
import 'package:photo_tracker/data/firebase/firebasePost.dart';
import 'package:photo_tracker/data/firebase/firebaseUser.dart';
import 'package:photo_tracker/db/dbManager.dart';
import 'package:photo_tracker/presentation/Widgets/pictureContainer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math';
import 'package:http/http.dart' as http;

class TrackerAppBar extends StatefulWidget with PreferredSizeWidget {
  final String title;
  final bool mainScreen;
  final bool implyLeading;
  final String? location;
  final bool? actionTwo;
  final bool? actionThree;
  final Widget? appBarAction;

  const TrackerAppBar(
      {Key? key,
      required this.title,
      this.actionTwo,
      this.implyLeading = true,
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
  String picPath = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      return AppBar(
        automaticallyImplyLeading: widget.implyLeading,
        elevation: 0,
        title: _title(),
        titleSpacing: 0,
        actions: [
          widget.appBarAction == null
              ? GestureDetector(
                  onLongPress: () {},
                  child: BlocBuilder<BlocOfUserInfo, BlocOfUserInfoState>(
                      builder: (context, state) {
                    return PictureContainer(
                      imgPath: state.userProfilePic,
                      pathOrURl: true,
                      profileID: state.userID,
                    );
                  }))
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
    //FirebasePost().getPostsForFeed();
    //FirebaseAuth.instance.signOut();
  }
}
