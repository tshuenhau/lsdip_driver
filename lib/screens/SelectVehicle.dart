//TODO: Interim just enter the vehicle number plate

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lsdip_driver/screens/Start.dart';

// ...

class SelectVehicle extends StatefulWidget {
  SelectVehicle({super.key});

  @override
  State<SelectVehicle> createState() => _SelectVehicleState();
}

class _SelectVehicleState extends State<SelectVehicle> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  CollectionReference vehiclesReference =
      FirebaseFirestore.instance.collection('vehicles');

  late Stream vehicleStream;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    vehicleStream = vehiclesReference.snapshots();
  }

  late String dropdownValue;
  var setDefaultValue = true;

  @override
  Widget build(BuildContext context) {
    // print(dropdownValue);
    return Container(
        child: Center(
            child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text("Select your vehicle:"),
        SizedBox(
          height: MediaQuery.of(context).size.height * 5 / 100,
          width: MediaQuery.of(context).size.height * 5 / 100,
        ),
        StreamBuilder(
            stream: vehicleStream,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasError) {
                return Text(snapshot.error.toString());
              }
              if (snapshot.connectionState == ConnectionState.active) {
                QuerySnapshot querySnapshot = snapshot.data;
                List<QueryDocumentSnapshot> listQueryDocumentSnapshot =
                    querySnapshot.docs;

                if (setDefaultValue) {
                  dropdownValue = listQueryDocumentSnapshot[0].id;
                }

                return DropdownButton<String>(
                  value: dropdownValue,
                  icon: const Icon(Icons.arrow_downward),
                  elevation: 16,
                  style: const TextStyle(color: Colors.deepPurple),
                  underline: Container(
                    height: 2,
                    color: Colors.deepPurpleAccent,
                  ),
                  onChanged: (String? value) {
                    // This is called when the user selects an item.
                    setState(() {
                      dropdownValue = value!;
                      setDefaultValue = false;
                    });
                  },
                  items: listQueryDocumentSnapshot
                      .map<DropdownMenuItem<String>>((document) {
                    return DropdownMenuItem<String>(
                      value: document.id,
                      child: Text(document['numberPlate']),
                    );
                  }).toList(),
                );
              }
              return Center(
                  child: SizedBox(child: CircularProgressIndicator()));
            }),
        SizedBox(
          height: MediaQuery.of(context).size.height * 5 / 100,
          width: MediaQuery.of(context).size.height * 5 / 100,
        ),
        ElevatedButton(
            onPressed: () async {
              var ref = db.collection("vehicles").doc(dropdownValue);

              ref.update({"vehicleStatus": "Active"});
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Start(
                            vehicleId: dropdownValue,
                          )));
            },
            child: Text("Continue"))
      ],
    )));
  }
}
