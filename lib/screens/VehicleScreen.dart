import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:awesome_select/awesome_select.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:lsdip_driver/screens/SelectVehicleScreen.dart';
import 'package:lsdip_driver/widgets/OrderDetailsTile.dart';

import 'LoginScreen.dart';

//TODO: Update vehicle status
class VehicleScreen extends StatefulWidget {
  VehicleScreen({required this.vehicleId, required this.date, super.key});
  String vehicleId;
  String date;
  @override
  State<VehicleScreen> createState() => _VehicleScreenState();
}

class _VehicleScreenState extends State<VehicleScreen> {
  String status = 'Inactive';
  List<S2Choice<String>> options = [
    S2Choice<String>(value: 'Broke Down', title: 'Broke Down'),
    S2Choice<String>(value: 'Active', title: 'Active'),
    S2Choice<String>(value: 'Inactive', title: 'Inactive'),
  ];

  FirebaseFirestore db = FirebaseFirestore.instance;
  // late DocumentReference vehicleReference;
  late Map<String, dynamic> vehicle;
  late Stream<DocumentSnapshot> vehicleStream;
  late Stream<DocumentSnapshot> userStream;

  // late Stream vehicleStream;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    vehicleStream = db.collection("vehicles").doc(widget.vehicleId).snapshots();
    userStream = db
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    // print(vehicleReference.get());
    return StreamBuilder<DocumentSnapshot>(
        stream: vehicleStream,
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            var data = snapshot.data as DocumentSnapshot;

            return StreamBuilder<DocumentSnapshot>(
                stream: userStream,
                builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.active) {
                    var userData = snapshot.data as DocumentSnapshot;

                    return Center(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            // Card(
                            //   color: Colors.amberAccent.shade100,
                            //   child: Container(
                            //       height: MediaQuery.of(context).size.height * 5 / 100,
                            //       child: Container(
                            //         width: MediaQuery.of(context).size.width,
                            //         child: Center(
                            //             child: Text("Vehicle Details",
                            //                 style: TextStyle(
                            //                     fontSize:
                            //                         MediaQuery.of(context).size.height *
                            //                             2 /
                            //                             100,
                            //                     fontWeight: FontWeight.bold))),
                            //       )),
                            // ),
                            SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    2 /
                                    100),
                            OrderDetailsTile(
                                title: "Name", value: userData["name"]),
                            OrderDetailsTile(
                                title: "Email", value: userData["email"]),
                            OrderDetailsTile(title: "Date", value: widget.date),
                            OrderDetailsTile(
                                title: "Number Plate",
                                value: data["numberPlate"] ?? ''),
                            OrderDetailsTile(
                                title: "Mileage (KM)",
                                value: data["mileage"].toString() ?? ''),
                            Card(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                                side: BorderSide(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .tertiary
                                      .withOpacity(0.20),
                                  width: 1,
                                ),
                              ),
                              margin: EdgeInsets.symmetric(
                                  horizontal:
                                      MediaQuery.of(context).size.width *
                                          2.5 /
                                          100,
                                  vertical: MediaQuery.of(context).size.height *
                                      0.55 /
                                      100),
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width,
                                // height: MediaQuery.of(context).size.height * 5 / 100,
                                child: SmartSelect<String>.single(
                                    tileBuilder: (context, state) {
                                      return S2Tile<dynamic>(
                                        title: SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                1 /
                                                100,
                                            child: AutoSizeText('Status',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                                maxLines: 1)),
                                        // isTwoLine: true,
                                        value: Row(
                                          children: [
                                            SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    20 /
                                                    100,
                                                child: AutoSizeText(
                                                  data["vehicleStatus"],
                                                  maxLines: 1,
                                                  textAlign: TextAlign.end,
                                                )),
                                          ],
                                        ),
                                        onTap: state.showModal,
                                        isLoading: false,
                                      );
                                    },
                                    modalType: S2ModalType.bottomSheet,
                                    modalConfirm: true,
                                    modalConfig: S2ModalConfig(title: "status"),
                                    placeholder: data["vehicleStatus"],
                                    // title: 'status',
                                    selectedValue: data["vehicleStatus"],
                                    choiceItems: options,
                                    onChange: (state) async {
                                      var ref = db
                                          .collection("vehicles")
                                          .doc(widget.vehicleId);

                                      ref.update(
                                          {"vehicleStatus": state.value});
                                    }),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 20 / 100,
                          child: Column(
                            children: [
                              ElevatedButton(
                                  onPressed: () async {
                                    var ref = db
                                        .collection("vehicles")
                                        .doc(widget.vehicleId);
                                    // print(vehicleRef);

                                    if (data["vehicleStatus"] == "Active") {
                                      await ref.update({
                                        "vehicleStatus": "Inactive",
                                        "driver": ""
                                      });
                                      if (!mounted) return;

                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  SelectVehicleScreen()));
                                    }
                                  },
                                  child: SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          25 /
                                          100,
                                      child: Center(
                                          child: Text("Change Vehicle")))),
                              ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red),
                                  onPressed: () async {
                                    var ref = db
                                        .collection("vehicles")
                                        .doc(widget.vehicleId);
                                    if (data["vehicleStatus"] == "Active") {
                                      await ref.update({
                                        "vehicleStatus": "Inactive",
                                        "driver": ""
                                      });
                                      await FirebaseAuth.instance.signOut();
                                      if (!mounted) return;

                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  LoginScreen()));
                                    }
                                  },
                                  child: SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          25 /
                                          100,
                                      child: Center(child: Text("Log out"))))
                            ],
                          ),
                        ),
                      ],
                    ));
                  }
                  return Center(
                      child: SizedBox(child: CircularProgressIndicator()));
                });

            // print(data["numberPlate"] ?? '');
          } else {
            return Center(child: SizedBox(child: CircularProgressIndicator()));
          }
        });
  }
}
