import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:lsdip_driver/utilities/OrderService.dart';
import 'package:lsdip_driver/widgets/OrderDetailsTile.dart';
import 'package:maps_launcher/maps_launcher.dart';

class OrdersScreen extends StatefulWidget {
  OrdersScreen(
      {required this.outletId,
      required this.lat,
      required this.long,
      super.key});
  double lat;
  double long;
  String outletId;
  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List availableOrders = [];

  FirebaseFirestore db = FirebaseFirestore.instance;
  // String time = DateFormat('yyyy-MM-dd').format(DateTime.now());
  String time = "2023-05-26";

  late Stream<DocumentSnapshot> shiftOrdersStream =
      db.collection("shift_orders").doc(time).snapshots();

  late Stream<QuerySnapshot> ordersStream = db.collection("orders").snapshots();
  late Stream<QuerySnapshot> orderDriverStream =
      db.collection("order_driver").snapshots();

  // shiftOrdersStream = db.collection("shift_orders").doc(time).snapshots();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    DateTime timeNow = DateTime.now();

    if (DateTime.now().hour > 12) //PM Shift
    {
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    print("OUTLET: " + widget.outletId.toString());
    return Center(
        child: StreamBuilder<QuerySnapshot>(
            stream: ordersStream,
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.active) {
                List orders =
                    snapshot.data!.docs.map((DocumentSnapshot document) {
                  // print(document
                  //     .id); //!This is necessary to crossreference later on
                  Map<String, dynamic> data =
                      document.data()! as Map<String, dynamic>;
                  data["orderId"] = document.id;
                  // return data["customerName"];
                  return data;
                }).toList();
                // print(orders);

                return StreamBuilder<DocumentSnapshot>(
                    stream: shiftOrdersStream,
                    builder: (BuildContext context,
                        AsyncSnapshot<DocumentSnapshot> snapshot) {
                      var shift_orders;

                      if (snapshot.connectionState == ConnectionState.active) {
                        var data = snapshot.data as DocumentSnapshot;
                        shift_orders = data;
                        List processedOrders = OrderService()
                            .processOrders(orders, data, widget.outletId);
                        List sortedAvailableOrders =
                            OrderService().sortOrdersByTime(processedOrders);

                        return StreamBuilder<QuerySnapshot>(
                            stream: orderDriverStream,
                            builder: (BuildContext context,
                                AsyncSnapshot<QuerySnapshot> snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.active) {
                                List data = snapshot.data!.docs
                                    .map((DocumentSnapshot document) {
                                  // print(document
                                  //     .id); //!This is necessary to crossreference later on
                                  Map<String, dynamic> data =
                                      document.data()! as Map<String, dynamic>;
                                  // data["orderId"] = document.id;
                                  // return data["customerName"];
                                  return data;
                                }).toList();

                                List currentOrders = OrderService()
                                    .processCurrentOrders(
                                        orders, data, shift_orders);

                                // List sortedCurrentOrders =
                                //     sortOrdersByTime(currentOrders);

                                return SizedBox(
                                  height: MediaQuery.of(context).size.height,
                                  width: MediaQuery.of(context).size.width,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Card(
                                        elevation: 2,
                                        color: Colors.blue.shade100,
                                        child: Container(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                5 /
                                                100,
                                            child: Container(
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              child: Center(
                                                  child: Text(
                                                      "My Orders (" +
                                                          currentOrders.length
                                                              .toString() +
                                                          ")",
                                                      style: TextStyle(
                                                          fontSize: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height *
                                                              2 /
                                                              100,
                                                          fontWeight: FontWeight
                                                              .bold))),
                                            )),
                                      ),
                                      currentOrders.length < 1
                                          ? Card(
                                              elevation: 0,
                                              child: SizedBox(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      5 /
                                                      100,
                                                  child: Center(
                                                      child: Text(
                                                          "No Current Orders Found"))),
                                            )
                                          : ListView.builder(
                                              shrinkWrap: true,
                                              itemCount: currentOrders.length,
                                              itemBuilder:
                                                  (BuildContext context,
                                                      int index) {
                                                var currentOrder =
                                                    currentOrders[index];

                                                print(currentOrder);

                                                return InkWell(
                                                  onTap: () {
                                                    showModalBottomSheet<void>(
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10.0),
                                                      ),
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        return ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      10.0),
                                                          child: SizedBox(
                                                            height: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .height *
                                                                80 /
                                                                100,
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: <
                                                                  Widget>[
                                                                Container(
                                                                  color: Colors
                                                                      .blue
                                                                      .shade400,
                                                                  height: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .height *
                                                                      8 /
                                                                      100,
                                                                  child: Center(
                                                                    child: Text(
                                                                        "Order Details",
                                                                        style: TextStyle(
                                                                            color: Colors
                                                                                .white,
                                                                            fontSize: MediaQuery.of(context).size.height *
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
                                                                    title:
                                                                        "Address",
                                                                    value: (currentOrder["customerAddress"] ==
                                                                            ""
                                                                        ? "No Address"
                                                                        : currentOrder[
                                                                            "customerAddress"])),
                                                                OrderDetailsTile(
                                                                    title:
                                                                        "Order ID",
                                                                    value: (currentOrder[
                                                                        "orderId"])),
                                                                OrderDetailsTile(
                                                                    title:
                                                                        "Time",
                                                                    value: (currentOrder[
                                                                        "timing"])),
                                                                SizedBox(
                                                                    height: MediaQuery.of(context)
                                                                            .size
                                                                            .height *
                                                                        2.5 /
                                                                        100),
                                                                Column(
                                                                  children: [
                                                                    ElevatedButton(
                                                                      style: ElevatedButton
                                                                          .styleFrom(
                                                                        backgroundColor:
                                                                            Colors.green,
                                                                      ),
                                                                      child:
                                                                          SizedBox(
                                                                        width: MediaQuery.of(context).size.width *
                                                                            30 /
                                                                            100,
                                                                        child:
                                                                            Center(
                                                                          child:
                                                                              const Text('Navigate'),
                                                                        ),
                                                                      ),
                                                                      onPressed:
                                                                          () {
                                                                        MapsLauncher.launchQuery(
                                                                            currentOrder["customerAddress"]);
                                                                      },
                                                                    ),
                                                                    ElevatedButton(
                                                                      child:
                                                                          SizedBox(
                                                                        width: MediaQuery.of(context).size.width *
                                                                            30 /
                                                                            100,
                                                                        child:
                                                                            Center(
                                                                          child:
                                                                              const Text('Confirm Delivery'),
                                                                        ),
                                                                      ),
                                                                      onPressed:
                                                                          () {
                                                                        db
                                                                            .collection(
                                                                                "orders")
                                                                            .doc(currentOrder[
                                                                                "orderId"])
                                                                            .update({
                                                                          "orderStatus":
                                                                              "Delivered"
                                                                        });
                                                                        db
                                                                            .collection(
                                                                                "order_driver")
                                                                            .doc(currentOrder[
                                                                                "orderId"])
                                                                            .set({
                                                                          "orderId":
                                                                              currentOrder["orderId"],
                                                                          "driverId": FirebaseAuth
                                                                              .instance
                                                                              .currentUser!
                                                                              .uid,
                                                                          "status":
                                                                              1 //! 0 = being delivered , 1 = delivered, -1 = failed to deliver
                                                                        }).onError((e, _) =>
                                                                                print("Error writing document: $e"));

                                                                        Navigator.of(context)
                                                                            .pop();
                                                                      },
                                                                    ),
                                                                    ElevatedButton(
                                                                      style: ElevatedButton
                                                                          .styleFrom(
                                                                        backgroundColor:
                                                                            Colors.red,
                                                                      ),
                                                                      child:
                                                                          SizedBox(
                                                                        width: MediaQuery.of(context).size.width *
                                                                            30 /
                                                                            100,
                                                                        child:
                                                                            Center(
                                                                          child:
                                                                              const Text('Cancel Delivery'),
                                                                        ),
                                                                      ),
                                                                      onPressed:
                                                                          () {
                                                                        db
                                                                            .collection(
                                                                                "orders")
                                                                            .doc(currentOrder[
                                                                                "orderId"])
                                                                            .update({
                                                                          "orderStatus":
                                                                              "Pending Delivery"
                                                                        });

                                                                        db
                                                                            .collection("order_driver")
                                                                            .doc(currentOrder["orderId"])
                                                                            .delete()
                                                                            .then(
                                                                              (doc) => print("Document deleted"),
                                                                              onError: (e) => print("Error updating document $e"),
                                                                            );

                                                                        Navigator.of(context)
                                                                            .pop();
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
                                                            vertical: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .height *
                                                                1 /
                                                                100),
                                                        child: ListTile(
                                                          // Text(currentOrder[
                                                          //     "orderId"]),
                                                          title: Text(
                                                              currentOrder[
                                                                  "timing"]),
                                                          subtitle: Text(currentOrder[
                                                                          "customerAddress"]
                                                                      .length >
                                                                  0
                                                              ? currentOrder[
                                                                  "customerAddress"]
                                                              : "No address"),
                                                        ),
                                                      )),
                                                );
                                              }),
                                      Card(
                                        elevation: 2,
                                        color: Colors.teal.shade100,
                                        child: Container(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                5 /
                                                100,
                                            child: Center(
                                                child: Text(
                                                    "Available Orders (" +
                                                        sortedAvailableOrders
                                                            .length
                                                            .toString() +
                                                        ")",
                                                    style: TextStyle(
                                                        fontSize: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height *
                                                            2 /
                                                            100,
                                                        fontWeight:
                                                            FontWeight.bold)))),
                                      ),
                                      processedOrders.length < 1
                                          ? Card(
                                              elevation: 0,
                                              child: SizedBox(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      5 /
                                                      100,
                                                  child: Center(
                                                      child: Text(
                                                          "No Orders Found"))),
                                            )
                                          : ListView.builder(
                                              itemCount:
                                                  sortedAvailableOrders.length,
                                              shrinkWrap: true,
                                              itemBuilder:
                                                  (BuildContext context,
                                                      int index) {
                                                var order =
                                                    sortedAvailableOrders[
                                                        index];
                                                return InkWell(
                                                  onTap: () {
                                                    showModalBottomSheet<void>(
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10.0),
                                                      ),
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        return ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      10.0),
                                                          child: Container(
                                                            height: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .height *
                                                                80 /
                                                                100,
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: <
                                                                  Widget>[
                                                                Container(
                                                                  color: Colors
                                                                      .green,
                                                                  height: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .height *
                                                                      8 /
                                                                      100,
                                                                  child: Center(
                                                                    child: Text(
                                                                        "Order Details",
                                                                        style: TextStyle(
                                                                            color: Colors
                                                                                .white,
                                                                            fontSize: MediaQuery.of(context).size.height *
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
                                                                    title:
                                                                        "Address",
                                                                    value: (order["customerAddress"] ==
                                                                            ""
                                                                        ? "No Address"
                                                                        : order[
                                                                            "customerAddress"])),
                                                                OrderDetailsTile(
                                                                    title:
                                                                        "Order ID",
                                                                    value: (order[
                                                                        "orderId"])),
                                                                OrderDetailsTile(
                                                                    title:
                                                                        "Time",
                                                                    value: (order[
                                                                        "timing"])),
                                                                SizedBox(
                                                                    height: MediaQuery.of(context)
                                                                            .size
                                                                            .height *
                                                                        2.5 /
                                                                        100),
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
                                                            vertical: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .height *
                                                                1 /
                                                                100),
                                                        child: ListTile(
                                                          title: Text(
                                                              order["timing"]),
                                                          // Text(order[
                                                          //     "customerName"]),
                                                          subtitle: Text(order[
                                                                          "customerAddress"]
                                                                      .length >
                                                                  0
                                                              ? order[
                                                                  "customerAddress"]
                                                              : "No address"),
                                                        ),
                                                      )),
                                                );
                                              },
                                            ),
                                    ],
                                  ),
                                );
                              } else {
                                return CircularProgressIndicator();
                              }
                            });
                      } else {
                        return CircularProgressIndicator();
                      }
                    });
              }

              return const Center(
                  child: SizedBox(child: CircularProgressIndicator()));
            }));
  }
}
