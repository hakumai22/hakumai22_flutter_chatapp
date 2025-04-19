import 'dart:ui';
import 'package:flutter_floating_bottom_bar/flutter_floating_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
//---------------------My Code-------------------
import 'package:flutter_application_1/overlay.dart';
import 'package:flutter_application_1/struct/Uniquemessage.dart';
import 'MainDisplay.dart';
import 'SomeFunctions.dart';
import 'LoginDisplay.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseFirestore db = FirebaseFirestore.instance;
  final docRef = db
      .collection("chats")
      .doc(getChatId("56023", "56024"))
      .collection("messages");
  docRef.snapshots().listen(
    (event) => ListenMethod(event.docs),
    onError: (error) => debugPrint("Listen failed: $error"),
  );
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  const MyApp({super.key});
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ColorScheme Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: Logindisplay(),
      debugShowCheckedModeBanner: false,
    );
  }
}

//----------Overlayを表示する関数------------
