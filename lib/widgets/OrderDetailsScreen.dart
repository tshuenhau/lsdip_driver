import 'package:flutter/material.dart';

class OrderDetailsScreen extends StatelessWidget {
  OrderDetailsScreen({required this.orderId, super.key});

  String orderId;

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(orderId));
  }
}
