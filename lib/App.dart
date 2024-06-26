import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:lsdip_driver/screens/Homescreen.dart';
import 'package:lsdip_driver/screens/LoginScreen.dart';
import 'package:lsdip_driver/screens/SelectVehicleScreen.dart';
import 'package:lsdip_driver/screens/Start.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lsdip_driver/widgets/OrderScanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  CollectionReference vehiclesReference =
      FirebaseFirestore.instance.collection('vehicles');

  bool isLoggedIn = false;

  String vehicleId = "";

  void permissionHandler() async {
    // Either the permission was already granted before or the user just granted it.
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.location,
    ].request();

// You can request multiple permissions at once.
  }

  void checkVehicleAllocated() async {
    await vehiclesReference
        .where("driver", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((querySnapshot) {
      for (var docSnapshot in querySnapshot.docs) {
        setState(() {
          vehicleId = docSnapshot.id;
        });
      }
    }, onError: (e) => print("error completing : $e"));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    permissionHandler();
    checkVehicleAllocated();

    // permissionHandler();
  }

  @override
  Widget build(BuildContext context) {
    if (vehicleId != "") {
      print("BUSB");
    }
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        print('User is currently signed out!');
        isLoggedIn = false;
      } else {
        isLoggedIn = true;

        print('User is signed in!');
      }
    });
    return Scaffold(
        body: Center(
            child: StreamBuilder(
                stream: FirebaseAuth.instance.authStateChanges(),
                builder: (BuildContext context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.active) {
                    if (isLoggedIn == false) {
                      return LoginScreen();
                    } else {
                      if (vehicleId != "") {
                        return Homescreen(vehicleId: vehicleId);
                      } else {
                        return SelectVehicleScreen();
                      }
                    }
                  }

                  return CircularProgressIndicator();
                })

            // isLoggedIn
            //     ? SelectVehicleScreen()
            //     : LoginScreen() //!todo to add login screen & auth
            ));
  }
}
