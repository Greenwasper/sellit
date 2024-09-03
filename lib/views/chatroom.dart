import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../components/chat_bubble.dart';
import '../components/colors.dart';
import '../components/message.dart';


class ChatRoom extends StatefulWidget {

  final String senderName;
  final String receiverId;
  final String receiverName;

  const ChatRoom({super.key, required this.senderName, required this.receiverId, required this.receiverName});

  @override
  State<ChatRoom> createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {

  User? user = FirebaseAuth.instance.currentUser;
  final TextEditingController _messageController = TextEditingController();

  final ScrollController _scrollController = ScrollController();
  bool updatedChatRoomList = false;

  Future<void> sendMessage () async {
    List<String> ids = [user!.uid, widget.receiverId];
    ids.sort();
    String chatRoomId = ids.join('_');

    if(!updatedChatRoomList){
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection('chatRoomList').doc(chatRoomId).get();

      if(!doc.exists){
        await FirebaseFirestore.instance.collection('chatRoomList').doc(chatRoomId).set({
          user!.uid: widget.senderName,
          widget.receiverId: widget.receiverName
        });
      }

      updatedChatRoomList = true;
    }

    Timestamp timestamp = Timestamp.now();

    Message newMessage = Message(
      senderId: user!.uid,
      senderEmail: user!.email!,
      receiverId: widget.receiverId,
      message: _messageController.text,
      timeStamp: timestamp
    );

    _messageController.clear();
    await FirebaseFirestore.instance.collection('chatRooms').doc(chatRoomId).collection('messages').add(newMessage.toMap());
    // _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
  }

  Stream<QuerySnapshot> getMessages () {
    List<String> ids = [user!.uid, widget.receiverId];
    ids.sort();
    String chatRoomId = ids.join('_');

    return FirebaseFirestore.instance.collection('chatRooms').doc(chatRoomId).collection('messages').orderBy('timeStamp', descending: false).snapshots();
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
    _messageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AppBar(
          flexibleSpace: Container(
            decoration: BoxDecoration(gradient: LinearGradient(colors: [primaryColor, secondaryColor])),
          ),
          title: Row(
            children: [
              const CircleAvatar(
                child: Icon(Icons.person),
              ),
              const SizedBox(width: 15),
              Text(widget.receiverName, style: const TextStyle(color: Colors.white))
            ],
          ),
          iconTheme: const IconThemeData(
            color: Colors.white, // Change the drawer icon color to white
          ),
          elevation: 0,
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            opacity: 1,
            image: AssetImage('assets/chat_wallpaper.webp'),
            fit: BoxFit.cover
          )
        ),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                stream: getMessages(),
                builder: (context, snapshot) {
                  if(snapshot.hasError){
                    return const Text("Error loading messages");
                  }

                  if(snapshot.connectionState == ConnectionState.waiting){
                    return Container(
                      height: double.infinity,
                      width: double.infinity,
                      color: Colors.transparent,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
                  });

                  return Padding(
                    padding: const EdgeInsets.only(left: 8, right: 8),
                    child: ListView(
                      controller: _scrollController,
                      children: snapshot.data!.docs.map((doc){
                        Map data = doc.data() as Map;

                        return Container(
                          alignment: data['senderId'] == user!.uid ? Alignment.centerRight : Alignment.centerLeft,
                          child: Column(
                            children: [
                              ChatBubble(
                                message: data['message'],
                                isSender: data['senderId'] == user!.uid,
                                timeStamp: data['timeStamp'],
                              ),
                            ],
                          )
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      style: const TextStyle(letterSpacing: 0.1),
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        hintText: "Enter message...",
                        border: InputBorder.none,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(40),
                          borderSide: BorderSide.none
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(40),
                          borderSide: BorderSide.none
                        ),
                        suffixIcon: GestureDetector(
                          onTap: sendMessage,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [primaryColor, secondaryColor]),
                              borderRadius: BorderRadius.circular(40)
                            ),
                            child: const Icon(Icons.send, color: Colors.white),
                          ),
                        )
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
