import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class OrderService {
  List processCurrentOrders(List orders, var orderDrivers, var shiftOrder) {
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
              }
            }
          }
        }
      }
    }

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

    List newResult = [];
    for (var a in result) {
      bool test = false;
      bool secondTest = false;

      for (var b in result) {
        if (a["customerName"] == b["customerName"] &&
            a["customerAddress"] == b["customerAddress"] &&
            a["invoiceNumber"] != b["invoiceNumber"]) {
          for (var c in newResult) {
            if (a["customerName"] == c["customerName"] &&
                a["customerAddress"] == c["customerAddress"]) {
              secondTest = true;
            }
          }

          print("IM JANICE");
        }
      }
      if (test == false && secondTest == false) {
        newResult.add(a);
        print(a);
      }
    }

    for (int i = 0; i < result.length; i++) {
      if (i == 0) {
        continue;
      }

      print("HYEGG" + i.toString());
    }
    return newResult;
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
