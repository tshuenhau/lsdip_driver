import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:lsdip_driver/screens/OrdersScreen.dart';
import 'package:lsdip_driver/screens/VehicleScreen.dart';
import 'package:lsdip_driver/widgets/layout/CustomBottomNavigationBar.dart';
import 'package:lsdip_driver/widgets/layout/CustomPageView.dart';

class Homescreen extends StatefulWidget {
  Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  final Location location = Location();
  late double lat;
  late double long;
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
          //TODO: upload lat long to firestore
        });
      }
      print(lat.toString() + "   " + long.toString());
      print("count" + count.toString());
    });
  }

  final List<Widget> _navScreens = [OrdersScreen(), const VehicleScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
