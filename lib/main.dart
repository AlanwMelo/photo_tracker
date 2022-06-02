import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_tracker/classes/alertDialog.dart';
import 'package:photo_tracker/classes/cacheCleaner.dart';
import 'package:photo_tracker/classes/createListItemFromQueryResult.dart';
import 'package:photo_tracker/classes/listItem.dart';
import 'package:photo_tracker/classes/mainListItem.dart';
import 'package:photo_tracker/classes/newListDialog.dart';
import 'package:photo_tracker/layouts/Widgets/AppBar.dart';
import 'package:photo_tracker/layouts/exifViewer.dart';
import 'package:photo_tracker/layouts/map_and_photos.dart';
import 'dart:io';
import 'db/dbManager.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Photo Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Photo Tracker'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;
  final DBManager dbManager = DBManager();

  @override
  _MyHomePageState createState() {
    dbManager.createDB();
    return _MyHomePageState();
  }
}

class _MyHomePageState extends State<MyHomePage> {
  List<MainListItem> mainList = [];
  final DBManager dbManager = DBManager();
  late String mapBoxKey;
  bool loading = true;
  var scaffoldKey = GlobalKey<ScaffoldState>();

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
      drawer: Drawer(),
      appBar: TrackerAppBar(
        title: 'Photo Tracker',
        showDrawer: true,
        notificationCallback: (_) {
          scaffoldKey.currentState?.openDrawer();
        },
      )
      /*AppBar(
        elevation: 0,
        title: Text(widget.title),
      )*/
      ,
      body: Container(),

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
    String data = await DefaultAssetBundle.of(context)
        .loadString('lib/assets/mapboxKey.json');
    final jsonResult = jsonDecode(data);
    mapBoxKey = jsonResult['mapboxKey'];
  }
}
