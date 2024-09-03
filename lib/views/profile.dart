import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sellit/components/colors.dart';

import '../components/custom_text.dart';
import '../components/loader.dart';
import '../components/switch_tile.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {

  bool isLoading = false;

  List<bool> tileValues = [false];

  User? user = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String userEmail = '';
  Map userInfo = {};

  final TextEditingController _firstName = TextEditingController(text: "Loading...");
  final TextEditingController _lastName = TextEditingController(text: "Loading...");
  final TextEditingController _phone = TextEditingController(text: "Loading...");

  bool isEditingFirstName = false;
  bool isEditingLastName = false;
  bool isEditingPhone = false;

  void getUserInfo () async {
    DocumentSnapshot userInfoSnapshot = await _firestore.collection('users').doc(user!.uid).get();
    userInfo = userInfoSnapshot.data() as Map;
    print(userInfo);

    _firstName.text = userInfo['first_name'];
    _lastName.text = userInfo['last_name'];
    _phone.text = userInfo['phone_number'];

    setState(() {

    });
  }

  @override
  void initState() {
    // TODO: implement initState
    if(user == null){
      userEmail = 'Not logged in';
    } else {
      userEmail = user!.email!;
    }

    getUserInfo();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                primaryColor,
                secondaryColor
              ]
            )
          ),
        ),
        // backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(
          color: Colors.white, // Change the drawer icon color to white
        ),
        elevation: 0,
      ),
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
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 40,
                        child: Icon(Icons.person, size: 40),
                      ),
                      const SizedBox(height: 10),
                      CustomText(text: userInfo.isEmpty ? 'Loading...' : "${userInfo['first_name']} ${userInfo['last_name']}", color: Colors.white, fontSize: 30, textAlign: TextAlign.center,),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () async {
                          await FirebaseAuth.instance.signOut();
                          if(mounted){
                            Navigator.pop(context);
                          }
                        },
                        child: Container(
                            height: 50,
                            width: 200,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(40),
                                gradient: LinearGradient(
                                    colors: [
                                      Colors.red.shade400,
                                      Colors.red.shade400,
                                    ]
                                )
                            ),
                            child: const Center(
                              child: CustomText(text: "Logout", color: Colors.white, fontSize: 17),
                            )
                        ),
                      ),
                    ],
                  ),
                )
              ),
              Padding(
                padding: const EdgeInsets.only(top: 280),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        const CustomText(text: "Edit Profile", fontSize: 20),
                        const SizedBox(height: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const CustomText(text: "First Name", fontSize: 12),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _firstName,
                                    enabled: isEditingFirstName,
                                    style: const TextStyle(color: Colors.black),
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      enabledBorder: isEditingFirstName ? const UnderlineInputBorder() : null,
                                      focusedBorder: isEditingFirstName ?  const UnderlineInputBorder() : null,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                isEditingFirstName ?
                                IconButton(
                                  onPressed: () {
                                    _firestore.collection('users').doc(user!.uid).update({
                                      'first_name': _firstName.text
                                    });

                                    setState(() {
                                      isEditingFirstName = false;
                                    });
                                  },
                                  icon: const Icon(Icons.check),
                                  color: Colors.black,
                                ) :
                                IconButton(
                                  onPressed: (){
                                    setState(() {
                                      isEditingFirstName = true;
                                    });
                                  },
                                  icon: const Icon(Icons.edit),
                                  color: Colors.black,
                                )
                              ],
                            )
                          ],
                        ),
                        const SizedBox(height: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const CustomText(text: "Last Name", fontSize: 12),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _lastName,
                                    enabled: isEditingLastName,
                                    style: const TextStyle(color: Colors.black),
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      enabledBorder: isEditingLastName ? const UnderlineInputBorder() : null,
                                      focusedBorder: isEditingLastName ?  const UnderlineInputBorder() : null,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                isEditingLastName ?
                                IconButton(
                                  onPressed: (){
                                    _firestore.collection('users').doc(user!.uid).update({
                                      'last_name': _lastName.text
                                    });
                                    setState(() {
                                      isEditingLastName = false;
                                    });
                                  },
                                  icon: const Icon(Icons.check),
                                  color: Colors.black,
                                ) :
                                IconButton(
                                  onPressed: (){
                                    setState(() {
                                      isEditingLastName = true;
                                    });
                                  },
                                  icon: const Icon(Icons.edit),
                                  color: Colors.black,
                                )
                              ],
                            )
                          ],
                        ),
                        const SizedBox(height: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const CustomText(text: "Phone Number", fontSize: 12),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _phone,
                                    enabled: isEditingPhone,
                                    style: const TextStyle(color: Colors.black),
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      enabledBorder: isEditingPhone ? const UnderlineInputBorder() : null,
                                      focusedBorder: isEditingPhone ?  const UnderlineInputBorder() : null,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                isEditingPhone ?
                                IconButton(
                                  onPressed: (){
                                    _firestore.collection('users').doc(user!.uid).update({
                                      'phone_number': _phone.text
                                    });

                                    setState(() {
                                      isEditingPhone = false;
                                    });
                                  },
                                  icon: const Icon(Icons.check),
                                  color: Colors.black,
                                ) :
                                IconButton(
                                  onPressed: (){
                                    setState(() {
                                      isEditingPhone = true;
                                    });
                                  },
                                  icon: const Icon(Icons.edit),
                                  color: Colors.black,
                                )
                              ],
                            )
                          ],
                        ),
                        const SizedBox(height: 20),
                        const CustomText(text: "Settings", fontSize: 20),
                        const SizedBox(height: 20),
                        Column(
                          children: List.generate(tileValues.length, (index) {
                            return CustomSwitchTile(
                              title: "Enable Notifications",
                              subtitle: "Receive Notifications",
                              icon: Icons.notifications,
                              iconBackgroundColor: Colors.pink,
                              value: tileValues[index],
                              onChanged: (value) {
                                setState(() {
                                  tileValues[index] = value;
                                });
                              },
                            );
                          }),
                        ),
                      ]
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
