import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:photo_tracker/screens/classes/alertDialog.dart';
import 'package:photo_tracker/screens/classes/listItem.dart';
import 'package:photo_tracker/screens/classes/loadPhotosToList.dart';
import 'package:photo_tracker/screens/map_and_photos.dart';

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

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
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
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        _newListButton(),
        Expanded(
          child: Container(
            child: ListView.builder(
                itemCount: 12,
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MapAndPhotos()));
                    },
                    onLongPress: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return MyAlertDialog(
                                alertTitle: 'Remover',
                                alertText: 'Deseja mesmo remover esta lista?',
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
                              'Nome da lista',
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
        ),
      ],
    );
  }

  _newListButton() {
    return Container(
      height: 60,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            primary: Colors.lightBlue,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero)),
        onPressed: () async {
          FilePickerResult? result = await FilePicker.platform.pickFiles(
              allowMultiple: true,
              type: FileType.custom,
              allowedExtensions: ['jpg']);

          if (result != null) {
            List<ListItem> loadToListItems =
                await LoadPhotosToList(result).loadPhotos();

            for (var element in loadToListItems) {
              /*fileList.add(element);
                  thisItem = element;
                  _addMarkerToMap(element);*/
            }
            /*fileList.sort((a, b) => a.timestamp!.compareTo(b.timestamp!));

                _listAndCarouselSynchronizer(thisItem!,
                    fileList.indexWhere((element) => element == thisItem));*/
          } else {
            // User canceled the picker
          }
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
}
