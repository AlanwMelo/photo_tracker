import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_tracker/classes/alertDialog.dart';
import 'package:photo_tracker/classes/cacheCleaner.dart';
import 'package:photo_tracker/classes/createListItemFromQueryResult.dart';
import 'package:photo_tracker/classes/listItem.dart';
import 'package:photo_tracker/classes/mainListItem.dart';
import 'package:photo_tracker/classes/newListDialog.dart';
import 'package:photo_tracker/screens/map_and_photos.dart';
import 'dart:io';
import 'db/dbManager.dart';

void main() {
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
  bool loading = true;

  @override
  void initState() {
    super.initState();
    CacheCleaner().cleanUnusedImgs();
    _loadMainList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: _mainListView(),
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
                                onDoubleTap: () {
                                  _addItemToList('awm');
                                },
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => MapAndPhotos(
                                              listName: mainList[index].name)));
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

          /*
          FilePickerResult? result = await FilePicker.platform.pickFiles(
              allowMultiple: true,
              type: FileType.custom,
              allowedExtensions: ['jpg']);

          if (result != null) {
            List<ListItem> loadToListItems =
                await LoadPhotosToList(result).loadPhotos();

            for (var element in loadToListItems) {
              */ /*fileList.add(element);
                  thisItem = element;
                  _addMarkerToMap(element);*/ /*
            }
            */ /*fileList.sort((a, b) => a.timestamp!.compareTo(b.timestamp!));

                _listAndCarouselSynchronizer(thisItem!,
                    fileList.indexWhere((element) => element == thisItem));*/ /*
          } else {
            // User canceled the picker
          }*/
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

  _addItemToList(String listName) async {
    var result = await dbManager.getListItem(listName);
    for (var element in result) {
      await _funcAddItem(element);
      setState(() {});
    }
  }

  _funcAddItem(file) async {
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
      mainList.add(addThisItem);
      mainList.sort((a, b) => a.created.compareTo(b.created));
    }
    return true;
  }
}
