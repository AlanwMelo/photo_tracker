import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';
import 'package:photo_tracker/data/listItem.dart';
import 'package:photo_tracker/data/firebase/firebasePost.dart';

/// Read firebase images list based on postID and return a List of List items to be displayed on the map
class CreateListItemFromQueryResult {
  fireTest(String postID) async {
    List<ListItem> imagesList = [];

    QuerySnapshot postImages = await FirebasePost().getPostImages(postID);
    for (var element in postImages.docs) {
      GeoPoint geoPoint = element.get('latLong');
      imagesList.add(ListItem(
          latLng: LatLng(geoPoint.latitude, geoPoint.longitude),
          timestamp: DateTime.fromMillisecondsSinceEpoch(
              element.get('timestamp').millisecondsSinceEpoch),
          imgPath: element.get('firestorePath'),
          locationError: element.get('locationError'),
          timeError: element.get('timeError')));
    }

    return imagesList;
  }
}
