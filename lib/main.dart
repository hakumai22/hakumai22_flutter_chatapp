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

String getChatId(String userId1, String userId2) {
  // ユーザーIDを昇順で並び替えて一意のチャットIDを作る
  List<String> sortedIds = [userId1, userId2]..sort();
  return "${sortedIds[0]}_${sortedIds[1]}";
}

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
    onError: (error) => print("Listen failed: $error"),
  );
  runApp(MyApp());
}

void ListenMethod(List<QueryDocumentSnapshot<Map<String, dynamic>>> datas) {
  if (datas.isEmpty) {
    return;
  }
  Map<String, dynamic> newestdata = Checknewestdata(datas);
  addmessageafterlisten(
    newestdata['from'],
    newestdata['to'],
    newestdata['message'],
    newestdata['timestamp'],
  );
}

void addmessageafterlisten(
  String from,
  String to,
  String message,
  int timestamp,
) {
  types.User user = types.User(
    id: '82091008-a484-4a89-ae75-a22bf8d6f3ac',
    firstName: "hakumai22",
    imageUrl: "images/genseki.png",
  );
  types.TextMessage textMessage = types.TextMessage(
    author: user,
    createdAt: timestamp,
    id: randomString(),
    text: message,
  );
  Uniquemessage uniquemessage = Uniquemessage(textMessage, from, to);

  _MainDisplayState()._addMessage(uniquemessage);
}

Map<String, dynamic> Checknewestdata(
  List<QueryDocumentSnapshot<Map<String, dynamic>>> datas,
) {
  datas.sort((a, b) => a.data()['timestamp'].compareTo(b.data()['timestamp']));
  print(datas.last.data());
  return datas.last.data();
}

String randomString() {
  final random = Random.secure();
  final values = List<int>.generate(16, (i) => random.nextInt(255));
  return base64UrlEncode(values);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ColorScheme Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: MainDisplay(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainDisplay extends StatefulWidget {
  @override
  _MainDisplayState createState() => _MainDisplayState();
}

class _MainDisplayState extends State<MainDisplay> {
  static List<types.Message> _messages = [];
  final String karifromuser = "56023";
  final String karitouser = "56024";
  final _byuser = const types.User(
    id: '82091008-a484-4a89-ae75-a22bf8d6f3ac',
    firstName: "hakumai22",
    imageUrl: "images/genseki.png",
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("テスト用のルーム"),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
        leading: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(100),
            onTap: () {
              if (overlayEntry == null) {
                showOverlay(context, false);
              } else {
                showOverlay(context, true);
              }
            },
            child: Container(
              margin: EdgeInsets.all(8),
              constraints: BoxConstraints.expand(),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: AssetImage("images/genseki.png"),
                ),
              ),
            ),
          ),
        ),
      ),

      body: Row(
        children: [
          //----------------------------左側ナビゲーション--------------------------
          Container(
            width: 200,
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            child: ListView(
              children: [
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {},
                    child: ListTile(
                      leading: Text(
                        "#",
                        style: TextStyle(
                          fontSize: 20,
                          //fontWeight: FontWeight.bold
                        ),
                      ),
                      title: Text('channel1'),
                    ),
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {},
                    child: ListTile(
                      leading: Text(
                        "#",
                        style: TextStyle(
                          fontSize: 20,
                          //fontWeight: FontWeight.bold,
                        ),
                      ),
                      title: Text('channel2'),
                    ),
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {},
                    child: ListTile(
                      leading: Text(
                        "#",
                        style: TextStyle(
                          fontSize: 20,
                          //fontWeight: FontWeight.bold,
                        ),
                      ),
                      title: Text('channel3'),
                    ),
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ],
            ),
          ),
          //--------------------------チャット画面--------------------------
          Expanded(
            child: Stack(
              children: [
                Container(
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
                ),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Chat(
                    user: _byuser,
                    messages: _messages,
                    onSendPressed: _handleSendPressed,
                    theme: DefaultChatTheme(
                      inputTextStyle: TextStyle(
                        color:
                            Theme.of(
                              context,
                            ).colorScheme.onSurface, // プレースホルダーテキストの色を薄いグレーに設定
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  //----------------------------メッセージを関連の関数--------------------------

  void _addMessage(Uniquemessage message) async {
    String chatId = getChatId(karifromuser, karitouser);
    setState(() {
      _messages.insert(0, message.message);
    });
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    await firestore.collection('chats').doc(chatId).collection('messages').add({
      'from': karifromuser,
      'to': karitouser,
      'message': message.message.text,
      'timestamp': message.message.createdAt,
    });
  }

  void _handleSendPressed(types.PartialText message) {
    final textMessage = types.TextMessage(
      author: _byuser,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: randomString(),
      text: message.text,
    );
    _addMessage(Uniquemessage(textMessage, karifromuser, karitouser));
  }
}

class Uniquemessage {
  String from;
  String to;
  types.TextMessage message;
  Uniquemessage(this.message, this.from, this.to);
}

//----------Overlayを表示する関数------------
OverlayEntry? overlayEntry;
void showOverlay(BuildContext context, bool a) {
  if (a) {
    overlayEntry?.remove();
    overlayEntry = null;
    return;
  }
  OverlayState? overlayState = Overlay.of(context);
  overlayEntry = OverlayEntry(
    builder:
        (context) => Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  overlayEntry?.remove();
                  overlayEntry = null;
                },
                child: Container(color: Colors.transparent),
              ),
            ),
            Positioned(
              top: 50,
              left: 20,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  child: Container(
                    width: 300,
                    height: 300,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.black.withOpacity(0.7),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Align(
                          child: InkWell(
                            onTap: () {
                              overlayEntry?.remove();
                              overlayEntry = null;
                            },
                            child: Icon(Icons.close, color: Colors.white),
                          ),
                          alignment: Alignment.centerRight,
                        ),
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: AssetImage("images/genseki.png"),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
  );
  overlayState.insert(overlayEntry!);
}
