import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class Start extends StatelessWidget {
  const Start({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Center(
            child:
                ElevatedButton(onPressed: () {}, child: Text("Start Shift"))));
  }
}
