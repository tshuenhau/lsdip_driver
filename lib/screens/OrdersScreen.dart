import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';

//TODO: Get list of orders from firestore based on current time ig? >12pm = PM shift
//TODO:Figure out how to get the current order being deliverd

class OrdersScreen extends StatefulWidget {
  OrdersScreen({required this.lat, required this.long, super.key});
  double lat;
  double long;
  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

//TODO: new collection driver - orderid (will delete once delivered)
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
    List result = [];
    //TODO: query firebase to find current order being undertaken if any
    for (var order in orders) {
      for (var orderDriver in orderDrivers) {
        // print("order_Drivers :" + orderDrivers.toString());
        // print(FirebaseAuth.instance.currentUser!.uid);
        // print(orderDriver["driverId"]);

        if (orderDriver["driverId"] == FirebaseAuth.instance.currentUser!.uid &&
            order["orderStatus"] == "Out for Delivery") {
          for (var shiftOrder in shiftOrders) {
            if (shiftOrder["id"] == order["orderId"]) {
              order["timing"] = shiftOrder["timing"];
              result.add(order);
              break;
            }
          }
        }
      }
    }
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

    //TODO:still need to check for
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    DateTime timeNow = DateTime.now();
    // print(DateFormat('yyyy-MM-dd').format(timeNow));

    // print(shiftOrdersStream.toString());

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
                  return data; //TODO make it the entire order obj
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
                        // List currentOrders =
                        // checkCurrentOrders(orders, data["orders"]);
                        //TODO: Maybe need to nest one more streambuilder for order_driver

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
                                  return data; //TODO make it the entire order obj
                                }).toList();

                                List currentOrders = processCurrentOrders(
                                    orders, data, shift_orders["orders"]);

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
                                              child: Text("Avilable Orders"))),
                                      ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: currentOrders.length,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            var currentOrder =
                                                currentOrders[index];
                                            print(currentOrder);
                                            // return Container(
                                            //     child: Text(
                                            //         currentOrder.toString()));
                                            return InkWell(
                                              onTap: () {
                                                showModalBottomSheet<void>(
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
                                                            ElevatedButton(
                                                              child: const Text(
                                                                  'Select order'),
                                                              onPressed: () {
                                                                // db
                                                                //     .collection(
                                                                //         "orders")
                                                                //     .doc(currentOrder[
                                                                //         "orderId"])
                                                                //     .update({
                                                                //   "orderStatus":
                                                                //       "Out for Delivery"
                                                                // });
                                                                // db
                                                                //     .collection(
                                                                //         "order_driver")
                                                                //     .doc(currentOrder[
                                                                //         "orderId"])
                                                                //     .set({
                                                                //   "orderId":
                                                                //       currentOrder[
                                                                //           "orderId"],
                                                                //   "driverId":
                                                                //       FirebaseAuth
                                                                //           .instance
                                                                //           .currentUser!
                                                                //           .uid,
                                                                //   "status":
                                                                //       0 //! 0 = being delivered , 1 = delivered, -1 = failed to deliver
                                                                // }).onError((e,
                                                                //             _) =>
                                                                //         print(
                                                                //             "Error writing document: $e"));

                                                                // Navigator.of(
                                                                //         context)
                                                                //     .pop();
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
                                                        vertical: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height *
                                                            1 /
                                                            100),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(currentOrder[
                                                            "orderId"]),
                                                        Text(currentOrder[
                                                            "timing"]),
                                                        Text(currentOrder[
                                                            "customerName"]),
                                                        Text(currentOrder[
                                                                        "customerAddress"]
                                                                    .length >
                                                                0
                                                            ? currentOrder[
                                                                "customerAddress"]
                                                            : "No address"),
                                                      ],
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
                                              child: Text("Avilable Orders"))),
                                      ListView.builder(
                                        itemCount: processedOrders.length,
                                        shrinkWrap: true,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          var order = processedOrders[index];
                                          return InkWell(
                                            onTap: () {
                                              showModalBottomSheet<void>(
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
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(order["orderId"]),
                                                      Text(order["timing"]),
                                                      Text(order[
                                                          "customerName"]),
                                                      Text(order["customerAddress"]
                                                                  .length >
                                                              0
                                                          ? order[
                                                              "customerAddress"]
                                                          : "No address"),
                                                    ],
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

                //TODO: possibly put a streambuilder here as well to check am pm shift orders
              }

              return const Center(
                  child: SizedBox(child: CircularProgressIndicator()));
            }));
  }
}
