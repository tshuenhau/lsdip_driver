import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';

class OrdersScreen extends StatefulWidget {
  OrdersScreen({required this.lat, required this.long, super.key});
  double lat;
  double long;
  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  // String time = DateFormat('yyyy-MM-dd').format(DateTime.now());
  String time = "2023-04-19";

  late Stream<DocumentSnapshot> shiftOrdersStream =
      db.collection("shift_orders").doc(time).snapshots();

  late Stream<QuerySnapshot> ordersStream = db.collection("orders").snapshots();
  late Stream<QuerySnapshot> orderDriverStream =
      db.collection("order_driver").snapshots();

  // shiftOrdersStream = db.collection("shift_orders").doc(time).snapshots();
  List processCurrentOrders(List orders, var orderDrivers, var shiftOrders) {
    //TODO: Need to sort by time

    List result = [];
    for (var order in orders) {
      for (var shiftOrder in shiftOrders) {
        for (var orderDriver in orderDrivers) {
          if (orderDriver["driverId"] ==
                  FirebaseAuth.instance.currentUser!.uid &&
              order["orderStatus"] == "Out for Delivery" &&
              shiftOrder["id"] == order["orderId"] &&
              orderDriver["orderId"] == order["orderId"]) {
            order["timing"] = shiftOrder["timing"];
            result.add(order);
            // print("YESSSSSSSSSSSSSSSSSS");
          }
        }
      }
    }

    return result;
  }

  List sortOrdersByTime(List orders) {
    List result = [];

    for (var order in orders) {
      DateTime startTime = DateFormat("HH:mm")
          .parse(order["timing"].replaceAll(' ', '').split("-")[0]);
      DateTime endTime = DateFormat("HH:mm")
          .parse(order["timing"].replaceAll(' ', '').split("-")[1]);
      order["startTime"] = startTime;
      order["endTime"] = endTime;
      result.add(order);
      print("start Time: " + order["startTime"].toString());
    }

    result.sort((a, b) => a["startTime"].compareTo(b["startTime"]));
    print(result);
    return result;
  }

  List processOrders(List orders, var shiftOrders) {
    List result = [];

    print(shiftOrders.toString());

    //TODO: Need to sort by time

    for (var order in orders) {
      for (var shiftOrder in shiftOrders) {
        if (shiftOrder["id"] == order["orderId"] &&
            order["orderStatus"] == "Pending Delivery") {
          order["timing"] = shiftOrder["timing"];
          result.add(order);
        }
      }
    }
    return result;
  }

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
                        List processedOrders =
                            processOrders(orders, data["orders"]);
                        List sortedCurrentOrders =
                            sortOrdersByTime(processedOrders);
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

                                List currentOrders = processCurrentOrders(
                                    orders, data, shift_orders["orders"]);

                                // List sortedCurrentOrders =
                                //     sortOrdersByTime(currentOrders);

                                return SizedBox(
                                  height: MediaQuery.of(context).size.height,
                                  width: MediaQuery.of(context).size.width *
                                      95 /
                                      100,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              5 /
                                              100,
                                          child: Center(
                                              child: Text("Current Orders"))),
                                      ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: currentOrders.length,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            var currentOrder =
                                                currentOrders[index];

                                            print(currentOrder);

                                            return InkWell(
                                              onTap: () {
                                                showModalBottomSheet<void>(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                  ),
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return SizedBox(
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              80 /
                                                              100,
                                                      child: Center(
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: <Widget>[
                                                            Text(currentOrder[
                                                                "orderId"]),
                                                            Text(currentOrder[
                                                                        "customerAddress"] ==
                                                                    ""
                                                                ? "No Address"
                                                                : currentOrder[
                                                                    "customerAddress"]),
                                                            Column(
                                                              children: [
                                                                ElevatedButton(
                                                                  child:
                                                                      SizedBox(
                                                                    width: MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        30 /
                                                                        100,
                                                                    child:
                                                                        Center(
                                                                      child: const Text(
                                                                          'Confirm Delivery'),
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
                                                                          currentOrder[
                                                                              "orderId"],
                                                                      "driverId": FirebaseAuth
                                                                          .instance
                                                                          .currentUser!
                                                                          .uid,
                                                                      "status":
                                                                          1 //! 0 = being delivered , 1 = delivered, -1 = failed to deliver
                                                                    }).onError((e,
                                                                                _) =>
                                                                            print("Error writing document: $e"));

                                                                    Navigator.of(
                                                                            context)
                                                                        .pop();
                                                                  },
                                                                ),
                                                                ElevatedButton(
                                                                  style: ElevatedButton
                                                                      .styleFrom(
                                                                    backgroundColor:
                                                                        Colors
                                                                            .red,
                                                                  ),
                                                                  child:
                                                                      SizedBox(
                                                                    width: MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        30 /
                                                                        100,
                                                                    child:
                                                                        Center(
                                                                      child: const Text(
                                                                          'Cancel Delivery'),
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
                                                                        .collection(
                                                                            "order_driver")
                                                                        .doc(currentOrder[
                                                                            "orderId"])
                                                                        .delete()
                                                                        .then(
                                                                          (doc) =>
                                                                              print("Document deleted"),
                                                                          onError: (e) =>
                                                                              print("Error updating document $e"),
                                                                        );

                                                                    Navigator.of(
                                                                            context)
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
                                                      title: Text(currentOrder[
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
                                      Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              5 /
                                              100,
                                          child: Center(
                                              child: Text("Available Orders"))),
                                      ListView.builder(
                                        itemCount: sortedCurrentOrders.length,
                                        shrinkWrap: true,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          var order =
                                              sortedCurrentOrders[index];
                                          return InkWell(
                                            onTap: () {
                                              showModalBottomSheet<void>(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                ),
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return SizedBox(
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            80 /
                                                            100,
                                                    child: Center(
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: <Widget>[
                                                          Text(
                                                              order["orderId"]),
                                                          Text(order["customerAddress"] ==
                                                                  ""
                                                              ? "No Address"
                                                              : order[
                                                                  "customerAddress"]),
                                                          ElevatedButton(
                                                            child: const Text(
                                                                'Select order'),
                                                            onPressed: () {
                                                              db
                                                                  .collection(
                                                                      "orders")
                                                                  .doc(order[
                                                                      "orderId"])
                                                                  .update({
                                                                "orderStatus":
                                                                    "Out for Delivery"
                                                              });
                                                              db
                                                                  .collection(
                                                                      "order_driver")
                                                                  .doc(order[
                                                                      "orderId"])
                                                                  .set({
                                                                "orderId": order[
                                                                    "orderId"],
                                                                "driverId":
                                                                    FirebaseAuth
                                                                        .instance
                                                                        .currentUser!
                                                                        .uid,
                                                                "status":
                                                                    0 //! 0 = being delivered , 1 = delivered, -1 = failed to deliver
                                                              }).onError((e,
                                                                          _) =>
                                                                      print(
                                                                          "Error writing document: $e"));

                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
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
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              1 /
                                                              100),
                                                  child: ListTile(
                                                    title:
                                                        Text(order["timing"]),
                                                    // Text(order[
                                                    //     "customerName"]),
                                                    subtitle: Text(
                                                        order["customerAddress"]
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
