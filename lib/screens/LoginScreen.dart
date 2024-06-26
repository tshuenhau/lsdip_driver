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
  CollectionReference usersReference =
      FirebaseFirestore.instance.collection('users');
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Logging in...'),
              duration: const Duration(milliseconds: 600)),
        );
        final userRef =
            usersReference.doc(FirebaseAuth.instance.currentUser?.uid);

        userRef.get().then(
          (DocumentSnapshot doc) {
            if (doc.data() == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    backgroundColor: Colors.red,
                    content: Text('User not found...'),
                    duration: const Duration(milliseconds: 900)),
              );

              // throw FirebaseAuthException(code: 'user-not-found');
            } else {
              final data = doc.data() as Map<String, dynamic>;
              if (data["role"] == "Driver") {
                Future.delayed(const Duration(milliseconds: 1200), () {
                  // Here you can write your code
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SelectVehicleScreen()));
                });
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      backgroundColor: Colors.red,
                      content: Text('User is not a driver...'),
                      duration: const Duration(milliseconds: 900)),
                );
              }
            }

            // ...
          },
          onError: (e) => print("Error getting document: $e"),
        );
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                backgroundColor: Colors.red,
                content: Text('Wrong Username...'),
                duration: const Duration(milliseconds: 900)),
          );
        } else if (e.code == 'wrong-password') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                backgroundColor: Colors.red,
                content: Text('Wrong Password...'),
                duration: const Duration(milliseconds: 900)),
          );
        }
      }
    }

    void doSubmit() {
      if (_formKey.currentState!.validate()) {
        doLogin();

        //TODO: Replace with creating firebase doc and saving it
// Here you can write your code
      }
    }

    return Scaffold(
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          alignment: AlignmentDirectional.center,
          children: [
            Positioned(
              top: 0,
              child: Container(
                height: MediaQuery.of(context).size.height * 40 / 100,
                width: MediaQuery.of(context).size.width,
                child: FittedBox(
                    child: Image.asset("assets/images/backImage.jpg"),
                    fit: BoxFit.cover),
                // decoration: const BoxDecoration(
                //     image: DecorationImage(
                //         image: AssetImage("assets/images/backImage.jpg"))),
              ),
            ),
            Positioned(
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(30),
                    topLeft: Radius.circular(30),
                  ),
                ),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 63 / 100,
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 5 / 100,
                      ),
                      Text("Log In",
                          style: TextStyle(
                              color: Colors.blue,
                              fontSize:
                                  MediaQuery.of(context).size.width * 7 / 100,
                              fontWeight: FontWeight.bold)),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 5 / 100,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 75 / 100,
                        child: TextFormField(
                          decoration: InputDecoration(
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 0),
                              border: InputBorder.none,
                              hintText: 'Username',
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    width: 2, color: Colors.grey),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              // Set border for focused state
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    width: 2, color: Colors.blue),
                                borderRadius: BorderRadius.circular(10),
                              )),
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
                            doSubmit();
                          },
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 2 / 100,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 75 / 100,
                        child: TextFormField(
                          decoration: InputDecoration(
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 0),
                              border: InputBorder.none,
                              hintText: 'Password',
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    width: 2, color: Colors.grey),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              // Set border for focused state
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    width: 2, color: Colors.blue),
                                borderRadius: BorderRadius.circular(10),
                              )),
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
                          style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadiusDirectional.circular(8))),
                          onPressed: () async {
                            doSubmit();
                          },
                          child: SizedBox(
                              width:
                                  MediaQuery.of(context).size.width * 66 / 100,
                              height:
                                  MediaQuery.of(context).size.height * 5 / 100,
                              child: Center(child: Text('Login'))),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
