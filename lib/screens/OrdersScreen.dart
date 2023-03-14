import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:location/location.dart';

//TODO: Get list of orders from firestore based on current time ig? >12pm = PM shift
class OrdersScreen extends StatefulWidget {
  OrdersScreen({required this.lat, required this.long, super.key});
  double lat;
  double long;
  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  // final Location location = Location();

  // Future<LocationData> getLocation() async {
  //   return await location.getLocation();
  // }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Container(
            child: Text("lat: " +
                widget.lat.toString() +
                ", " +
                "long: " +
                widget.long.toString())));
  }
}
