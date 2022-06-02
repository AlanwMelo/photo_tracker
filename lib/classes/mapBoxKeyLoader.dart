import 'dart:convert';

import 'package:flutter/cupertino.dart';

class MapBoxKeyLoader {
  final BuildContext context;

  MapBoxKeyLoader({required this.context});

  loadKey() async {
    String data = await DefaultAssetBundle.of(context)
        .loadString('lib/assets/mapboxKey.json');
    final jsonResult = jsonDecode(data);

    return jsonResult['mapboxKey'];
  }
}
