import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';
import 'package:photo_tracker/business_logic/firebase/firebasePost.dart';
import 'package:photo_tracker/classes/listItem.dart';

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

/*create(var element) {
    bool locationError =
        element['locationError'].toString().toLowerCase() == 'true';
    bool timeError = element['timeError'].toString().toLowerCase() == 'true';

    ListItem listItem = ListItem(
        LatLng(double.parse(element['latitude'].toString()),
            double.parse(element['longitude'].toString())),
        DateTime.fromMillisecondsSinceEpoch(
            double.parse(element['timestamp'].toString()).ceil()),
        element['imgPath'].toString(),
        locationError,
        timeError);

    return listItem;
  }*/
}
