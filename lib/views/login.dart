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
import 'package:sellit/views/register.dart';

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
      body: Stack(
        children: [
          Stack(
            children: [
              Container(
                height: double.infinity,
                width: double.infinity,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [
                          primaryColor,
                          secondaryColor
                        ]
                    )
                ),
                child: const Padding(
                  padding: EdgeInsets.only(top: 70, left: 20),
                  child: CustomText(text: 'Welcome', color: Colors.white, fontSize: 40),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 200),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  height: double.infinity,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      )
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 50),
                        Image.asset('assets/sellit.png', width: 100),
                        const SizedBox(height: 20),
                        Column(
                          children: [
                            TextField(
                              controller: _email,
                              decoration: const InputDecoration(labelText: 'Email'),
                            ),
                            const SizedBox(height: 20),
                            TextField(
                              controller: _password,
                              obscureText: passwordObscured,
                              autocorrect: false,
                              enableSuggestions: false,
                              decoration: InputDecoration(
                                suffix: IconButton(
                                  onPressed: () {
                                    if(passwordObscured){
                                      setState(() {
                                        passwordObscured = false;
                                      });
                                    } else {
                                      setState(() {
                                        passwordObscured = true;
                                      });
                                    }
                                  },
                                  icon: Icon(passwordObscured ? Icons.visibility_off : Icons.visibility, size: 20,)
                                ),
                                contentPadding: const EdgeInsets.symmetric(vertical: 5),
                                label: const Text("Password", style: TextStyle(color: Colors.black)),
                                enabledBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.black)
                                ),
                                focusedBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.black)
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () {},
                                  child: const CustomText(text: "Forgot Password?", fontSize: 16,),
                                ),
                              ],
                            ),
                            Visibility(
                              visible: errorVisible,
                              child: CustomText(text: errorText, color: Colors.red),
                            ),
                            const SizedBox(height: 20),
                            InkWell(
                              onTap: () async {
                                await login();
                              },
                              child: Container(
                                height: 55,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                  gradient: LinearGradient(
                                    colors: [
                                      primaryColor,
                                      secondaryColor
                                    ]
                                  )
                                ),
                                child: const Center(
                                  child: CustomText(text: "SIGN IN", color: Colors.white, fontSize: 20),
                                )
                              ),
                            ),
                            const SizedBox(height: 30)
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const CustomText(text: "Don't have an account?", fontSize: 16),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => const Register()));
                                },
                                style: ButtonStyle(
                                  padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                                    const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                                  ),
                                ),
                                child: const CustomText(text: "Sign Up", fontSize: 17),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
          isLoading ? const Loader() : const SizedBox(height: 0)
        ],
      ),
    );
  }
}
