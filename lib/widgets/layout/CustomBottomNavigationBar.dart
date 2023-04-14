import 'package:flutter/material.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  CustomBottomNavigationBar(
      {Key? key, required this.pageController, required this.selectedIndex})
      : super(key: key);
  late PageController pageController;
  int selectedIndex = 0;

  @override
  State<CustomBottomNavigationBar> createState() =>
      _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  //int _selectedIndex = 0;
  double roundedRadius = 20;

  void _onItemTapped(int index) {
    setState(() {
      widget.selectedIndex = index;
      widget.pageController.animateToPage(index,
          duration: const Duration(milliseconds: 350), curve: Curves.easeOut);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        backgroundBlendMode: BlendMode.clear,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(roundedRadius),
          topRight: Radius.circular(roundedRadius),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black38, spreadRadius: 0, blurRadius: 2),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(roundedRadius),
          topRight: Radius.circular(roundedRadius),
        ),
        child: SizedBox(
          height: MediaQuery.of(context).size.height *
              8 /
              100, //TODO Maybe need to make this more fixed/have min-max vals
          child: BottomNavigationBar(
            backgroundColor: Colors.white,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.inventory),
                label: 'Orders',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.local_shipping),
                label: 'Pickups',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.account_circle),
                label: 'Account',
              ),
              // BottomNavigationBarItem(
              //   icon: Icon(Icons.emoji_events),
              //   label: 'Rewards',
              // ),
            ],
            currentIndex: widget.selectedIndex,
            onTap: _onItemTapped,
          ),
        ),
      ),
    );
  }
}
