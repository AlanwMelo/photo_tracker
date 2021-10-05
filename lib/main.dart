import 'package:flutter/material.dart';
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
  void _incrementCounter() {
    setState(() {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => MapAndPhotos()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: _mainListView(),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.forward),
      ),
    );
  }

  _mainListView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Container(
          color: Colors.red,
          height: 80,
        ),
        Expanded(
          child: Container(
            color: Colors.yellow,
            child: ListView.builder(
               itemCount: 12,
                itemBuilder: (BuildContext context, int index) {
              return Container(margin: EdgeInsets.all(4),
                color: Colors.blueGrey,
                height: 100,
              );
            }),
          ),
        ),
      ],
    );
  }
}
