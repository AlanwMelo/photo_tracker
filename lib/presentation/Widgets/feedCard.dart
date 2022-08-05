import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:photo_tracker/data/firebase/firebasePost.dart';
import 'package:photo_tracker/data/firebase/firebaseUser.dart';
import 'package:photo_tracker/data/routeAnimations/pageRouterSlideUp.dart';
import 'package:photo_tracker/presentation/Widgets/pictureContainer.dart';
import 'package:photo_tracker/presentation/screens/map_and_photos.dart';

class FeedCard extends StatefulWidget {
  final String mapboxKey;
  final String postID;

  const FeedCard({Key? key, required this.mapboxKey, required this.postID})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _FeedCardState();
}

class _FeedCardState extends State<FeedCard> {
  late DocumentSnapshot thisPost;
  late DocumentSnapshot postOwner;
  late QuerySnapshot postImages;
  List<String> postImagesURLs = [];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {},
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => MapAndPhotos(
                    postTitle: thisPost['title'],
                    postID: widget.postID,
                    answer: (_) {},
                    mapboxKey: widget.mapboxKey)));
      },
      child: FutureBuilder(
          future: _getPostInfo(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Container(
                color: Colors.white,
                margin: EdgeInsets.only(top: 15),
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: [
                    _publicationInfo(),
                    _publicationCoverPic(),
                    _publicationInteractionIcons(),
                  ],
                ),
              );
            } else {
              return Container();
            }
          }),
    );
  }

  _publicationInfo() {
    return Container(
      constraints: BoxConstraints(
        maxHeight: 200,
      ),
      color: Colors.grey.withOpacity(0.05),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              PictureContainer(
                  imgPath: postOwner['profilePicURL'], pathOrURl: false),
              Text(
                postOwner['name'],
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Expanded(child: Container()),
              Icon(Icons.bookmark_border_rounded),
              SizedBox(width: 10)
            ],
          ),
          Container(
              padding: EdgeInsets.only(left: 15),
              child: Text(
                thisPost['title'],
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              )),
          Container(
              padding: EdgeInsets.only(left: 15, top: 5, bottom: 3),
              child: Text(
                thisPost['description'],
                style: TextStyle(fontSize: 15),
              )),
          Container(
              padding: EdgeInsets.only(left: 15, bottom: 5),
              child: Row(
                children: [
                  Text(
                    thisPost['mainLocation'],
                    style: TextStyle(color: Colors.lightBlue, fontSize: 13),
                  )
                ],
              )),
        ],
      ),
    );
  }

  _publicationCoverPic() {
    return Container(
      child: CarouselSlider(
        options: CarouselOptions(
            height: 400,
            initialPage: 0,
            enableInfiniteScroll: false,
            autoPlay: true,
            autoPlayInterval: Duration(seconds: 20),
            viewportFraction: 1,
            aspectRatio: 1),
        items: postImagesURLs.map((url) {
          return Builder(builder: (BuildContext context) {
            return Container(
              child: Image.network(
                url,
                fit: BoxFit.cover,
              ),
            );
          });
        }).toList(),
      ),
    );
  }

  _publicationInteractionIcons() {
    return Container(
      height: 50,
      color: Colors.grey.withOpacity(0.05),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Icon(Icons.add_reaction_outlined),
          Container(
              width: 230,
              child: GestureDetector(
                  onTap: () => Navigator.of(context).push(routeSlideUp(
                      MapAndPhotos(
                          postTitle: thisPost['title'],
                          postID: widget.postID,
                          answer: (_) {},
                          mapboxKey: widget.mapboxKey,
                          goToComments: true))),
                  child: Icon(Icons.notes_rounded))),
          Icon(Icons.send),
        ],
      ),
    );
  }

  _getPostInfo() async {
    postImagesURLs.clear();
    thisPost = await FirebasePost().getPostInfo(widget.postID);
    postImages = await FirebasePost().getPostImages(widget.postID);
    for (var element in postImages.docs) {
      postImagesURLs.add(element['firestorePath']);
    }
    postOwner = await FirebaseUser().getUserInfo(thisPost['ownerID']);
    return true;
  }
}
