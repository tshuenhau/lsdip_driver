import 'package:flutter/material.dart';

class OrderDetailsTile extends StatelessWidget {
  OrderDetailsTile({required this.title, required this.value, super.key});

  String title;
  String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
        side: BorderSide(
          color: Theme.of(context).colorScheme.tertiary.withOpacity(0.20),
          width: 1,
        ),
      ),
      margin: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 2.5 / 100,
          vertical: MediaQuery.of(context).size.height * 0.55 / 100),
      child: Padding(
          padding: EdgeInsets.symmetric(
              vertical: MediaQuery.of(context).size.height * 0.35 / 100),
          child: ListTile(
            horizontalTitleGap: MediaQuery.of(context).size.width * 5 / 100,
            dense: true,
            leading: SizedBox(
                width: MediaQuery.of(context).size.width * 25 / 100,
                child:
                    Text(title, style: TextStyle(fontWeight: FontWeight.bold))),
            title: Padding(
              padding: EdgeInsets.symmetric(
                  vertical: MediaQuery.of(context).size.height * 1 / 100),
              child: Text(value),
            ),
          )),
    );
  }
}
