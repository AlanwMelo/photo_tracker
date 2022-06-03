import 'package:flutter/cupertino.dart';
import 'package:photo_tracker/layouts/Widgets/feedCard.dart';

class Feed extends StatefulWidget {
  final String mapBoxKey;
  final int itemCount;

  const Feed({Key? key, required this.mapBoxKey, required this.itemCount}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _FeedState();
}

class _FeedState extends State<Feed> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Expanded(
        child: ListView.builder(
            itemCount: widget.itemCount,
            itemBuilder: (context, index) {
              return FeedCard(
                name: 'teste',
                mapboxKey: widget.mapBoxKey,
              );
            }),
      ),
    );
  }
}