import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:awesome_select/awesome_select.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:lsdip_driver/screens/SelectVehicleScreen.dart';

//TODO: Update vehicle status
class VehicleScreen extends StatefulWidget {
  VehicleScreen({required this.vehicleId, super.key});
  String vehicleId;

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
                // Text("status: " + data["vehicleStatus"] ?? ''),

                Text("starting mileage: " + data["mileage"].toString() ?? ''),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 50 / 100,
                  // height: MediaQuery.of(context).size.height * 5 / 100,
                  child: SmartSelect<String>.single(
                      tileBuilder: (context, state) {
                        return S2Tile<dynamic>(
                          title: SizedBox(
                              width:
                                  MediaQuery.of(context).size.width * 10 / 100,
                              child: AutoSizeText('status', maxLines: 1)),
                          // isTwoLine: true,
                          value: SizedBox(
                              width:
                                  MediaQuery.of(context).size.width * 20 / 100,
                              child: AutoSizeText(
                                data["vehicleStatus"],
                                maxLines: 1,
                                textAlign: TextAlign.end,
                              )),
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
                        var ref =
                            db.collection("vehicles").doc(widget.vehicleId);

                        ref.update({"vehicleStatus": state.value});
                      }),
                ),
                ElevatedButton(
                    onPressed: () async {
                      var ref = db.collection("vehicles").doc(widget.vehicleId);
                      // print(vehicleRef);

                      if (data["vehicleStatus"] == "Active") {
                        ref.update({"vehicleStatus": "Inactive"});
                      } else {
                        ref.update({"vehicleStatus": "Inactive"});
                      }

                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SelectVehicleScreen()));
                    },
                    child: Text("Leave Vehicle"))
              ],
            ));

            // print(data["numberPlate"] ?? '');
          } else {
            return Center(child: SizedBox(child: CircularProgressIndicator()));
          }
        });
  }
}
