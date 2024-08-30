import 'dart:async';

import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_dropdown/controllers/dropdown_controller.dart';
import 'package:cool_dropdown/cool_dropdown.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sellit/components/colors.dart';
import 'package:sellit/components/item.dart';
import 'package:sellit/components/loader.dart';
import 'package:sellit/components/marker_model.dart';
import 'package:sellit/views/chat.dart';
import 'package:uuid/uuid.dart';

import 'chatroom.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  User user = FirebaseAuth.instance.currentUser!;
  // LatLng? initialPosition;
  LatLng initialPosition = const LatLng(0, 0);
  bool isLoading = false;
  Map? userInfo;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();
  final TextEditingController _itemController = TextEditingController();
  Color homeColor = secondaryColor;
  Color dropdownColor = dropdownBlue;
  String action = 'Buy';
  int buyCounter = 1;
  int sellCounter = 1;
  List? pastBuySnapshots;
  List? pastSellSnapshots;
  List currentBuySnapshots = [];
  List currentSellSnapshots = [];
  Set<Marker> markers = {};

  bool selling = false;
  bool buying = false;
  String buttonText = "Continue";
  String uidInProgress = "";
  LatLng latlngInProgress = const LatLng(0, 0);

  Color oppositeColor (){
    return dropdownColor == dropdownGreen ? dropdownBlue : dropdownGreen;
  }

  DropdownController dropdownController = DropdownController();

  final List<String> _list = [
    'BUY',
    'SELL',
  ];

  void getPastBuySnapshots() async {
    QuerySnapshot snapshots = await _firestore.collection('buys').get();
    print('Buys_________________________');
    print(snapshots.docs);
    pastBuySnapshots = snapshots.docs;
    setState(() {

    });
  }

  void getPastSellSnapshots() async {
    QuerySnapshot snapshots = await _firestore.collection('sells').get();
    print('Sells________________________________');
    print(snapshots.docs);
    pastSellSnapshots = snapshots.docs;
    setState(() {

    });
  }

  void getUserInfo () async {
    DocumentSnapshot userInfoSnapshot = await _firestore.collection('users').doc(user.uid).get();
    userInfo = userInfoSnapshot.data() as Map;
    print(userInfo);

    setState(() {

    });
  }

  void getInitialPosition () async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    initialPosition = LatLng(position.latitude, position.longitude);
    setState(() {

    });
  }

  void triggerLoading () {

  }

  @override
  void initState() {
    super.initState();
    getPastBuySnapshots();
    getPastSellSnapshots();
    getUserInfo();
    getInitialPosition();
  }

  @override
  Widget build(BuildContext context) {
    sellCounter = 1;
    buyCounter = 1;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 65,
        backgroundColor: homeColor,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const Chat()));
            },
            icon: const Icon(Icons.chat_bubble_outline),
          )
        ],
      ),
      body: Stack(
        children: [
          SizedBox(
            height: double.infinity,
            child: initialPosition != null ? Consumer<MarkerModel>(
              builder: (context, value, child) {
                // markers = value.markers;
                return Stack(
                  children: [
                    GoogleMap(
                      mapType: MapType.hybrid,
                      initialCameraPosition: const CameraPosition(
                        target: LatLng(6.6747, -1.5717),
                        // target: initialPosition!,
                        zoom: 14.4746,
                      ),
                      markers: value.markers,
                      onMapCreated: (GoogleMapController controller) {
                        _controller.complete(controller);
                      },
                    ),
                    isLoading ? const Loader() : const SizedBox()
                  ],
                );
              }
            ) : Container(
              height: double.infinity,
              width: double.infinity,
              color: Colors.white,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.blue),
              ),
            ),
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.2,
            minChildSize: 0.1,
            maxChildSize: 0.2,
            builder: (context, scrollController) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: homeColor,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(30),
                    topLeft: Radius.circular(30),
                  ), // Add border radius
                ),
                child: ListView(
                  controller: scrollController,
                  children: [
                    const SizedBox(height: 7),
                    Center(
                      child: Container(
                        height: 5,
                        width: 50,
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: CustomDropdown<String>(
                            closedHeaderPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                            decoration: CustomDropdownDecoration(
                              closedBorderRadius: BorderRadius.circular(50),
                              closedFillColor: dropdownColor,
                              expandedFillColor: dropdownColor,
                              closedBorder: Border.all(
                                color: Colors.black,
                                width: 1,
                              ),
                              headerStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              listItemDecoration: ListItemDecoration(
                                splashColor: oppositeColor(),
                                highlightColor: oppositeColor(),
                                selectedColor: oppositeColor()
                              )
                            ),
                            hintText: 'Select job role',
                            items: _list,
                            initialItem: _list[0],
                            onChanged: (value) {
                              if(value == 'SELL'){
                                setState(() {
                                  action = "Sell";
                                  homeColor = primaryColor;
                                  dropdownColor = dropdownGreen;
                                });
                              } else{
                                setState(() {
                                  action = "Buy";
                                  homeColor = secondaryColor;
                                  dropdownColor = dropdownBlue;
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          flex: 5,
                          child: TextField(
                            controller: _itemController,
                            decoration: InputDecoration(
                              constraints: const BoxConstraints(maxHeight: 40),
                              hintText: "What Would You Like To $action",
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(100)
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(100)
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    pastSellSnapshots != null && pastBuySnapshots != null && userInfo != null ? ElevatedButton(
                      onPressed: () async {
                        if(isLoading){return;}

                        setState(() {
                          isLoading = true;
                          buttonText = "Loading...";
                        });

                        String uid = const Uuid().v4();

                        if(buying || selling){
                          context.read<MarkerModel>().removeMarker(latlngInProgress);

                          if(buying){
                            await _firestore.collection('buys').doc(uidInProgress).delete();
                          } else {
                            await _firestore.collection('sells').doc(uidInProgress).delete();
                          }

                          setState(() {
                            isLoading = false;
                            buttonText = "Continue";
                            buying = false;
                            selling = false;
                            uidInProgress = "";
                            latlngInProgress = const LatLng(0, 0);
                          });
                          return;
                        }

                        if(action == 'Buy'){
                          buying = true;
                        } else {
                          selling = true;
                        }

                        Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
                        Map<String, dynamic> item = Item(
                          name: _itemController.text,
                          sellerId: action == "Sell" ? user.uid : '',
                          buyerId: action == "Buy" ? user.uid : '',
                          sellerName: action == "Sell" ? "${userInfo!['first_name']} ${userInfo!['last_name']}" : '',
                          buyerName: action == "Buy" ? "${userInfo!['first_name']} ${userInfo!['last_name']}" : '',
                          timestamp: Timestamp.now(),
                          coordinates: [position.latitude, position.longitude]
                        ).toMap();

                        uidInProgress = uid;
                        latlngInProgress = LatLng(position.latitude, position.longitude);

                        if(action == 'Buy'){
                          await _firestore.collection('buys').doc(uid).set(item);
                        } else {
                          await _firestore.collection('sells').doc(uid).set(item);
                        }

                        setState(() {
                          isLoading = false;
                          buttonText = "Cancel";
                        });

                        // Future.delayed(const Duration(seconds: 20), () {
                        //   setState(() {
                        //     buttonText = "Continue";
                        //     buying = false;
                        //     selling = false;
                        //   });
                        // });

                        print(action);
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 1,
                        backgroundColor: dropdownColor,
                        foregroundColor: Colors.white
                      ),
                      child: Text(buttonText),
                    ) : const SizedBox(),
                    pastSellSnapshots != null ? StreamBuilder(
                      stream: _firestore.collection('sells').orderBy('timestamp', descending: false).snapshots(),
                      builder: (context, snapshot) {
                        if(snapshot.connectionState == ConnectionState.waiting){
                          return const SizedBox();
                        }

                        currentSellSnapshots = snapshot.data!.docs;

                        print(pastSellSnapshots!.length);
                        print(currentSellSnapshots.length);

                        // print(snapshot.data!.docs[0].id);
                        // print("Counter: $counter");

                        if(currentSellSnapshots.length > pastSellSnapshots!.length) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("${currentSellSnapshots.last['sellerName']} wants to sell ${currentSellSnapshots.last['name']}", style: TextStyle(color: Colors.black)),
                                dismissDirection: DismissDirection.down,
                                backgroundColor: Colors.white,
                                behavior: SnackBarBehavior.floating,
                                margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height-150, left: 10, right: 10),
                                action: SnackBarAction(
                                  textColor: Colors.blue,
                                  label: 'OK',
                                  onPressed: () {

                                  },
                                ),
                                duration: const Duration(seconds: 2),
                              ),
                            );

                            context.read<MarkerModel>().addMarker(Marker(
                              position: LatLng(currentSellSnapshots.last['coordinates'][0], currentSellSnapshots.last['coordinates'][1]),
                              markerId: MarkerId(const Uuid().v4()),
                              infoWindow: InfoWindow(
                                title: currentSellSnapshots.last['name'],
                                snippet: currentSellSnapshots.last['sellerName'] == '' ? "Tap to message ${currentSellSnapshots.last['buyerName']}" : "Tap to message ${currentSellSnapshots.last['sellerName']}",
                                onTap: () {
                                  print(currentSellSnapshots.last['sellerId'] == '' ? currentSellSnapshots.last['buyerId'] : currentSellSnapshots.last['sellerId']);
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => ChatRoom(
                                      senderName: "${userInfo!['first_name']} ${userInfo!['last_name']}",
                                      receiverId: currentSellSnapshots.last['sellerId'] == '' ? currentSellSnapshots.last['buyerId'] : currentSellSnapshots.last['sellerId'],
                                      receiverName: currentSellSnapshots.last['sellerName'] == '' ? currentSellSnapshots.last['buyerName'] : currentSellSnapshots.last['sellerName']))
                                  );
                                }
                              ),
                            ));
                          });
                        } else {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            context.read<MarkerModel>().emptyMarkers();
                            Set<Marker> newMarkers = {};
                            for(var currentSellSnapshot in currentSellSnapshots){
                              newMarkers.add(Marker(
                                position: LatLng(currentSellSnapshot['coordinates'][0], currentSellSnapshot['coordinates'][1]),
                                markerId: MarkerId(const Uuid().v4()),
                                infoWindow: InfoWindow(
                                  title: currentSellSnapshot['name'],
                                  snippet: currentSellSnapshot['sellerName'] == '' ? "Tap to message ${currentSellSnapshot['buyerName']}" : "Tap to message ${currentSellSnapshot['sellerName']}",
                                  onTap: () {
                                    print(currentSellSnapshot['sellerId'] == '' ? currentSellSnapshot['buyerId'] : currentSellSnapshot['sellerId']);
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => ChatRoom(
                                        senderName: "${userInfo!['first_name']} ${userInfo!['last_name']}",
                                        receiverId: currentSellSnapshot['sellerId'] == '' ? currentSellSnapshot['buyerId'] : currentSellSnapshot['sellerId'],
                                        receiverName: currentSellSnapshot['sellerName'] == '' ? currentSellSnapshot['buyerName'] : currentSellSnapshot['sellerName']))
                                    );
                                  }
                                ),
                              ));
                            }
                            context.read<MarkerModel>().setMarkers(newMarkers);
                          });
                        }

                        pastSellSnapshots = currentSellSnapshots;

                        sellCounter++;

                        return const SizedBox();
                      },
                    ) : const SizedBox(),
                    pastBuySnapshots != null ? StreamBuilder(
                      stream: _firestore.collection('buys').orderBy('timestamp', descending: false).snapshots(),
                      builder: (context, snapshot) {
                        if(snapshot.connectionState == ConnectionState.waiting){
                          return const SizedBox();
                        }

                        currentBuySnapshots = snapshot.data!.docs;

                        print(pastBuySnapshots!.length);
                        print(currentBuySnapshots.length);

                        // print(snapshot.data!.docs[0].id);
                        // print("Counter: $counter");

                        if(currentBuySnapshots.length > pastBuySnapshots!.length) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("${currentBuySnapshots.last['buyerName']} wants to buy ${currentBuySnapshots.last['name']}", style: TextStyle(color: Colors.black)),
                                dismissDirection: DismissDirection.down,
                                backgroundColor: Colors.white,
                                behavior: SnackBarBehavior.floating,
                                margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height-150, left: 10, right: 10),
                                action: SnackBarAction(
                                  textColor: Colors.blue,
                                  label: 'OK',
                                  onPressed: () {

                                  },
                                ),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          });
                        }

                        pastBuySnapshots = currentBuySnapshots;

                        buyCounter++;
                        return const SizedBox();
                      },
                    ) : const SizedBox(),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Drawer Header',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              title: Text('Item 1'),
              onTap: () {
                // Handle item 1 tap
                Navigator.pop(context); // Close the drawer
              },
            ),
            ListTile(
              title: Text('Item 2'),
              onTap: () {
                // Handle item 2 tap
                Navigator.pop(context); // Close the drawer
              },
            ),
            ListTile(
              title: Text('Log Out'),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
