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

  @override
  void initState() {
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
