import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:photo_tracker/data/firebase/firebasePost.dart';
import 'package:photo_tracker/data/firebase/firebaseUser.dart';
import 'package:photo_tracker/data/routeAnimations/pageRouterSlideUp.dart';
import 'package:photo_tracker/presentation/Widgets/pictureContainer.dart';
import 'package:photo_tracker/presentation/screens/map_and_photos.dart';
import 'package:shimmer/shimmer.dart';

class FeedCard extends StatefulWidget {
  final String mapboxKey;
  final String postID;
  final int index;

  const FeedCard(
      {Key? key,
      required this.mapboxKey,
      required this.postID,
      required this.index})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _FeedCardState();
}

class _FeedCardState extends State<FeedCard> with AutomaticKeepAliveClientMixin {
  late DocumentSnapshot thisPost;
  late DocumentSnapshot postOwner;
  late QuerySnapshot postImages;
  bool postLoaded = false;
  int imgIndex = 0;
  List<String> postImagesURLs = [];

  @override
  void initState() {
    _getPostInfo();
    super.initState();
  }

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
      child: postLoaded ? _postLoaded() : _postLoading(),
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
    double height = 400;
    double width = MediaQuery.of(context).size.width;
    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
              onPageChanged: (index, reason) {
                setState(() {
                  imgIndex = index;
                });
              },
              height: height,
              initialPage: 0,
              enableInfiniteScroll: false,
              autoPlay: false,
              viewportFraction: 1,
              aspectRatio: 1),
          items: postImagesURLs.map((url) {
            return Builder(builder: (BuildContext context) {
              return Container(
                height: 500,
                width: MediaQuery.of(context).size.width,
                color: Colors.grey.withOpacity(0.05),
                child: Image.network(
                  url,
                  fit: BoxFit.cover,
                ),
              );
            });
          }).toList(),
        ),
        _dotsContainer(width),
      ],
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
    thisPost = await FirebasePost().getPostInfo(widget.postID);
    postImages = await FirebasePost().getPostImages(widget.postID);
    for (var element in postImages.docs) {
      postImagesURLs.add(element['firestorePath']);
    }
    postOwner = await FirebaseUser().getUserInfo(thisPost['ownerID']);
    postLoaded = true;
    setState(() {});
    return true;
  }

  _dotsContainer(double width) {
    return postImagesURLs.length > 0
        ? Container(
            color: Colors.grey.withOpacity(0.05),
            height: 20,
            width: width,
            child: Center(
              child: ListView.builder(
                itemCount: 7,
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    width: index == imgIndex ? 6.0 : 4.0,
                    height: 6.0,
                    margin: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: index == imgIndex ? Colors.blue : Colors.black),
                  );
                },
              ),
            ),
          )
        : Container();
  }

  _postLoaded() {
    return Container(
      color: Colors.white,
      margin: widget.index == 0
          ? EdgeInsets.only(top: 0)
          : EdgeInsets.only(top: 15),
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
          _publicationInfo(),
          _publicationCoverPic(),
          _publicationInteractionIcons(),
        ],
      ),
    );
  }

  _postLoading() {
    return Stack(
      children: [
        Container(
          height: 600,
          margin: widget.index == 0
              ? EdgeInsets.only(top: 0)
              : EdgeInsets.only(top: 15),
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              Container(
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
                        Container(
                            margin: EdgeInsets.all(16),
                            height: 40,
                            width: 40,
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            )),
                        Container(
                          color: Colors.blue,
                          width: 120,
                          height: 25,
                        ),
                        Expanded(child: Container()),
                        Icon(Icons.bookmark_border_rounded),
                        SizedBox(width: 10)
                      ],
                    ),
                    Container(
                        padding: EdgeInsets.only(left: 15),
                        child: Container(
                          color: Colors.blue,
                          width: 230,
                          height: 25,
                        )),
                    Container(
                        padding: EdgeInsets.only(left: 15, top: 5, bottom: 3),
                        child: Container(
                          color: Colors.blue,
                          width: 270,
                          height: 25,
                        )),
                    SizedBox(height: 15),
                  ],
                ),
              ),
              Container(
                height: 400,
                color: Colors.blue,
              ),
            ],
          ),
        ),
        Container(
          child: Shimmer.fromColors(
            highlightColor: Colors.white.withOpacity(0.2),
            baseColor: Colors.blueAccent.withOpacity(0.2),
            child: Container(
              margin: widget.index == 0
                  ? EdgeInsets.only(top: 0)
                  : EdgeInsets.only(top: 15),
              color: Colors.white,
              height: 600,
            ),
          ),
        )
      ],
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
