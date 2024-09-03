import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:sellit/components/colors.dart';

import '../components/custom_text.dart';
import '../components/field.dart';
import '../components/loader.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {

  bool isLoading = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _firstName = TextEditingController();
  final TextEditingController _lastName = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _phoneNumber = TextEditingController();
  final TextEditingController _password = TextEditingController();

  bool passwordObscured = false;

  void register () async {
    bool isError = false;

    setState(() {
      isLoading = true;
    });

    try{
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _email.text.trim(),
          password: _password.text.trim()
      );

      _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'first_name': _firstName.text,
        'last_name': _lastName.text,
        'email': userCredential.user!.email,
        'phone_number': _phoneNumber.text
      });

      isError = false;

      if(mounted){
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      isError = true;
      setState(() {
        isLoading = false;
      });

      print(e.code);

      // if (e.code == 'invalid-email') {
      //   // Invalid email format, remember to trim
      //   toast("Invalid Email Format");
      // } else if (e.code == 'invalid-credential') {
      //   // Incorrect email or password
      //   toast("Incorrect Email or Password");
      // }
    }

    if(!isError){
      // FirebaseFirestore.instance.collection('users').doc(userCredentials!.user!.uid).set({
      //   'uid': userCredentials.user!.uid,
      //   'email': userCredentials.user!.email,
      //   'first_name': _firstName.text,
      //   'last_name': _lastName.text,
      //   'user_name': _username.text
      // });
    }
  }

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
                  child: CustomText(text: 'Register', color: Colors.white, fontSize: 40),
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
                        const SizedBox(height: 120),
                        Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Field(
                                    controller: _firstName,
                                    labelText: "First Name",
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: Expanded(
                                    child: Field(
                                      controller: _lastName,
                                      labelText: "Last Name",
                                    ),
                                  ),
                                )
                              ]
                            ),
                            const SizedBox(height: 20),
                            Field(
                              controller: _email,
                              labelText: "Email",
                              textInputType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 20),
                            InternationalPhoneNumberInput(
                              hintText: '',
                              initialValue: PhoneNumber(isoCode: 'GH'),
                              selectorConfig: const SelectorConfig(
                                selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                              ),
                              cursorColor: Colors.black,
                              inputDecoration: const InputDecoration(
                                label: Text("Phone", style: TextStyle(color: Colors.black)),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black)
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black)
                                ),
                              ),
                              onInputChanged: (phoneNumber) {
                                _phoneNumber.text = phoneNumber.phoneNumber!;
                              },
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: _password,
                              obscureText: passwordObscured,
                              autocorrect: false,
                              enableSuggestions: false,
                              decoration: InputDecoration(
                                suffix: IconButton(
                                  onPressed: setPasswordObscured,
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
                            const SizedBox(height: 30),
                            InkWell(
                              onTap: () async {
                                register();
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
                                  child: CustomText(text: "REGISTER", color: Colors.white, fontSize: 20),
                                )
                              ),
                            ),
                            const SizedBox(height: 30)
                          ],
                        ),
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
