import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:lsdip_driver/screens/OrdersScreen.dart';
import 'package:lsdip_driver/screens/VehicleScreen.dart';
import 'package:lsdip_driver/widgets/OrderScanner.dart';
import 'package:lsdip_driver/widgets/layout/CustomBottomNavigationBar.dart';
import 'package:lsdip_driver/widgets/layout/CustomPageView.dart';
import 'dart:math' show cos, sqrt, asin;

import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';

class Homescreen extends StatefulWidget {
  Homescreen({required this.vehicleId, super.key});
  String vehicleId;

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  FirebaseFirestore db = FirebaseFirestore.instance;

  final Location location = Location();
  late double lat = 0;
  late double long = 0;
  late GeoPoint prevLocation;
  late GeoPoint currLocation;
  late int count = 0;

  late bool _serviceEnabled;
  // late PermissionStatus _permissionGranted;

  double totalDistance = 0;
//!BUG: TOtal distance on app startup might be super large/wrong.
  double calculateDistance(lat1, lon1, lat2, lon2) {
    //!Return value is in KM i think.
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  // List<GeoPoint> points = [];

  late PageController _pageController;
  int _selectedIndex = 0;

  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();

    super.dispose();
  }

  void initializeLocation() async {
    if (await Permission.location.isDenied) {
      print("denied");
      // The user opted to never again see the permission request dialog for this
      // app. The only way to change the permission's status now is to let the
      // user manually enable it in the system settings.
      await openAppSettings(); //TODO: Open modal to tell them they need to grant permission
    } else if (await Permission.location.isPermanentlyDenied) {
      // The user opted to never again see the permission request dialog for this
      // app. The only way to change the permission's status now is to let the
      print("permanently denied");
      // user manually enable it in the system settings.
      await openAppSettings();
    }
    if (!await Permission.location.isGranted) {
      return;
    }
    location.changeSettings(
        accuracy: LocationAccuracy.high, interval: 3000, distanceFilter: 5);
    LocationData locationData = await location.getLocation();

    prevLocation = GeoPoint(locationData.latitude!, locationData.longitude!);
    currLocation = GeoPoint(locationData.latitude!, locationData.longitude!);
  }

  @override
  initState() {
    super.initState();
    _pageController = PageController();
    initializeLocation();

    location.onLocationChanged.listen((event) {
      if (mounted) {
        setState(() {
          lat = event.latitude!;
          long = event.longitude!;
          prevLocation = currLocation;
          currLocation = GeoPoint(lat, long);

          if (currLocation != prevLocation) {
            final Distance distance = Distance();

            // km = 423
            final double km = distance(
                LatLng(prevLocation.latitude, prevLocation.longitude),
                LatLng(currLocation.latitude, currLocation.longitude));
            // print("latlong total distance " + km.toString());

            double totalDistance = calculateDistance(
                prevLocation.latitude,
                prevLocation.longitude,
                currLocation.latitude,
                currLocation.longitude);
            // print("total distance " + totalDistance.toString());
            var ref = db.collection("vehicles").doc(widget.vehicleId);
            const source = Source.cache;
            ref.get(const GetOptions(source: source)).then(
              (res) {
                ref.update({
                  "location": currLocation,
                  "mileage": totalDistance + res.get("mileage")
                });

                print(res.get("mileage").toString());
              },
              onError: (e) => print("Error completing: $e"),
            );
          }

          count += 1;
        });
      }

      print("count" + count.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    // for (var i = 0; i < points.length - 1; i++) {
    //   setState(() {
    //     totalDistance += calculateDistance(
    //         points[i].latitude,
    //         points[i].longitude,
    //         points[i + 1].latitude,
    //         points[i + 1].longitude);
    //   });
    // }
    // print(totalDistance);
    List<Widget> _navScreens = [
      OrdersScreen(lat: lat, long: long),
      VehicleScreen(vehicleId: widget.vehicleId)
    ];

    return Scaffold(
      appBar: AppBar(title: Text("Driver"), automaticallyImplyLeading: false),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height * 3 / 100),
        child: FloatingActionButton(
          elevation: 4.0,
          child: const Icon(Icons.add),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => OrderScanner()),
            );
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: CustomPageView(
        navScreens: _navScreens,
        pageController: _pageController,
        onPageChanged: _onPageChanged,
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        pageController: _pageController,
        selectedIndex: _selectedIndex,
      ),
    );
  }
}
