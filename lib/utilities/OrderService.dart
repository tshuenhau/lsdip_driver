import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class OrderService {
  List processCurrentOrders(List orders, var orderDrivers, var shiftOrder) {
    //TODO: Need to sort by time

    List result = [];

    for (var order in orders) {
      if (shiftOrder["selected_times"] != null) {
        for (var selectedTime in shiftOrder["selected_times"]) {
          for (var deliveryId in selectedTime["orders"]) {
            for (var orderDriver in orderDrivers) {
              if (orderDriver["driverId"] ==
                      FirebaseAuth.instance.currentUser!.uid &&
                  order["orderStatus"] == "Out for Delivery" &&
                  deliveryId == order["orderId"] &&
                  orderDriver["orderId"] == order["orderId"]) {
                order["timing"] = selectedTime["time"];

                result.add(order);
                // print("YESSSSSSSSSSSSSSSSSS");
              }
            }
          }
        }
      }
    }
    // for (var order in orders) {
    //   for (var shiftOrder in shiftOrders) {
    //     for (var orderDriver in orderDrivers) {
    //       if (orderDriver["driverId"] ==
    //               FirebaseAuth.instance.currentUser!.uid &&
    //           order["orderStatus"] == "Out for Delivery" &&
    //           shiftOrder["id"] == order["orderId"] &&
    //           orderDriver["orderId"] == order["orderId"]) {
    //         order["timing"] = shiftOrder["timing"];
    //         result.add(order);
    //         // print("YESSSSSSSSSSSSSSSSSS");
    //       }
    //     }
    //   }
    // }

    return result;
  }

  List processOrders(List orders, var shiftOrder, String outletId) {
    List result = [];

    // print("Shift Orders: " + shiftOrder["selected_times"].toString());

    //TODO: Need to sort by time

    for (var order in orders) {
      if (shiftOrder["selected_times"] != null) {
        for (var selectedTime in shiftOrder["selected_times"]) {
          for (var deliveryId in selectedTime["orders"]) {
            if (deliveryId == order["orderId"] &&
                order["orderStatus"] == "Pending Delivery" &&
                order["outletId"] == outletId) {
              order["timing"] = selectedTime["time"];
              order["deliveryDate"] = shiftOrder["date"];
              result.add(order);
            }
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
    }

    result.sort((a, b) => a["startTime"].compareTo(b["startTime"]));
    return result;
  }

  List sortPickupsByTime(List pickups) {
    List result = [];

    for (var pickup in pickups) {
      DateTime startTime = DateFormat("HH:mm")
          .parse(pickup["time"].replaceAll(' ', '').split("-")[0]);
      DateTime endTime = DateFormat("HH:mm")
          .parse(pickup["time"].replaceAll(' ', '').split("-")[1]);
      pickup["startTime"] = startTime;
      result.add(pickup);
    }

    result.sort((a, b) => a["startTime"].compareTo(b["startTime"]));
    return result;
  }
}
