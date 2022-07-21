import 'package:flutter/material.dart';
import 'package:photo_tracker/classes/routeAnimations/pageRouterSlideUp.dart';
import 'package:photo_tracker/presentation/Widgets/pictureContainer.dart';
import 'package:photo_tracker/presentation/screens/map_and_photos.dart';

class FeedCard extends StatefulWidget {
  final String mapboxKey;
  final String name;

  const FeedCard({Key? key, required this.mapboxKey, required this.name})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _FeedCardState();
}

class _FeedCardState extends State<FeedCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => MapAndPhotos(
                    listName: widget.name,
                    answer: (_) {},
                    mapboxKey: widget.mapboxKey)));
      },
      child: Container(
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
      ),
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
              PictureContainer(imgPath: ''),
              Text(
                'Alan Melo',
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
                'Férias 2021',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              )),
          Container(
              padding: EdgeInsets.only(left: 15, top: 5, bottom: 3),
              child: Text(
                'Férias do ano passado',
                style: TextStyle(fontSize: 15),
              )),
          Container(
              padding: EdgeInsets.only(left: 15, bottom: 5),
              child: Row(
                children: [
                  Text(
                    'Campinas - SP',
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
      height: 400,
      child: Image.network(
        'https://www.melhoresdestinos.com.br/wp-content/uploads/2021/02/torre-eiffel-paris-reforma.jpg',
        fit: BoxFit.cover,
      ),
      color: Colors.yellow,
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
                          listName: widget.name,
                          answer: (_) {},
                          mapboxKey: widget.mapboxKey,
                          goToComments: true))),
                  child: Icon(Icons.notes_rounded))),
          Icon(Icons.send),
        ],
      ),
    );
  }
}
