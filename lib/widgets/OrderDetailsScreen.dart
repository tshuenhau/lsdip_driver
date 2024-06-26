import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lsdip_driver/widgets/OrderDetailsTile.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:permission_handler/permission_handler.dart'
    as PermissionHandler;

class OrderDetailsScreen extends StatefulWidget {
  OrderDetailsScreen({required this.orderId, required this.time, super.key});

  String orderId;
  String time;
  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  FirebaseFirestore db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    print("date" + widget.time);
    // String time = "2023-05-26";

    final orderRef = db.collection("orders").doc(widget.orderId);
    final orderDriverRef = db.collection("order_driver").doc(widget.orderId);
    final shiftOrdersRef = db.collection("shift_orders");
    var shift_orders;

    // final order_driverRef = db.collection("order_driver").doc(widget.orderId);
    // order_driverRef.get().then(
    //   (DocumentSnapshot doc) {
    //     final data = doc.data() as Map<String, dynamic>;
    //     print("order driver: " + data.toString());
    //     return Scaffold(body: Text("Already Taken"));
    //     // ...
    //   },
    //   onError: (e) => print("Error getting document: $e"),
    // );

    return Scaffold(
      appBar: AppBar(title: Text("Driver"), automaticallyImplyLeading: false),
      body: FutureBuilder<DocumentSnapshot>(
        future: orderRef.get(),
        builder: (_, snapshot) {
          if (snapshot.hasError) return Text('Error = ${snapshot.error}');
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: const CircularProgressIndicator());
          }

          final order = snapshot.data!.data() as Map<String, dynamic>?;

          if (order == null) {
            return Center(child: Text("Order not found"));
          }
          order["orderId"] = snapshot.data!.id;

          return FutureBuilder<QuerySnapshot>(
              future: shiftOrdersRef.get(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return Text('Error = ${snapshot.error}');
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                var shiftOrders =
                    snapshot.data!.docs.map((DocumentSnapshot document) {
                  Map<String, dynamic> data =
                      document.data()! as Map<String, dynamic>;
                  data["date"] = document.id;
                  return data;
                }).toList();
                // print("Order: " + order.toString());
                for (var shiftOrder in shiftOrders) {
                  // print(shiftOrder["date"].toString());
                  if (shiftOrder["selected_times"] != null &&
                      shiftOrder["selected_times"].length > 0) {
                    for (var selectedTime in shiftOrder["selected_times"]) {
                      print("ORDERS: " +
                          selectedTime["orders"].toString()); //This an array
                      print("TIME: " + selectedTime["time"].toString());

                      for (var deliveryId in selectedTime["orders"]) {
                        if (deliveryId == order["orderId"]) {
                          print("Selected Time: " + selectedTime["time"]);
                          order["timing"] = selectedTime["time"];
                          order["deliveryDate"] = shiftOrder["date"];
                        }
                      }
                    }
                  }
                }

                // print("nweiugthiwerg" + order["time"]);

                return FutureBuilder<DocumentSnapshot>(
                    future: orderDriverRef.get(),
                    builder: (_, snapshot) {
                      if (snapshot.hasError)
                        return Text('Error = ${snapshot.error}');
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: const CircularProgressIndicator());
                      }

                      final orderDriver =
                          snapshot.data!.data() as Map<String, dynamic>?;

                      // print("DELIVERY DATE: " +
                      //     order["deliveryDate"].seconds.toString());

                      // print(DateTime.fromMillisecondsSinceEpoch(
                      //     order["deliveryDate"].seconds * 1000));

                      String date = "";
                      if (order["deliveryDate"] is String) {
                        date = order["deliveryDate"];
                      } else {
                        date = DateFormat('yyyy-MM-dd').format(
                            DateTime.fromMillisecondsSinceEpoch(
                                order["deliveryDate"].seconds * 1000));
                      }
                      return SizedBox(
                        height: MediaQuery.of(context).size.height,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Card(
                                    color: Colors.amberAccent.shade100,
                                    child: Container(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                5 /
                                                100,
                                        child: Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: Center(
                                              child: Text("Order Details",
                                                  style: TextStyle(
                                                      fontSize:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              2 /
                                                              100,
                                                      fontWeight:
                                                          FontWeight.bold))),
                                        )),
                                  ),
                                  OrderDetailsTile(
                                      title: "Order ID: ",
                                      value: order["orderId"] ?? ''),
                                  OrderDetailsTile(
                                      title: "Customer Name: ",
                                      value: order["customerName"] ?? ''),
                                  OrderDetailsTile(
                                      title: "Customer Number: ",
                                      value: order["customerNumber"] ?? ''),
                                  OrderDetailsTile(
                                      title: "Address: ",
                                      value: order["customerAddress"] ?? ''),
                                  OrderDetailsTile(
                                      title: "Date: ", value: date),

                                  //! this is where the error is
                                  OrderDetailsTile(
                                      title: "Time: ",
                                      value: order["timing"] ?? ''),
                                ],
                              ),
                            ),
                            SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 20 / 100,
                              child: Column(
                                children: buildButtons(
                                    orderDriver, context, order, date),
                              ),
                            ),
                          ],
                        ),
                      );
                    });
              });
        },
      ),
    );
  }

  List<Widget> buildButtons(Map<String, dynamic>? orderDriver,
      BuildContext context, Map<String, dynamic> order, String date) {
    bool canSelect = false;
    bool canDeliver = false;
    if (order["timing"] != null && date == widget.time) {
      print(order.toString() + "EBUGiu");
      canSelect = true;
    }

    if (order["orderStatus"] == "Out for Delivery") {
      canDeliver = true;
    }
    // print("TIMING: " + order["timing"]!);

    return orderDriver != null
        ? ((orderDriver["driverId"] != FirebaseAuth.instance.currentUser!.uid)
            ? [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Warning: not your delivery*",
                      style: TextStyle(
                          color: Colors.red, fontWeight: FontWeight.bold)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 20 / 100,
                    child: Center(
                      child: Text('Take over',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  onPressed: () {
                    db.collection("orders").doc(order["orderId"]).update(
                        {"driverId": FirebaseAuth.instance.currentUser!.uid});
                    db.collection("order_driver").doc(order["orderId"]).update(
                        {"driverId": FirebaseAuth.instance.currentUser!.uid});

                    // db.collection("order_driver").doc(order["orderId"]).set({
                    //   "orderId": order["orderId"],
                    //   "driverId": FirebaseAuth.instance.currentUser!.uid,
                    //   "status":
                    //       0 //! 0 = being delivered , 1 = delivered, -1 = failed to deliver
                    // }).onError((e, _) => print("Error writing document: $e"));

                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 20 / 100,
                    child: Center(
                      child: const Text('Back'),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ]
            : !canDeliver
                ? [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 5 / 100,
                      child: Center(
                        child: Text("Has already been delivered.",
                            style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 30 / 100,
                        child: Center(
                          child: const Text('Back'),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ]
                : [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 30 / 100,
                        child: Center(
                          child: const Text('Navigate'),
                        ),
                      ),
                      onPressed: () {
                        MapsLauncher.launchQuery(order["customerAddress"]);
                      },
                    ),
                    ElevatedButton(
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 30 / 100,
                        child: Center(
                          child: const Text('Confirm Delivery'),
                        ),
                      ),
                      onPressed: () {
                        db
                            .collection("orders")
                            .doc(order["orderId"])
                            .update({"orderStatus": "Delivered"});
                        db
                            .collection("order_driver")
                            .doc(order["orderId"])
                            .set({
                          "orderId": order["orderId"],
                          "driverId": FirebaseAuth.instance.currentUser!.uid,
                          "status":
                              1 //! 0 = being delivered , 1 = delivered, -1 = failed to deliver
                        }).onError(
                                (e, _) => print("Error writing document: $e"));

                        Navigator.of(context).pop();
                      },
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 30 / 100,
                        child: Center(
                          child: const Text('Back'),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ])
        : [
            canSelect
                ? ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 20 / 100,
                      child: Center(
                        child: Text('Select order',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    onPressed: () {
                      db
                          .collection("orders")
                          .doc(order["orderId"])
                          .update({"orderStatus": "Out for Delivery"});
                      db.collection("order_driver").doc(order["orderId"]).set({
                        "orderId": order["orderId"],
                        "driverId": FirebaseAuth.instance.currentUser!.uid,
                        "status":
                            0 //! 0 = being delivered , 1 = delivered, -1 = failed to deliver
                      }).onError((e, _) => print("Error writing document: $e"));

                      Navigator.of(context).pop();
                    },
                  )
                : date != widget.time
                    ? Container(
                        height: MediaQuery.of(context).size.height * 5 / 100,
                        child: Center(
                          child: Text("Not scheduled to be delivered today",
                              style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold)),
                        ),
                      )
                    : Container(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 20 / 100,
                child: Center(
                  child: const Text('Back'),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ];
  }
}
