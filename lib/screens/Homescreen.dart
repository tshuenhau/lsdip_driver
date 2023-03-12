import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:lsdip_driver/screens/OrdersScreen.dart';
import 'package:lsdip_driver/screens/VehicleScreen.dart';
import 'package:lsdip_driver/widgets/layout/CustomBottomNavigationBar.dart';
import 'package:lsdip_driver/widgets/layout/CustomPageView.dart';
import 'dart:math' show cos, sqrt, asin;

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
  late int count = 0;
  double totalDistance = 0;

  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  List<GeoPoint> points = [];

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

  @override
  initState() {
    super.initState();
    _pageController = PageController();

    location.onLocationChanged.listen((event) {
      if (mounted) {
        setState(() {
          lat = event.latitude!;
          long = event.longitude!;
          count += 1;
          GeoPoint currPoint = GeoPoint(lat, long);
          if (points.isEmpty) {
            points.add(currPoint);
          } else if (points.isNotEmpty && points.last != currPoint) {
            points.add(currPoint);
          }
          var ref = db.collection("vehicles").doc(widget.vehicleId);
          ref.update({"location": currPoint, "mileage": totalDistance});
        });
      }
      print(lat.toString() + "   " + long.toString());
      for (GeoPoint point in points) {
        print(point.latitude.toString() + ", " + point.longitude.toString());
      }
      // print(points.toString());
      print("count" + count.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    for (var i = 0; i < points.length - 1; i++) {
      setState(() {
        totalDistance += calculateDistance(
            points[i].latitude,
            points[i].longitude,
            points[i + 1].latitude,
            points[i + 1].longitude);
      });
    }
    print(totalDistance);
    List<Widget> _navScreens = [
      OrdersScreen(lat: lat, long: long),
      VehicleScreen(vehicleId: widget.vehicleId)
    ];

    return Scaffold(
      appBar: AppBar(title: Text("Driver")),
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
