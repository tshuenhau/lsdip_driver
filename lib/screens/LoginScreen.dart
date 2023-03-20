import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lsdip_driver/screens/SelectVehicleScreen.dart';
import 'package:email_validator/email_validator.dart';

//TODO: Wrong credentials
class LoginScreen extends StatefulWidget {
  LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String? password;
  String? email;
  final _formKey = GlobalKey<FormState>();
  FirebaseFirestore db = FirebaseFirestore.instance;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    void doLogin() async {
      try {
        final credential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email!, password: password!);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          print('No user found for that email.');
        } else if (e.code == 'wrong-password') {
          print('Wrong password provided for that user.');
        }
      }
    }

    void doSubmit() {
      // Validate returns true if the form is valid, or false otherwise.
      if (_formKey.currentState!.validate()) {
        // If the form is valid, display a snackbar. In the real world,
        // you'd often call a server or save the information in a database.
        doLogin();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Processing Data...'),
              duration: const Duration(milliseconds: 900)),
        );
        Future.delayed(const Duration(milliseconds: 1000), () {
          //TODO: Replace with creating firebase doc and saving it
// Here you can write your code
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => SelectVehicleScreen()));
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
            Text("Please Login:"),
            SizedBox(
              width: MediaQuery.of(context).size.width * 65 / 100,
              child: TextFormField(
                textAlign: TextAlign.center,
                keyboardType: TextInputType.emailAddress,
                // The validator receives the text that the user has entered.
                onChanged: (val) {
                  if (val.length > 0) {
                    setState(() {
                      email = val;
                    });
                  }
                },
                validator: (value) {
                  if (!EmailValidator.validate(value!)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                  // doSubmit();
                },
                onFieldSubmitted: (e) async {
                  print("E" + e.toString());

                  doSubmit();
                },
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 65 / 100,
              child: TextFormField(
                obscureText: true,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.visiblePassword,
                // The validator receives the text that the user has entered.
                onChanged: (val) {
                  if (val.length > 0) {
                    setState(() {
                      password = val;
                    });
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password cannot be empty';
                  }
                  return null;
                  // doSubmit();
                },
                onFieldSubmitted: (e) async {
                  print("E" + e.toString());

                  doSubmit();
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: ElevatedButton(
                onPressed: () async {
                  // print("value" + value.toString());
                  // var ref = db.collection("vehicles").doc(widget.vehicleId);
                  // // print(vehicleRef);
                  // await ref.update({"mileage": value});
                  doSubmit();
                },
                child: const Text('Login'),
              ),
            ),
          ],
        )),
      ),
    );
  }
}
