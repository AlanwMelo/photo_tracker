import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:photo_tracker/classes/alertDialog.dart';
import 'package:photo_tracker/classes/cacheCleaner.dart';
import 'package:photo_tracker/classes/createListItemFromQueryResult.dart';
import 'package:photo_tracker/classes/listItem.dart';
import 'package:photo_tracker/classes/mainListItem.dart';
import 'package:photo_tracker/classes/newListDialog.dart';
import 'package:photo_tracker/screens/map_and_photos.dart';

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
    return Column(
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
                            _loadMainList();
                          },
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        MapAndPhotos(listName: 'name')));
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
                                        print(answer);
                                      });
                                });
                          },
                          child: Container(
                            margin: EdgeInsets.all(4),
                            height: 100,
                            color: Colors.lightBlueAccent.withOpacity(0.65),
                            child: Row(children: [
                              Container(
                                height: 100,
                                width: 100,
                                child: Image.network(
                                    'https://wallpaperaccess.com/full/155734.png',
                                    fit: BoxFit.fill),
                              ),
                              Expanded(
                                  child: Center(
                                child: Container(
                                  child: Text(
                                    '${mainList[index].name} ${mainList[index].itemCount}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ))
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
                      print(answer);
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
    mainListItems.forEach((file) async {
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
      }
    });
  }
}
