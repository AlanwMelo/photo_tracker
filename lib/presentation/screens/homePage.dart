import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_tracker/business_logic/blocs/loadingCoverScreen/loadingCoverScreenBloc.dart';
import 'package:photo_tracker/business_logic/blocs/loadingCoverScreen/loadingCoverScreenEvent.dart';
import 'package:photo_tracker/business_logic/blocs/userInfo/userInfoBloc.dart';
import 'package:photo_tracker/business_logic/blocs/userInfo/userInfoEvent.dart';
import 'package:photo_tracker/business_logic/processingFilesStream.dart';
import 'package:photo_tracker/classes/mainListItem.dart';
import 'package:photo_tracker/data/mapBoxKeyLoader.dart';
import 'package:photo_tracker/db/dbManager.dart';
import 'package:photo_tracker/presentation/Widgets/appBar.dart';
import 'package:photo_tracker/presentation/screens/feed.dart';
import 'package:photo_tracker/presentation/screens/newPost/new_post.dart';
import 'package:photo_tracker/presentation/screens/notifications.dart';
import 'package:photo_tracker/presentation/screens/searchScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TrackerHomePage extends StatefulWidget {
  TrackerHomePage({Key? key, required this.title}) : super(key: key);

  final String title;
  final DBManager dbManager = DBManager();

  @override
  _TrackerHomePageState createState() {
    return _TrackerHomePageState();
  }
}

class _TrackerHomePageState extends State<TrackerHomePage> {
  List<MainListItem> mainList = [];
  final DBManager dbManager = DBManager();
  late SharedPreferences prefs;
  late String mapBoxKey;
  bool loading = true;
  var scaffoldKey = GlobalKey<ScaffoldState>();
  ProcessingFilesStream processingFiles = ProcessingFilesStream();
  late Stream processingFilesStream;

  String varFeedMode = 'feed';
  bool varFeedSelected = true;
  bool postingOn = false;
  int varMainMode = 0;

  @override
  void initState() {
    super.initState();
    BlocProvider.of<BlocOfLoadingCoverScreen>(context).add(
        LoadingCoverScreenEventChanged(LoadingCoverScreenStatus.notLoading));
    processingFilesStream = processingFiles.initStream();
    processingFilesStream.listen((event) {
      if (event.toString().contains('posting') && event['posting']) {
        postingOn = true;
        setState(() {});
      } else if (event.toString().contains('posting') && !event['posting']) {
        postingOn = false;
        setState(() {});
      }
    });
    _loadMapboxKey();
    _loadPrefs();
  }

  @override
  build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: TrackerAppBar(
        title: 'Photo Tracker',
        mainScreen: true,
      ),
      body: _mainBody(),
    );
  }

  _loadMapboxKey() async {
    mapBoxKey = await MapBoxKeyLoader(context: context).loadKey();
    return true;
  }

  _loadPrefs() async {
    DBManager db = DBManager();
    var userInfo = await db.readUserInfo();

    BlocProvider.of<BlocOfUserInfo>(context).add(UpdateUserEventChanged(
        UpdateUserInfoStatus.updateUserStatus,
        userInfo[0]['userName'],
        userInfo[0]['userEmail'],
        userInfo[0]['profileImageLocation'],
        userInfo[0]['userID']));
  }

  _mainBody() {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            color: Colors.lightBlue,
            height: 50,
            child: _mainActions(),
          ),
          _switchMainMode(varMainMode)
        ],
      ),
    );
  }

  _feedMode() {
    _feedModeContainer(String text, bool selected) {
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

    return Container(
      height: 50,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
              child: GestureDetector(
                  onTap: () {
                    if (!varFeedSelected ? true : false) {
                      varFeedMode = 'feed';
                      varFeedSelected = !varFeedSelected;
                      setState(() {});
                    }
                  },
                  child: _feedModeContainer(
                      'Feed', varFeedSelected ? true : false))),
          Expanded(
            child: GestureDetector(
                onTap: () {
                  if (varFeedSelected ? true : false) {
                    varFeedMode = 'favorites';
                    varFeedSelected = !varFeedSelected;
                    setState(() {});
                  }
                },
                child: _feedModeContainer(
                    'Favoritos', !varFeedSelected ? true : false)),
          )
        ],
      ),
    );
  }

  _feed() {
    return FutureBuilder(
        future: _loadMapboxKey(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.data == true) {
            return Expanded(
              child: Container(
                child: Column(
                  children: [
                    postingOn
                        ? Container(
                            color: Colors.white,
                            height: 25,
                            child: Stack(
                              children: [
                                Container(
                                  margin: EdgeInsets.only(top: 20),
                                  child: LinearProgressIndicator(),
                                ),
                                Container(
                                    child: Center(child: Text('Posting...'))),
                              ],
                            ),
                          )
                        : Container(),
                    Container(
                      child: _feedMode(),
                      color: Colors.white,
                    ),
                    _switchFeedMode(varFeedMode),
                  ],
                ),
              ),
            );
          } else {
            return Container();
          }
        });
  }

  _mainActions() {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
              child: Container(
                  child: Center(
                      child: GestureDetector(
            onTap: () {
              if (varMainMode != 0) {
                varMainMode = 0;
                setState(() {});
              }
            },
            child: Icon(
              Icons.home_rounded,
              color: Colors.white70,
            ),
          )))),
          Expanded(
              child: Container(
                  child: GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => NewPost(processingFiles)));
            },
            child: Center(
                child: Icon(
              Icons.add_photo_alternate_rounded,
              color: Colors.white70,
            )),
          ))),
          Expanded(
              child: Container(
                  child: Center(
                      child: GestureDetector(
            onTap: () {
              if (varMainMode != 1) {
                varMainMode = 1;
                setState(() {});
              }
            },
            child: Icon(
              Icons.search,
              color: Colors.white70,
            ),
          )))),
          Expanded(
              child: Container(
                  child: Center(
                      child: GestureDetector(
            onTap: () {
              if (varMainMode != 2) {
                varMainMode = 2;
                setState(() {});
              }
            },
            child: Icon(
              Icons.notifications,
              color: Colors.white70,
            ),
          )))),
        ],
      ),
    );
  }

  _switchFeedMode(String varFeedMode) {
    switch (varFeedMode) {
      case 'feed':
        return Feed(mapBoxKey: mapBoxKey, queryMode: 'default');
      case 'favorites':
        return Feed(mapBoxKey: mapBoxKey, queryMode: 'default');
    }
  }

  _switchMainMode(int i) {
    switch (i) {
      case 0:
        return _feed();
      case 1:
        return SearchScreen();
      case 2:
        return NotificationsScreen();
    }
  }
}
