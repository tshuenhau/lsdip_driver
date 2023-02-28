import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:lsdip_driver/screens/OrdersScreen.dart';
import 'package:lsdip_driver/screens/VehicleScreen.dart';
import 'package:lsdip_driver/widgets/layout/CustomBottomNavigationBar.dart';
import 'package:lsdip_driver/widgets/layout/CustomPageView.dart';

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

          var ref = db.collection("vehicles").doc(widget.vehicleId);
          // print(vehicleRef);
          ref.update({"location": GeoPoint(lat, long)});
        });
      }
      print(lat.toString() + "   " + long.toString());
      print("count" + count.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
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
