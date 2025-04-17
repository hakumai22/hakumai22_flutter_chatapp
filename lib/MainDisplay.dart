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
import 'package:flutter_application_1/overlay.dart';
import 'package:flutter_application_1/struct/Uniquemessage.dart';
import 'package:flutter_application_1/SomeFunctions.dart';

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
  void initState() {
    super.initState();
    // コールバックの登録
    addMessageCallback = _addMessage;
  }

  @override
  void dispose() {
    // コールバックの解除
    addMessageCallback = null;
    super.dispose();
  }

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
  void _addMessage(Uniquemessage message, {bool addcloud = true}) async {
    String chatId = getChatId(karifromuser, karitouser);
    setState(() {
      _messages.insert(0, message.message);
    });
    if (!addcloud) {
      return;
    }
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
