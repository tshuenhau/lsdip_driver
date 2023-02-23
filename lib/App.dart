import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:lsdip_driver/screens/Login.dart';
import 'package:lsdip_driver/screens/Start.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            child: Center(child: Login() //!todo to add login screen & auth
                )));
  }
}
