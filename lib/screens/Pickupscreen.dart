import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:lsdip_driver/utilities/OrderService.dart';
import 'package:lsdip_driver/widgets/OrderDetailsTile.dart';
import 'package:maps_launcher/maps_launcher.dart';

class Pickupscreen extends StatefulWidget {
  Pickupscreen({required this.time, super.key});
  String time;
  @override
  State<Pickupscreen> createState() => _PickupscreenState();
}

class _PickupscreenState extends State<Pickupscreen> {
  // List availablePickups = [];
  FirebaseFirestore db = FirebaseFirestore.instance;
  // String time = DateFormat('yyyy-MM-dd').format(DateTime.now());

  // String time = "2023-05-06";
  late Stream<DocumentSnapshot> pickupOrdersStream =
      db.collection("pickup_orders").doc(widget.time).snapshots();
  late Stream<QuerySnapshot> pickupDriverStream =
      db.collection("pickup_driver").snapshots();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: pickupOrdersStream,
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        var pickup_orders;
        // List allPickups = [];

        List availablePickups = [];
        List myPickups = [];
        List completedPickups = [];

        if (snapshot.connectionState == ConnectionState.active) {
          if (!snapshot.data!.exists) {
            return Center(
                child: Container(child: Text("No Pickups For Today")));
          }
          var data = snapshot.data as DocumentSnapshot;
          pickup_orders = data;

          if (pickup_orders["date"] != null) {
            for (var pickup in pickup_orders["selected_times"]) {
              // allPickups.add(pickup);
              if (pickup["driver"] == null) {
                availablePickups.add(pickup);
              } else if (pickup["driver"] ==
                      FirebaseAuth.instance.currentUser!.uid &&
                  pickup["status"] == null) {
                myPickups.add(pickup);
              } else {
                completedPickups.add(pickup);
              }
            }
          }

          // allPickups = OrderService().sortPickupsByTime(allPickups);
          availablePickups = OrderService().sortPickupsByTime(availablePickups);
          myPickups = OrderService().sortPickupsByTime(myPickups);

          return SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Card(
                    elevation: 2,
                    color: Colors.teal.shade100,
                    child: Container(
                        height: MediaQuery.of(context).size.height * 5 / 100,
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          child: Center(
                              child: Text(
                                  "My Pickups (" +
                                      myPickups.length.toString() +
                                      ")",
                                  style:
                                      TextStyle(
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              2 /
                                              100,
                                          fontWeight: FontWeight.bold))),
                        )),
                  ),
                  (myPickups.length < 1
                      ? Card(
                          elevation: 0,
                          child: SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 5 / 100,
                              child: Center(child: Text("No Pickups Found"))),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: myPickups.length,
                          itemBuilder: (BuildContext context, int index) {
                            var currentPickup = myPickups[index];

                            return InkWell(
                              onTap: () {
                                showModalBottomSheet<void>(
                                  isScrollControlled: true,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  context: context,
                                  builder: (BuildContext context) {
                                    return ClipRRect(
                                      borderRadius: BorderRadius.circular(10.0),
                                      child: SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                60 /
                                                100,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Container(
                                              color: Colors.blue.shade400,
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  8 /
                                                  100,
                                              child: Center(
                                                child: Text("Pickup Details",
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height *
                                                            2.5 /
                                                            100,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                              ),
                                            ),
                                            SizedBox(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    2.5 /
                                                    100),
                                            OrderDetailsTile(
                                                title: "Address",
                                                value:
                                                    (currentPickup["address"] ==
                                                            ""
                                                        ? "No Address"
                                                        : currentPickup[
                                                            "address"])),
                                            OrderDetailsTile(
                                                title: "Name",
                                                value: (currentPickup["name"] ==
                                                        ""
                                                    ? "No Name"
                                                    : currentPickup["name"])),
                                            OrderDetailsTile(
                                                title: "Number",
                                                value: (currentPickup[
                                                            "number"] ==
                                                        ""
                                                    ? "No Number"
                                                    : currentPickup["number"])),
                                            OrderDetailsTile(
                                                title: "Time",
                                                value: (currentPickup["time"])),
                                            SizedBox(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    2.5 /
                                                    100),
                                            Column(
                                              children: [
                                                ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.green,
                                                  ),
                                                  child: SizedBox(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            30 /
                                                            100,
                                                    child: Center(
                                                      child: const Text(
                                                          'Navigate'),
                                                    ),
                                                  ),
                                                  onPressed: () {
                                                    MapsLauncher.launchQuery(
                                                        currentPickup[
                                                            "address"]);
                                                  },
                                                ),
                                                ElevatedButton(
                                                  child: SizedBox(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            30 /
                                                            100,
                                                    child: Center(
                                                      child: const Text(
                                                          'Confirm Pickup'),
                                                    ),
                                                  ),
                                                  onPressed: () {
                                                    currentPickup["status"] = 1;

                                                    myPickups[index] =
                                                        currentPickup;

                                                    db
                                                        .collection(
                                                            "pickup_orders")
                                                        .doc(widget.time)
                                                        .update({
                                                      "selected_times":
                                                          availablePickups +
                                                              myPickups +
                                                              completedPickups
                                                    });

                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                                // ElevatedButton(
                                                //   style:
                                                //       ElevatedButton.styleFrom(
                                                //     backgroundColor: Colors.red,
                                                //   ),
                                                //   child: SizedBox(
                                                //     width:
                                                //         MediaQuery.of(context)
                                                //                 .size
                                                //                 .width *
                                                //             30 /
                                                //             100,
                                                //     child: Center(
                                                //       child: const Text(
                                                //           'Cancel Delivery'),
                                                //     ),
                                                //   ),
                                                //   onPressed: () {
                                                //     Navigator.of(context).pop();
                                                //   },
                                                // ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                              child: Card(
                                  elevation: 1,
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical:
                                            MediaQuery.of(context).size.height *
                                                1 /
                                                100),
                                    child: ListTile(
                                      // Text(currentOrder[
                                      //     "orderId"]),
                                      title: Text(currentPickup["time"]),
                                      subtitle: Text(
                                          currentPickup["address"].length > 0
                                              ? currentPickup["address"]
                                              : "No address"),
                                    ),
                                  )),
                            );
                          })),
                  Card(
                    elevation: 2,
                    color: Colors.blue.shade100,
                    child: Container(
                        height: MediaQuery.of(context).size.height * 5 / 100,
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          child: Center(
                              child: Text(
                                  "Available Pickups (" +
                                      availablePickups.length.toString() +
                                      ")",
                                  style: TextStyle(
                                      fontSize:
                                          MediaQuery.of(context).size.height *
                                              2 /
                                              100,
                                      fontWeight: FontWeight.bold))),
                        )),
                  ),
                  (availablePickups.length < 1
                      ? Card(
                          elevation: 0,
                          child: SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 5 / 100,
                              child: Center(
                                  child: Text("No Available Pickups Found"))),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: availablePickups.length,
                          itemBuilder: (BuildContext context, int index) {
                            var currentPickup = availablePickups[index];

                            return InkWell(
                              onTap: () {
                                showModalBottomSheet<void>(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  context: context,
                                  builder: (BuildContext context) {
                                    return ClipRRect(
                                      borderRadius: BorderRadius.circular(10.0),
                                      child: SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                80 /
                                                100,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Container(
                                              color: Colors.blue.shade400,
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  8 /
                                                  100,
                                              child: Center(
                                                child: Text("Pickup Details",
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height *
                                                            2.5 /
                                                            100,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                              ),
                                            ),
                                            SizedBox(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    2.5 /
                                                    100),
                                            OrderDetailsTile(
                                                title: "Address",
                                                value:
                                                    (currentPickup["address"] ==
                                                            ""
                                                        ? "No Address"
                                                        : currentPickup[
                                                            "address"])),
                                            OrderDetailsTile(
                                                title: "Name",
                                                value: (currentPickup["name"] ==
                                                        ""
                                                    ? "No Name"
                                                    : currentPickup["name"])),
                                            OrderDetailsTile(
                                                title: "Number",
                                                value: (currentPickup[
                                                            "number"] ==
                                                        ""
                                                    ? "No Number"
                                                    : currentPickup["number"])),
                                            OrderDetailsTile(
                                                title: "Time",
                                                value: (currentPickup["time"])),
                                            SizedBox(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    2.5 /
                                                    100),
                                            Column(
                                              children: [
                                                ElevatedButton(
                                                  child: SizedBox(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            30 /
                                                            100,
                                                    child: Center(
                                                      child: const Text(
                                                          'Select Pickup'),
                                                    ),
                                                  ),
                                                  onPressed: () {
                                                    var newPickup =
                                                        currentPickup[
                                                                "driver"] =
                                                            FirebaseAuth
                                                                .instance
                                                                .currentUser!
                                                                .uid;
                                                    availablePickups[index] =
                                                        currentPickup;

                                                    db
                                                        .collection(
                                                            "pickup_orders")
                                                        .doc(widget.time)
                                                        .update({
                                                      "selected_times":
                                                          availablePickups +
                                                              myPickups +
                                                              completedPickups
                                                    });

                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                              child: Card(
                                  elevation: 1,
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical:
                                            MediaQuery.of(context).size.height *
                                                1 /
                                                100),
                                    child: ListTile(
                                      // Text(currentOrder[
                                      //     "orderId"]),
                                      title: Text(currentPickup["time"]),
                                      subtitle: Text(
                                          currentPickup["address"].length > 0
                                              ? currentPickup["address"]
                                              : "No address"),
                                    ),
                                  )),
                            );
                          }))
                ],
              ));
        }
        return const CircularProgressIndicator();
      },
    );
  }
}
