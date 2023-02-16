import 'package:flutter/material.dart';
import 'package:lsdip_driver/screens/OrdersScreen.dart';
import 'package:lsdip_driver/screens/VehicleScreen.dart';
import 'package:lsdip_driver/widgets/layout/CustomBottomNavigationBar.dart';
import 'package:lsdip_driver/widgets/layout/CustomPageView.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  late PageController _pageController;
  int _selectedIndex = 0;

  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  final List<Widget> _navScreens = [
    const OrdersScreen(),
    const VehicleScreen()
  ];
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
