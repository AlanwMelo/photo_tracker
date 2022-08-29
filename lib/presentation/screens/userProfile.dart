import 'package:flutter/material.dart';
import 'package:photo_tracker/data/mapBoxKeyLoader.dart';
import 'package:photo_tracker/presentation/feedModeContainer.dart';
import 'package:photo_tracker/presentation/screens/feed.dart';

class UserProfile extends StatefulWidget {
  final String userID;

  const UserProfile({Key? key, required this.userID}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _UserProfile();
}

class _UserProfile extends State<UserProfile> {
  late String mapBoxKey;

  @override
  Widget build(BuildContext context) {
    print(widget.userID);
    return Scaffold(
      body: _body(),
    );
  }

  _body() {
    return FutureBuilder(
        future: _loadMapboxKey(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return Container(
            child: Column(
              children: [
                SizedBox(height: MediaQuery.of(context).viewPadding.top),
                _fakeAppBar(),
                _picAndBio(),
                _followers(),
                SizedBox(height: 12),
                _midButton(),
                _feedMode(),
                _feed(),
              ],
            ),
          );
        });
  }

  _fakeAppBar() {
    return Container(
      margin: EdgeInsets.only(right: 6, left: 12, top: 8),
      child: Row(
        children: [
          Expanded(
              child: Container(
            child: Text(
              'Tracker#8739f7ba',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          )),
          Container(child: Center(child: Icon(Icons.more_vert, size: 35))),
        ],
      ),
    );
  }

  _picAndBio() {
    return Container(
      margin: EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _pic(),
          Expanded(
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _name(),
                  _bio(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  _followers() {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _info(
            upperText: "1000",
            downText: 'Followers',
          ),
          _info(
            upperText: "10K",
            downText: 'Following',
          ),
        ],
      ),
    );
  }

  _pic() {
    return Container(
      height: 80,
      width: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
      ),
      child: ClipRRect(
          borderRadius: BorderRadius.circular(100.0),
          child: Image.network(
              'https://lh3.googleusercontent.com/a-/AFdZucp2juMBhxTq35bUeKVAdDKng3qwJ-hkyoK5qDb2=s96-c',
              fit: BoxFit.fill)),
    );
  }

  _info({
    required String upperText,
    required String downText,
  }) {
    return Container(
      child: Column(
        children: [
          Text(
            upperText,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          Text(
            downText,
            style: TextStyle(
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  _name() {
    return Container(
      child: Row(
        children: [
          Container(
            margin: EdgeInsets.only(left: 12),
            child: Text(
              'Alan Willian',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  _bio() {
    return Container(
      child: Row(
        children: [
          Container(
            margin: EdgeInsets.only(right: 12, left: 12, top: 8),
            child: Text('\${informacoes_pessoais}\n'
                '\${texto_legal}'),
          )
        ],
      ),
    );
  }

  _midButton() {
    return Container(
      margin: EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Container(
              width: 300,
              height: 25,
              color: Colors.black54,
              child: Center(
                child: Text(
                  'Edit Profile',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _feedMode() {
    return Container(
      height: 40,
      child: Row(
        children: [
          Expanded(
            child: FeedModeContainer(selected: true, text: 'Posts'),
          ),
          Expanded(
            child: FeedModeContainer(selected: false, text: 'Colaborações'),
          ),
        ],
      ),
    );
  }

  _feed() {
    return Container(
      child: Feed(mapBoxKey: mapBoxKey),
    );
  }

  _loadMapboxKey() async {
    mapBoxKey = await MapBoxKeyLoader(context: context).loadKey();
    return true;
  }
}
