import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_tracker/data/firebase/firebasePost.dart';
import 'package:photo_tracker/presentation/Widgets/feedCard.dart';

class Feed extends StatefulWidget {
  final String mapBoxKey;
  final String queryMode;
  final String? userID;

  const Feed({Key? key, required this.mapBoxKey, required this.queryMode, this.userID})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _FeedState();
}

class _FeedState extends State<Feed> {
  List<dynamic> posts = [];
  CollectionReference _posts = FirebaseFirestore.instance.collection('posts');

  @override
  void initState() {
    _posts.snapshots().listen((event) {
      event.docChanges.forEach((element) async {
        if (await element.doc.get('postReady')) {
          posts.clear();
          await Future.delayed(Duration(seconds: 2));
          _loadFeed();
        }
      });
    });
    _loadFeed();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Expanded(
        child: Container(
          color: Colors.blueGrey.withOpacity(0.15),
          child: ListView.builder(
            padding: EdgeInsets.all(0),
              itemCount: posts.length,
              itemBuilder: (context, index) {
                return FeedCard(
                  postID: posts[index]['postID'],
                  mapboxKey: widget.mapBoxKey,
                  index: index,
                );
              }),
        ),
      ),
    );
  }

  _loadFeed() async {
    if (widget.queryMode == 'default') {
      posts = await FirebasePost().getPostsForFeed();
    } else if (widget.queryMode == 'userPosts') {
      posts = await FirebasePost().getPostsFromProfile(widget.userID!);
    }

    setState(() {});
  }
}
