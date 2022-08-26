import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:photo_tracker/data/firebase/firebasePost.dart';
import 'package:photo_tracker/presentation/Widgets/feedCard.dart';

class Feed extends StatefulWidget {
  final String mapBoxKey;
  final int itemCount;

  const Feed({Key? key, required this.mapBoxKey, required this.itemCount})
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
        print(await element.doc.get('postReady'));
        if (await element.doc.get('postReady')) {
          posts.clear();
          await Future.delayed(Duration(microseconds: 500));
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
        child: ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              return FeedCard(
                postID: posts[index]['postID'],
                mapboxKey: widget.mapBoxKey,
                index: index,
              );
            }),
      ),
    );
  }

  _loadFeed() async {
    posts = await FirebasePost().getPostsForFeed();
    setState(() {});
  }
}
