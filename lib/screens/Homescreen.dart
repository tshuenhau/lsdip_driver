import 'package:awesome_select/awesome_select.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:lsdip_driver/screens/OrdersScreen.dart';
import 'package:lsdip_driver/screens/VehicleScreen.dart';
import 'package:lsdip_driver/widgets/OrderScanner.dart';
import 'package:lsdip_driver/widgets/layout/CustomBottomNavigationBar.dart';
import 'package:lsdip_driver/widgets/layout/CustomPageView.dart';
import 'dart:math' show cos, sqrt, asin;

import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart'
    as PermissionHandler;

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
  late GeoPoint prevLocation;
  late GeoPoint currLocation;
  late int count = 0;
  late List outlets = [];
  late bool _serviceEnabled;
  // late PermissionStatus _permissionGranted;
  late String outletId = "";
  late String outletName = "";
  double totalDistance = 0;

  late PermissionStatus _permissionGranted;

//!BUG: TOtal distance on app startup might be super large/wrong.
  double calculateDistance(lat1, lon1, lat2, lon2) {
    //!Return value is in KM i think.
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  // List<GeoPoint> points = [];

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

  Future<bool> checkLocation() async {
    var status = await PermissionHandler.Permission.location.request();
    if (status.isPermanentlyDenied) {
      // The user opted to never again see the permission request dialog for this
      // app. The only way to change the permission's status now is to let the
      // user manually enable it in the system settings.
      print("isPermanentlyDenied");
      PermissionHandler.openAppSettings();
      status = await PermissionHandler.Permission.location.status;
      return status.isGranted;
    }
    if (status.isDenied) {
      print("isDenied");
      // Either the permission was already granted before or the user just granted it.
      return false;
    }
    return true;
  }

  void initializeLocation() async {
    // if (await Permission.location.isDenied) {
    //   print("denied");
    //   // The user opted to never again see the permission request dialog for this
    //   // app. The only way to change the permission's status now is to let the
    //   // user manually enable it in the system settings.
    //   await openAppSettings(); //TODO: Open modal to tell them they need to grant permission
    // } else if (await Permission.location.isPermanentlyDenied) {
    //   // The user opted to never again see the permission request dialog for this
    //   // app. The only way to change the permission's status now is to let the
    //   print("permanently denied");
    //   // user manually enable it in the system settings.
    //   await openAppSettings();
    // }
    // if (!await Permission.location.isGranted) {
    //   return;
    // }

    // _serviceEnabled = await location.serviceEnabled();
    // if (!_serviceEnabled) {
    //   _serviceEnabled = await location.requestService();
    //   if (!_serviceEnabled) {
    //     return;
    //   }
    // }

    // _permissionGranted = await location.hasPermission();
    // if (_permissionGranted == PermissionStatus.denied) {
    //   _permissionGranted = await location.requestPermission();
    //   if (_permissionGranted != PermissionStatus.granted) {
    //     return;
    //   }
    // }

    bool checkPermission = await checkLocation();
    if (!checkPermission) {
      return;
    }
    location.changeSettings(
        accuracy: LocationAccuracy.high, interval: 3000, distanceFilter: 5);
    LocationData locationData = await location.getLocation();

    prevLocation = GeoPoint(locationData.latitude!, locationData.longitude!);
    currLocation = GeoPoint(locationData.latitude!, locationData.longitude!);
  }

  @override
  initState() {
    super.initState();
    _pageController = PageController();
    initializeLocation();
    var tempOutlets;

    db.collection("outlet").get().then(
      (querySnapshot) {
        print("Successfully completed");
        var outlets = querySnapshot.docs.map((DocumentSnapshot document) {
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          data["outletId"] = document.id;
          return data;
        }).toList();
        tempOutlets = outlets;
      },
      onError: (e) => print("Error completing: $e"),
    );

    location.onLocationChanged.listen((event) {
      if (mounted) {
        setState(() {
          outlets = tempOutlets;
          lat = event.latitude!;
          long = event.longitude!;
          prevLocation = currLocation;
          currLocation = GeoPoint(lat, long);

          if (currLocation != prevLocation) {
            final Distance distance = Distance();

            // km = 423
            final double km = distance(
                LatLng(prevLocation.latitude, prevLocation.longitude),
                LatLng(currLocation.latitude, currLocation.longitude));
            // print("latlong total distance " + km.toString());

            double totalDistance = calculateDistance(
                prevLocation.latitude,
                prevLocation.longitude,
                currLocation.latitude,
                currLocation.longitude);
            // print("total distance " + totalDistance.toString());
            var ref = db.collection("vehicles").doc(widget.vehicleId);
            const source = Source.cache;
            ref.get(const GetOptions(source: source)).then(
              (res) {
                ref.update({
                  "location": currLocation,
                  "mileage": totalDistance + res.get("mileage")
                });

                print(res.get("mileage").toString());
              },
              onError: (e) => print("Error completing: $e"),
            );
          }

          count += 1;
        });
      }

      print("count" + count.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    // for (var i = 0; i < points.length - 1; i++) {
    //   setState(() {
    //     totalDistance += calculateDistance(
    //         points[i].latitude,
    //         points[i].longitude,
    //         points[i + 1].latitude,
    //         points[i + 1].longitude);
    //   });
    // }
    // print(totalDistance);
    List<Widget> _navScreens = [
      OrdersScreen(lat: lat, long: long),
      VehicleScreen(vehicleId: widget.vehicleId)
    ];

    return Scaffold(
      appBar: AppBar(
        title:
            Text(outletName == "" ? "Please select an outlet -->" : outletName),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (_) => SimpleDialog(
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0))),
                        contentPadding: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height * 1 / 100,
                            bottom:
                                MediaQuery.of(context).size.height * 2 / 100),
                        title: Text('Select Outlet'),
                        children: buildOutletOptions(context)));
                // setState(() {
                //   outletId = outlets.isNotEmpty ? outlets[1]["outletId"] : "";
                // });
              },
              icon: Icon(Icons.filter_list))
        ],
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height * 0 / 100),
        child: FloatingActionButton(
          elevation: 4.0,
          child: const Icon(Icons.qr_code),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => OrderScanner()),
            );
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
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

  List<Widget> buildOutletOptions(BuildContext context) {
    final choices = outlets
        .map(
          (e) => SimpleDialogOption(
            onPressed:

                //  outletId == e["outletId"]
                //     ? null
                //     :

                () {
              setState(() {
                outletId = e["outletId"];
                outletName = e["outletName"];
              });
              Navigator.of(context).pop();
            },
            child: SizedBox(
                height: MediaQuery.of(context).size.height * 3 / 100,
                child: Text(e["outletName"])),
          ),
        )
        .toList();
    print("choices: " + choices.toString());

    return choices;
  }
}
