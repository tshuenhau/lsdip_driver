import 'package:flutter/material.dart';
import 'package:lsdip_driver/App.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:lsdip_driver/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

//https://stackoverflow.com/questions/54138750/total-distance-calculation-from-latlng-list
//https://pub.dev/packages/latlong2
//TODO: https://pub.dev/packages/location
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Driver',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: App(),
    );
  }
}
