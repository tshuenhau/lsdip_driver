//TODO: https://pub.dev/packages/flutter_secure_storage
// TODO: https://systemweakness.com/how-to-store-login-credentials-the-right-way-in-flutter-857ba6e7e96d
//TODO: https://firebase.google.com/docs/auth/flutter/password-auth
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lsdip_driver/screens/Homescreen.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ...

class SelectVehicleScreen extends StatefulWidget {
  //!Need to persist the state of vehicle selection
  //TODO: Query firebase for vehicle and then check if any have the same UID as the user and auto go to next page.
  SelectVehicleScreen({super.key});

  @override
  State<SelectVehicleScreen> createState() => _SelectVehicleScreenState();
}

class _SelectVehicleScreenState extends State<SelectVehicleScreen> {
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

  @override
  void dispose() {
    super.dispose();

    doSelectVehicle();

    dropdownValue = "";
  }

  String dropdownValue = "";
  var setDefaultValue = true;

  @override
  Widget build(BuildContext context) {
    print(
        FirebaseAuth.instance.currentUser!.displayName.toString() + " hewrewt");
    void doSubmit() {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Processing Data...'),
            duration: const Duration(milliseconds: 900)),
      );
      Future.delayed(const Duration(milliseconds: 1000), () {
        //TODO: check if status is active
// Here you can write your code
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => Homescreen(vehicleId: dropdownValue)));
      });
    }

    // print(dropdownValue);
    return Scaffold(
      body: Container(
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

                  List<QueryDocumentSnapshot> vehicles =
                      listQueryDocumentSnapshot
                          .where((element) =>
                              element["vehicleStatus"] == "Inactive")
                          .toList();

                  if (setDefaultValue && vehicles.length > 0) {
                    dropdownValue = vehicles[0]
                        .id; //TODO: Default value needs to be fixed, if the default value changes vehicle status the app crashes
                  } else if (vehicles.length < 1) {
                    dropdownValue = "";
                  }

                  return DropdownButton<String>(
                    value: dropdownValue,
                    disabledHint: Text("None Available"),
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
                    items: vehicles.isEmpty
                        ? null
                        : vehicles.map<DropdownMenuItem<String>>((document) {
                            return DropdownMenuItem<String>(
                              value: document.id,
                              child: Text(document['numberPlate']),
                            );
                          }).toList(),
                  );
                }
                return const Center(
                    child: SizedBox(child: CircularProgressIndicator()));
              }),
          SizedBox(
            height: MediaQuery.of(context).size.height * 5 / 100,
            width: MediaQuery.of(context).size.height * 5 / 100,
          ),
          ElevatedButton(
              onPressed: () async {
                if (dropdownValue.isNotEmpty) {
                  var vehicleId = dropdownValue;
                  if (!mounted) return;

                  //TODO: Might need to put a loading page

                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Homescreen(
                                vehicleId: vehicleId,
                              )));
                }
              },
              child: Text("Continue"))
        ],
      ))),
    );
  }

  Future<void> doSelectVehicle() async {
    if (dropdownValue != "") {
      var ref = db.collection("vehicles").doc(dropdownValue);
      await ref.update({
        "vehicleStatus": "Active",
        "driver": FirebaseAuth.instance.currentUser?.uid ?? ""
      });
    }
  }
}
