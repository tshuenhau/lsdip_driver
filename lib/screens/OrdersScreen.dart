import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';

//TODO: Get list of orders from firestore based on current time ig? >12pm = PM shift

enum shift { AM, PM }

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
  String time = "2023-04-14";

  late Stream<DocumentSnapshot> shiftOrdersStream =
      db.collection("shift_orders").doc(time).snapshots();

  late Stream<QuerySnapshot> ordersStream = db.collection("orders").snapshots();

  // shiftOrdersStream = db.collection("shift_orders").doc(time).snapshots();
  dynamic checkOrder(Map<String, dynamic> data) {
    //TODO: query firebase orders_shift to find matching and also query customers for those matching to get their address
    return data;
  }

  List filterOrders(List orders, var shiftOrders) {
    List result = [];

    //TODO do the checks for shift here
    // print("order_shift " + shiftOrders["am_shift"].toString());

    // for (var shiftOrder in shiftOrders) {
    //   print("slodls" + shiftOrder);
    // }

    for (var order in orders) {
      for (var shiftOrder in shiftOrders) {
        if (order["orderId"] == shiftOrder) {
          result.add(order);
          print("Success");
        }
      }
      // print("order " + order["orderId"].toString());

      // print(order["orderId"]);
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

    print(shiftOrdersStream.toString());

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
                  print(document
                      .id); //!This is necessary to crossreference later on
                  Map<String, dynamic> data =
                      document.data()! as Map<String, dynamic>;
                  data["orderId"] = document.id;
                  // return data["customerName"];
                  return checkOrder(data); //TODO make it the entire order obj
                }).toList();
                print(orders);

                return StreamBuilder<DocumentSnapshot>(
                    stream: shiftOrdersStream,
                    builder: (BuildContext context,
                        AsyncSnapshot<DocumentSnapshot> snapshot) {
                      if (snapshot.connectionState == ConnectionState.active) {
                        var data = snapshot.data as DocumentSnapshot;

                        List filteredOrders =
                            filterOrders(orders, data["am_shift"]);
                        // print("order_shift " + data["am_shift"][0]);
                        // return ListView.builder(
                        //   itemCount: data["am_shift"].length,
                        //   shrinkWrap: true,
                        //   itemBuilder: (BuildContext context, int index) {
                        //     return Card(child: Text(data["am_shift"][index]));
                        //   },
                        // );

                        return Text(filteredOrders.toString());
                      } else {
                        return CircularProgressIndicator();
                      }
                    });

                return (Text(orders
                    .toString())); //TODO: possibly put a streambuilder here as well to check am pm shift orders
              }

              return Center(
                  child: SizedBox(child: CircularProgressIndicator()));
            }));
  }
}
