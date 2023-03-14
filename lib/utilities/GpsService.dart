import 'dart:math' show cos, sqrt, asin;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

class GpsService {
  late double lat = 0;
  late double long = 0;
  late GeoPoint prevLocation;
  late GeoPoint currLocation;
  final Location location = Location();

  void initLocation() async {
    LocationData locationData = await location.getLocation();
    prevLocation = GeoPoint(locationData.latitude!, locationData.longitude!);
    currLocation = GeoPoint(locationData.latitude!, locationData.longitude!);
  }

  double calculateDistance(lat1, lon1, lat2, lon2) {
    //!Return value is in KM i think.
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }
}
