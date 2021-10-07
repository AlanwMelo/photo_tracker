import 'package:latlong2/latlong.dart';
import 'package:photo_tracker/classes/listItem.dart';

class CreateListItemFromQueryResult {
  create(var element) {
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
  }
}
