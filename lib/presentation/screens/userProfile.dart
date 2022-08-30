import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:photo_tracker/data/firebase/firebaseUser.dart';
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
  String mapBoxKey = '';
  String userName = '';
  String userBio = '';
  String picURL = '';
  QuerySnapshot? userFollowers;
  QuerySnapshot? userFollowing;
  FirebaseUser firebaseUser = FirebaseUser();
  late DocumentSnapshot thisUser;

  @override
  void initState() {
    _loadUserInfo();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
            upperText: _calculateFollow(userFollowers),
            downText: 'Followers',
          ),
          _info(
            upperText: _calculateFollow(userFollowing),
            downText: 'Following',
          ),
        ],
      ),
    );
  }

  _calculateFollow(QuerySnapshot? querySnapshot) {
    String value = '';
    if (querySnapshot != null) {
      double total = querySnapshot.docs.length.toDouble();

      if (total < 1000) {
        value = total.toInt().toString();
      } else if (total < 1000000) {
        value = '${(total / 1000).toStringAsFixed(1)}K';
      } else {
        print(total / 1000000);
        value = '${(total / 1000000).toStringAsFixed(2)}M';
      }
    } else {
      value = '0';
    }

    return value;
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
          child: picURL != ''
              ? Image.network(picURL, fit: BoxFit.fill)
              : Container()),
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
              userName,
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
        mainAxisSize: MainAxisSize.min,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
                minHeight: 0, maxHeight: 150, minWidth: 285, maxWidth: 285),
            child: Container(
              margin: EdgeInsets.only(right: 12, left: 12, top: 8),
              child: Text(userBio),
            ),
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
    return Feed(
        mapBoxKey: mapBoxKey, queryMode: 'userPosts', userID: widget.userID);
  }

  _loadMapboxKey() async {
    mapBoxKey = await MapBoxKeyLoader(context: context).loadKey();
    return true;
  }

  _loadUserInfo() async {
    thisUser = await firebaseUser.getUserInfo(widget.userID);
    userFollowing = await firebaseUser.getUserFollowing(widget.userID);
    userName = thisUser.get('name');
    userBio = thisUser.get('userBio');
    picURL = thisUser.get('profilePicURL');
    setState(() {});
  }


}
