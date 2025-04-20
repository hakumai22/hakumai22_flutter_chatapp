import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:ui';
import 'barrel.dart';

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
