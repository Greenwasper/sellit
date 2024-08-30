import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sellit/components/loader.dart';

import '../components/custom_text.dart';
import 'chatroom.dart';

class Chat extends StatefulWidget {
  const Chat({super.key});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {

  User user = FirebaseAuth.instance.currentUser!;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List? chatRoomList;
  Map? userInfo;

  void getUserInfo () async {
    DocumentSnapshot userInfoSnapshot = await _firestore.collection('users').doc(user.uid).get();
    userInfo = userInfoSnapshot.data() as Map;
    print(userInfo);

    setState(() {

    });
  }

  void getChatRooms () async {
    QuerySnapshot q = await _firestore.collection('chatRoomList').get();
    chatRoomList = q.docs;
    setState(() {

    });
  }

  @override
  void initState() {
    super.initState();
    getChatRooms();
    getUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chats"),
      ),
      body: chatRoomList != null && userInfo != null ? StreamBuilder(
        stream: FirebaseFirestore.instance.collection('chatRoomList').snapshots(),
        builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting){
            return const Loader();
          }

          // print("Documents");
          // print(snapshot.data!.docs);

          return SingleChildScrollView(
            child: Column(
              children: [
                Column(
                  children: snapshot.data!.docs.map((doc){
                    Map data = doc.data() as Map;

                    // String docId = doc.id;
                    List<String> docIds = doc.id.split('_');
                    String userName = '';
                    String recipientId = '';
                    String recipientName = '';

                    if(docIds.contains(user.uid)){
                      if(docIds.indexOf(user.uid) == 0){
                        userName = doc[docIds[0]];
                        recipientId = docIds[1];
                        recipientName = doc[docIds[1]];
                      } else {
                        userName = doc[docIds[1]];
                        recipientId = docIds[0];
                        recipientName = doc[docIds[0]];
                      }

                      return Column(
                        children: [
                          ListTile(
                            leading: const CircleAvatar(
                              child: Icon(Icons.person),
                            ),
                            title: CustomText(text: recipientName),
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => ChatRoom(senderName: userName, receiverId: recipientId, receiverName: recipientName)));
                            },
                          ),
                          // const Divider(),
                        ],
                      );
                    }

                    return const SizedBox(height: 0);
                  }).toList(),
                ),
              ],
            ),
          );
        },
      ) : Container(
        height: double.infinity,
        width: double.infinity,
        color: Colors.white,
        child: const Center(
          child: CircularProgressIndicator(color: Colors.blue),
        ),
      ),
    );
  }
}
