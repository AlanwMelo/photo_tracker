import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_tracker/classes/alertDialog.dart';
import 'package:photo_tracker/classes/cacheCleaner.dart';
import 'package:photo_tracker/classes/createListItemFromQueryResult.dart';
import 'package:photo_tracker/classes/listItem.dart';
import 'package:photo_tracker/classes/mainListItem.dart';
import 'package:photo_tracker/classes/mapBoxKeyLoader.dart';
import 'package:photo_tracker/classes/newListDialog.dart';
import 'package:photo_tracker/db/dbManager.dart';
import 'package:photo_tracker/layouts/Widgets/appBar.dart';
import 'package:photo_tracker/layouts/exifViewer.dart';
import 'package:photo_tracker/layouts/screens/feed.dart';
import 'package:photo_tracker/layouts/screens/map_and_photos.dart';
import 'package:photo_tracker/layouts/screens/new_post/new_post.dart';
import 'package:photo_tracker/layouts/screens/notifications.dart';
import 'package:photo_tracker/layouts/screens/searchScreen.dart';

class TrackerHomePage extends StatefulWidget {
  TrackerHomePage({Key? key, required this.title}) : super(key: key);

  final String title;
  final DBManager dbManager = DBManager();

  @override
  _TrackerHomePageState createState() {
    dbManager.createDB();
    return _TrackerHomePageState();
  }
}

class _TrackerHomePageState extends State<TrackerHomePage> {
  List<MainListItem> mainList = [];
  final DBManager dbManager = DBManager();
  late String mapBoxKey;
  bool loading = true;
  var scaffoldKey = GlobalKey<ScaffoldState>();

  String varFeedMode = 'feed';
  bool varFeedSelected = true;
  int varMainMode = 0;

  @override
  void initState() {
    super.initState();
    CacheCleaner().cleanUnusedImgs();
    _loadMapboxKey();
    _loadMainList();
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

      ///body: _mainListView(),
    );
  }

  _mainListView() {
    return loading
        ? Container(
      child: Center(
        child: CircularProgressIndicator(),
      ),
    )
        : Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        _newListButton(),
        mainList.length != 0
            ? Expanded(
          child: Container(
            child: ListView.builder(
                itemCount: mainList.length,
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onDoubleTap: () async {
                      FilePickerResult? result =
                      await FilePicker.platform.pickFiles(
                          allowMultiple: false,
                          type: FileType.custom,
                          allowedExtensions: ['jpg']);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  ExifViewer(result: result)));
                    },
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MapAndPhotos(
                                mapboxKey: mapBoxKey,
                                listName: mainList[index].name,
                                answer: (answer) async {
                                  if (answer) {
                                    _addItemToList(
                                        mainList[index].name,
                                        update: true,
                                        updateIndex: index);
                                    await Future.delayed(
                                        Duration(seconds: 3));
                                    setState(() {});
                                  }
                                },
                              )));
                    },
                    onLongPress: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return MyAlertDialog(
                                alertTitle: 'Remover',
                                alertText:
                                'Deseja mesmo remover esta lista?',
                                alertButton1Text: 'Sim',
                                alertButton2Text: 'Não',
                                answer: (answer) {
                                  if (answer == 1) {
                                    dbManager.deleteList(
                                        mainList[index].name);
                                    mainList.removeAt(index);
                                    setState(() {});
                                  }
                                });
                          });
                    },
                    child: Container(
                      margin: EdgeInsets.all(4),
                      height: 80,
                      color:
                      Colors.lightBlueAccent.withOpacity(0.40),
                      child: Row(children: [
                        Container(
                          height: 100,
                          width: 100,
                          child: Image.file(
                              File(mainList[index]
                                  .firstItem
                                  .imgPath),
                              fit: BoxFit.fill),
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 10),
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: EdgeInsets.only(top: 25),
                                height: 55,
                                width: MediaQuery.of(context)
                                    .size
                                    .width *
                                    0.69, // 85
                                child: Text(
                                  '${mainList[index].name} ',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Text(
                                'Quantidade de imagens: ${mainList[index].itemCount}',
                                style: TextStyle(
                                  color: Colors.black45,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        )
                      ]),
                    ),
                  );
                }),
          ),
        )
            : Container()
      ],
    );
  }

  _newListButton() {
    return Container(
      height: mainList.length != 0 ? 60 : 150,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            primary: Colors.lightBlue,
            shape: mainList.length != 0
                ? RoundedRectangleBorder(borderRadius: BorderRadius.zero)
                : CircleBorder()),
        onPressed: () async {
          showDialog(
              barrierDismissible: false,
              context: context,
              builder: (BuildContext context) {
                return NewListDialog(
                    alertTitle: 'Criar nova lista',
                    answer: (answer) {
                      _addItemToList(answer);
                    });
              });
        },
        child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Nova lista', style: TextStyle(fontSize: 20)),
                SizedBox(width: 8),
                Icon(Icons.assignment_sharp),
              ],
            )),
      ),
    );
  }

  _loadMainList() async {
    var mainListItems = await dbManager.getMainListItems();
    for (var file in mainListItems) {
      await _funcAddItem(file);
    }
    loading = !loading;
    setState(() {});
  }

  _addItemToList(String listName,
      {bool update = false, int updateIndex = 0}) async {
    var result = await dbManager.getListItem(listName);
    for (var element in result) {
      await _funcAddItem(element, update: update, index: updateIndex);
      setState(() {});
    }
  }

  _funcAddItem(file, {bool update = false, int index = 0}) async {
    ListItem firstListItem;
    var firstItemResult =
    await dbManager.getFirstItemOfList(file['mainListName']);
    for (var element in firstItemResult) {
      firstListItem = await CreateListItemFromQueryResult().create(element);
      MainListItem addThisItem = MainListItem(
          file['mainListName'],
          firstListItem,
          DateTime.fromMillisecondsSinceEpoch(
              double.parse(file['created'].toString()).ceil()),
          await dbManager.getListItemCount(file['mainListName']));
      if (update) {
        mainList[index] = addThisItem;
      } else {
        mainList.add(addThisItem);
      }
      mainList.sort((a, b) => a.created.compareTo(b.created));
    }
    return true;
  }

  _loadMapboxKey() async {
    mapBoxKey = await MapBoxKeyLoader(context: context).loadKey();
    return true;
  }

  _mainBody() {
    return Container(
      color: Colors.blueGrey.withOpacity(0.15),
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

  feedMode() {
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

  feed() {
    return FutureBuilder(
        future: _loadMapboxKey(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.data == true) {
            return Expanded(
              child: Container(
                child: Column(
                  children: [
                    Container(
                      child: feedMode(),
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
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=> NewPost() ));
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
        return Feed(mapBoxKey: mapBoxKey, itemCount: 12);
      case 'favorites':
        return Feed(mapBoxKey: mapBoxKey, itemCount: 4);
    }
  }

  _switchMainMode(int i) {
    switch (i) {
      case 0:
        return feed();
      case 1:
        return SearchScreen();
      case 2:
        return NotificationsScreen();
    }
  }
}