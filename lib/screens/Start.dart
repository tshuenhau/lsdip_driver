import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:lsdip_driver/screens/Homescreen.dart';

class Start extends StatelessWidget {
  Start({super.key});

  late int value;

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Center(
            child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text("Please enter the current Odometer reading:"),
        SizedBox(
          width: MediaQuery.of(context).size.width * 70 / 100,
          child: TextField(
            textAlign: TextAlign.center,
            onChanged: (input) {
              value = int.parse(input);
              print(value);
            },
            keyboardType: TextInputType.number,
            onSubmitted: (e) {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => Homescreen()));
            },
          ),
        ),
        ElevatedButton(onPressed: () {}, child: Text("Start Shift")),
      ],
    )));
  }
}
