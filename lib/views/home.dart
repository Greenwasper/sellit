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
import 'package:sellit/components/custom_text.dart';
import 'package:sellit/components/item.dart';
import 'package:sellit/components/loader.dart';
import 'package:sellit/components/marker_model.dart';
import 'package:sellit/views/chat.dart';
import 'package:sellit/views/profile.dart';
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
  BitmapDescriptor? customBuyIcon;
  BitmapDescriptor? customSellIcon;

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
    print("User Info");
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

  Future<void> _loadCustomBuyMarker() async {
    customBuyIcon = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(48, 48)),
      'assets/marker-blue.png', // Path to the custom image asset
    );
    setState(() {});
  }

  Future<void> _loadCustomSellMarker() async {
    customSellIcon = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(48, 48)),
      'assets/marker-green.png', // Path to the custom image asset
    );
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getPastBuySnapshots();
    getPastSellSnapshots();
    getUserInfo();
    getInitialPosition();
    _loadCustomBuyMarker();
    _loadCustomSellMarker();
  }

  @override
  void dispose() {
    super.dispose();
    _itemController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    sellCounter = 1;
    buyCounter = 1;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 65,
        backgroundColor: homeColor,
        title: const Text("Sell It", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: () {
              FocusScope.of(context).unfocus();
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
                        FocusScope.of(context).unfocus();
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

                        if(currentSellSnapshots.length > pastSellSnapshots!.length) {
                          WidgetsBinding.instance.addPostFrameCallback((_) async {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("${currentSellSnapshots.last['sellerName']} wants to sell ${currentSellSnapshots.last['name']}", style: TextStyle(color: Colors.grey.shade200)),
                                dismissDirection: DismissDirection.down,
                                backgroundColor: dropdownGreen,
                                behavior: SnackBarBehavior.floating,
                                margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height-150, left: 10, right: 10),
                                action: SnackBarAction(
                                  textColor: Colors.white,
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
                          // WidgetsBinding.instance.addPostFrameCallback((_) async {
                          //   context.read<MarkerModel>().emptyMarkers();
                          //   Set<Marker> newMarkers = {};
                          //   for(var currentSellSnapshot in currentSellSnapshots){
                          //     newMarkers.add(Marker(
                          //       position: LatLng(currentSellSnapshot['coordinates'][0], currentSellSnapshot['coordinates'][1]),
                          //       markerId: MarkerId(const Uuid().v4()),
                          //       // icon: await BitmapDescriptor.asset(
                          //       //   const ImageConfiguration(size: Size(48, 48)),
                          //       //   'assets/marker-green.png',
                          //       // ),
                          //       infoWindow: InfoWindow(
                          //         title: currentSellSnapshot['name'],
                          //         snippet: currentSellSnapshot['sellerName'] == '' ? "Tap to message ${currentSellSnapshot['buyerName']}" : "Tap to message ${currentSellSnapshot['sellerName']}",
                          //         onTap: () {
                          //           print(currentSellSnapshot['sellerId'] == '' ? currentSellSnapshot['buyerId'] : currentSellSnapshot['sellerId']);
                          //           Navigator.push(context, MaterialPageRoute(builder: (context) => ChatRoom(
                          //               senderName: "${userInfo!['first_name']} ${userInfo!['last_name']}",
                          //               receiverId: currentSellSnapshot['sellerId'] == '' ? currentSellSnapshot['buyerId'] : currentSellSnapshot['sellerId'],
                          //               receiverName: currentSellSnapshot['sellerName'] == '' ? currentSellSnapshot['buyerName'] : currentSellSnapshot['sellerName']))
                          //           );
                          //         }
                          //       ),
                          //     ));
                          //   }
                          //   context.read<MarkerModel>().setMarkers(newMarkers);
                          // });
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

                        if(currentBuySnapshots.length > pastBuySnapshots!.length) {
                          WidgetsBinding.instance.addPostFrameCallback((_) async {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("${currentBuySnapshots.last['buyerName']} wants to buy ${currentBuySnapshots.last['name']}", style: TextStyle(color: Colors.grey.shade200)),
                                dismissDirection: DismissDirection.down,
                                backgroundColor: dropdownBlue,
                                behavior: SnackBarBehavior.floating,
                                margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height-150, left: 10, right: 10),
                                action: SnackBarAction(
                                  textColor: Colors.white,
                                  label: 'OK',
                                  onPressed: () {

                                  },
                                ),
                                duration: const Duration(seconds: 2),
                              ),
                            );

                            context.read<MarkerModel>().addMarker(Marker(
                              position: LatLng(currentBuySnapshots.last['coordinates'][0], currentBuySnapshots.last['coordinates'][1]),
                              markerId: MarkerId(const Uuid().v4()),
                              infoWindow: InfoWindow(
                                title: currentBuySnapshots.last['name'],
                                snippet: currentBuySnapshots.last['sellerName'] == '' ? "Tap to message ${currentBuySnapshots.last['buyerName']}" : "Tap to message ${currentBuySnapshots.last['sellerName']}",
                                onTap: () {
                                  print(currentBuySnapshots.last['sellerId'] == '' ? currentBuySnapshots.last['buyerId'] : currentBuySnapshots.last['sellerId']);
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => ChatRoom(
                                      senderName: "${userInfo!['first_name']} ${userInfo!['last_name']}",
                                      receiverId: currentBuySnapshots.last['sellerId'] == '' ? currentBuySnapshots.last['buyerId'] : currentBuySnapshots.last['sellerId'],
                                      receiverName: currentBuySnapshots.last['sellerName'] == '' ? currentBuySnapshots.last['buyerName'] : currentBuySnapshots.last['sellerName']))
                                  );
                                }
                              ),
                            ));
                          });
                        } else {
                          WidgetsBinding.instance.addPostFrameCallback((_) async {
                            context.read<MarkerModel>().emptyMarkers();
                            Set<Marker> newMarkers = {};
                            for(var currentSellSnapshot in currentSellSnapshots){
                              newMarkers.add(Marker(
                                position: LatLng(currentSellSnapshot['coordinates'][0], currentSellSnapshot['coordinates'][1]),
                                markerId: MarkerId(const Uuid().v4()),
                                icon: await BitmapDescriptor.asset(
                                  const ImageConfiguration(size: Size(48, 48)),
                                  'assets/marker-green.png',
                                ),
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
                            for(var currentSellSnapshot in currentBuySnapshots){
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
            Container(
              height: 250,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    primaryColor,
                    secondaryColor
                  ]
                )
              ),
              child: SafeArea(
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/sellit.png', width: 100),
                      const SizedBox(height: 15),
                      const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(text: "Sell It", fontSize: 30, color: Colors.white),
                          // CustomText(text: "+233545548038"),
                          // CustomText(text: "banyanful@gmail.com"),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.question_mark),
              title: const Text('About'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const Profile()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Log Out'),
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
