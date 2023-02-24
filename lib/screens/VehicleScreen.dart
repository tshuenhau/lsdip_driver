import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

//TODO: Update vehicle status
class VehicleScreen extends StatefulWidget {
  VehicleScreen({required this.vehicleId, super.key});
  String vehicleId;

  @override
  State<VehicleScreen> createState() => _VehicleScreenState();
}

class _VehicleScreenState extends State<VehicleScreen> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  // late DocumentReference vehicleReference;
  late Map<String, dynamic> vehicle;
  late Stream<DocumentSnapshot> vehicleStream;

  // late Stream vehicleStream;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // vehicleReference = FirebaseFirestore.instance
    //     .collection('vehicles')
    //     .doc(widget.numberPlate);
    // var test = FirebaseFirestore.instance
    //     .collection('vehicles')
    //     .where("numberPlate", isEqualTo: widget.vehicleId);

    vehicleStream = db.collection("vehicles").doc(widget.vehicleId).snapshots();
    // test.get().then((res) {
    //   if (res.docs.length > 0) {
    //     vehicleId = res.docs[0].id;

    //     vehicleStream = FirebaseFirestore.instance
    //         .collection('vehicles')
    //         .doc(vehicleId)
    //         .snapshots();
    //   }
    //   print(res.docs[0].id);
    // });
    // print(test.get().toString());

    // where("numberPlate", isEqualTo:widget.numberPlate)
    // print(vehicleStream);
  }

  @override
  Widget build(BuildContext context) {
    // print(vehicleReference.get());
    return StreamBuilder<DocumentSnapshot>(
        stream: vehicleStream,
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            var data = snapshot.data as DocumentSnapshot;
            // String numberPlate = snapshot.data["numberPlate"] ?? "";

            return Center(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("numberPlate: " + data["numberPlate"] ?? ''),
                Text("status: " + data["vehicleStatus"] ?? ''),
                Text("mileage: " + data["mileage"].toString() ?? ''),
                ElevatedButton(
                    onPressed: () async {
                      var ref = db.collection("vehicles").doc(widget.vehicleId);
                      // print(vehicleRef);
                      ref.update({"vehicleStatus": "updated"});
                    },
                    child: Text("Update Status"))
              ],
            ));

            // print(data["numberPlate"] ?? '');
          } else {
            return Center(child: SizedBox(child: CircularProgressIndicator()));
          }
        });
  }
}
