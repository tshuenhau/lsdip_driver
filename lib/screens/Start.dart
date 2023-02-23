import 'package:flutter/material.dart';
import 'package:lsdip_driver/screens/Homescreen.dart';

//TODO: add get state management https://blog.logrocket.com/ultimate-guide-getx-state-management-flutter/
class Start extends StatefulWidget {
  Start({required this.numberPlate, super.key});

  String numberPlate;

  @override
  State<Start> createState() => _StartState();
}

class _StartState extends State<Start> {
  late int value;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    print(widget.numberPlate);
    void doSubmit() {
      // Validate returns true if the form is valid, or false otherwise.
      if (_formKey.currentState!.validate()) {
        // If the form is valid, display a snackbar. In the real world,
        // you'd often call a server or save the information in a database.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Processing Data...'),
              duration: const Duration(milliseconds: 900)),
        );

        Future.delayed(const Duration(milliseconds: 1000), () {
          //TODO: Replace with creating firebase doc and saving it
// Here you can write your code
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => Homescreen()));
        });
      }
    }

    return Scaffold(
      body: Form(
        key: _formKey,
        child: Center(
            child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Please enter the current odometer reading:"),
            SizedBox(
              width: MediaQuery.of(context).size.width * 65 / 100,
              child: TextFormField(
                keyboardType: TextInputType.number,
                // The validator receives the text that the user has entered.
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a valid reading';
                  }
                  return null;
                  // doSubmit();
                },
                onFieldSubmitted: (e) {
                  doSubmit();
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: ElevatedButton(
                onPressed: () {
                  doSubmit();
                },
                child: const Text('Submit'),
              ),
            ),
          ],
        )),
      ),
    );
  }
}
