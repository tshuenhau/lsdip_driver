import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:lsdip_driver/screens/LoginScreen.dart';
import 'package:lsdip_driver/screens/SelectVehicleScreen.dart';
import 'package:lsdip_driver/screens/Start.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:permission_handler/permission_handler.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  bool isLoggedIn = false;

  void permissionHandler() async {
    if (!await Permission.location.request().isGranted) {
      // Either the permission was already granted before or the user just granted it.
      Map<Permission, PermissionStatus> statuses = await [
        Permission.location,
      ].request();
    }

// You can request multiple permissions at once.
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // permissionHandler();
  }

  @override
  Widget build(BuildContext context) {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        print('User is currently signed out!');
        isLoggedIn = false;
      } else {
        isLoggedIn = true;
        print(user);
        print('User is signed in!');
      }
    });
    return Scaffold(
        body: Center(
            child: StreamBuilder(
                stream: FirebaseAuth.instance.authStateChanges(),
                builder: (BuildContext context, snapshot) {
                  if (snapshot.hasData) {
                    return SelectVehicleScreen();
                  } else {
                    return LoginScreen();
                  }
                })

            // isLoggedIn
            //     ? SelectVehicleScreen()
            //     : LoginScreen() //!todo to add login screen & auth
            ));
  }
}
