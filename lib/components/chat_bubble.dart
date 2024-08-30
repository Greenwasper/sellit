import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sellit/components/colors.dart';
import 'package:sellit/components/functions.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'custom_text.dart';


class ChatBubble extends StatelessWidget {

  final String message;
  final bool isSender;
  final Timestamp timeStamp;

  const ChatBubble({super.key, required this.message, required this.isSender, required this.timeStamp});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 300),
      margin: const EdgeInsets.only(top: 5, bottom: 5),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
              colors: [
                isSender ? primaryColor : Colors.blue.shade400,
                isSender ? secondaryColor : Colors.blue.shade400
              ]
          )
      ),
      child: Column(
        crossAxisAlignment: isSender? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          CustomText(text: message, color: Colors.white, fontSize: 18),
          const SizedBox(height: 5),
          CustomText(text: formatDateFull(timeStamp.toDate()), color: Colors.white, fontSize: 11),
        ],
      ),
    );
  }
}
