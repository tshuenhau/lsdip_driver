import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:location/location.dart';

//!https://stackoverflow.com/questions/65516604/flutter-stream-location-and-user-data-to-firestore
class OrdersScreen extends StatefulWidget {
  OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final Location location = Location();
  late double lat;
  late double long;

  Future<LocationData> getLocation() async {
    return await location.getLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: FutureBuilder(
            future: getLocation(),
            builder:
                (BuildContext context, AsyncSnapshot<LocationData> snapshot) {
              if (snapshot.hasData) {
                return Text(snapshot.data.toString());
              } else {
                return Container();
              }
            }));
  }
}
