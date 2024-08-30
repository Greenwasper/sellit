import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sellit/components/colors.dart';
import 'package:sellit/components/field.dart';
import 'package:sellit/components/functions.dart';
import 'package:sellit/components/password_field.dart';
import 'package:sellit/components/custom_text.dart';
import 'package:sellit/views/home.dart';
import 'package:sellit/components/loader.dart';

class Login extends StatefulWidget {

  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool isLoading = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _phoneNumber = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool passwordObscured = true;

  bool errorVisible = false;
  String errorText = "";

  void setPasswordObscured () {
    if(passwordObscured){
      setState(() {
        passwordObscured = false;
      });
    } else {
      setState(() {
        passwordObscured = true;
      });
    }
  }

  Future<void> login() async {
    setState(() {
      isLoading = true;
    });

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _email.text,
        password: _password.text,
      );

      _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': userCredential.user!.email,
      }, SetOptions(merge: true));
    } on FirebaseAuthException catch (e) {
      print('Error signing in: ${e.code}');

      switch(e.code){
        case 'channel-error':
          errorText = "An error has occurred";
          break;
        case 'invalid-email':
          errorText = "Invalid email format";
          break;
        case 'invalid-credential':
          errorText = "Invalid password";
          break;
      }

      setState(() {
        errorVisible = true;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            Stack(
              children: [
                Positioned(
                  top: 0,
                  child: Image.asset('assets/edge2.png', fit: BoxFit.cover),
                ),
                Positioned(
                  bottom: -40,
                  child: Image.asset('assets/edge.png', fit: BoxFit.cover),
                ),
                Container(
                    height: double.infinity,
                    width: double.infinity,
                    color: Colors.transparent,
                    child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 20),
                              const CustomText(text: "Login", fontSize: 31, color: Colors.blue),
                              const SizedBox(height: 30),
                              // IntlField(controller: _phoneNumber),
                              Field(
                                controller: _email,
                                textInputType: TextInputType.emailAddress,
                                labelText: "Email",
                              ),
                              const SizedBox(height: 20),
                              PasswordField(
                                controller: _password,
                                passwordObscured: passwordObscured,
                                setPasswordObscured: setPasswordObscured,
                              ),
                              const SizedBox(height: 20),
                              InkWell(
                                onTap: () async {
                                  login();
                                },
                                child: Container(
                                  height: 55,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(7),
                                    gradient: LinearGradient(
                                      colors: [
                                        primaryColor,
                                        secondaryColor
                                      ]
                                    )
                                  ),
                                  child: const Center(
                                    child: CustomText(text: "Login", color: Colors.white, fontSize: 17),
                                  )
                                ),
                              ),
                              const SizedBox(height: 20),
                              const Row(
                                children: [
                                  Expanded(
                                    child: Divider(),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 10),
                                    child: CustomText(text: "Don't have an account?"),
                                  ),
                                  Expanded(
                                    child: Divider(),
                                  )
                                ],
                              ),
                              const SizedBox(height: 10),
                              Center(
                                child: ElevatedButton(
                                  onPressed: () {

                                  },
                                  style: ElevatedButton.styleFrom(
                                    elevation: 0,
                                    backgroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(7),
                                      side: const BorderSide(color: Colors.grey, width: 2.0),
                                    ),

                                  ),
                                  child: const CustomText(text: "Sign Up", fontSize: 15),
                                ),
                              )
                            ],
                          ),
                        )
                    )
                ),
              ],
            ),
            isLoading ? const Loader() : const SizedBox(height: 0)
          ],
        )
    );
  }
}
