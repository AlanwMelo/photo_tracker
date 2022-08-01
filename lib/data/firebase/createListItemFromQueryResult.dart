import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';
import 'package:photo_tracker/data/listItem.dart';
import 'package:photo_tracker/data/firebase/firebasePost.dart';

/// Read firebase images list based on postID and return a List of List items to be displayed on the map
class CreateListItemFromQueryResult {
  fireTest() async {
    List<ListItem> imagesList = [];

    QuerySnapshot postImages = await FirebasePost().getPostImages('postID');
    for (var element in postImages.docs) {
      imagesList.add(ListItem(
          latLng: LatLng(00, 00),
          timestamp: DateTime.fromMicrosecondsSinceEpoch(00),
          imgPath: element.get('firestorePath'),
          locationError: false,
          timeError: true));
    }

    return imagesList;
  }
}
