import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:location/location.dart';

class OrdersScreen extends StatelessWidget {
  OrdersScreen({super.key});
  final Location location = Location();

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
