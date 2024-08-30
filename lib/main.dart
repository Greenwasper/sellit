import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:sellit/views/auth_page.dart';
import 'package:sellit/views/home.dart';
import 'package:sellit/views/login.dart';

import 'components/marker_model.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  String? fcm = await FirebaseMessaging.instance.getToken();
  await FirebaseMessaging.instance.requestPermission();
  await Permission.location.request();
  print("Token:${fcm!}");
  runApp(
    ChangeNotifierProvider(
      create: (context) => MarkerModel(),
      child: const MyApp()
    )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sellit',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const AuthPage()
    );
  }
}

