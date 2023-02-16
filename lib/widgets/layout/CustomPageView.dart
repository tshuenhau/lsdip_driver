import 'dart:ui';

import 'package:flutter/material.dart';

class CustomPageView extends StatefulWidget {
  CustomPageView(
      {Key? key,
      required this.pageController,
      required List<Widget> navScreens,
      required this.onPageChanged})
      : _navScreens = navScreens,
        super(key: key);

  final List<Widget> _navScreens;
  PageController pageController;
  Function onPageChanged;

  @override
  State<CustomPageView> createState() => _CustomPageViewState();
}

class _CustomPageViewState extends State<CustomPageView> {
  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: widget.pageController,
      onPageChanged: (index) {
        widget.onPageChanged(index);
      },
      children: widget._navScreens,
    );
  }
}
