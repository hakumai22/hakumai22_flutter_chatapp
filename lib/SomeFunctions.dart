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
import 'package:flutter_application_1/struct/Uniquemessage.dart';
import 'package:flutter_application_1/overlay.dart';
import 'package:flutter_application_1/MainDisplay.dart';
import 'main.dart';
import 'LoginDisplay.dart';

// メッセージ処理用のコールバック
typedef MessageHandler = void Function(Uniquemessage message, {bool addcloud});
MessageHandler? addMessageCallback;

// クラウド送信専用のコールバック
typedef CloudSendHandler = void Function(Uniquemessage message);
CloudSendHandler? cloudSendCallback;

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

String getChatId(String userId1, String userId2) {
  // ユーザーIDを昇順で並び替えて一意のチャットIDを作る
  List<String> sortedIds = [userId1, userId2]..sort();
  return "${sortedIds[0]}_${sortedIds[1]}";
}

Future<List<String>> SearchbyuserId(String userId) async {
  //テスト用に入ってくるidは56023
  FirebaseFirestore db = FirebaseFirestore.instance;
  List<String> userNameMatchIds = [];
  try {
    QuerySnapshot<Map<String, dynamic>> snapshot =
        await db.collection('chats').get();
    print(snapshot.docs.length);
    for (var doc in snapshot.docs) {
      if (doc.id.contains(userId)) {
        debugPrint(doc.id.replaceAll(userId, "").replaceAll("_", ""));
        userNameMatchIds.add(doc.id.replaceAll(userId, "").replaceAll("-", ""));
      }
    } //forが回されていないので、snapshot.docsの中身が空になっている。
  } catch (e) {
    print("エラーが発生しました: $e");
  }
  final querySnapshot =
      await FirebaseFirestore.instance.collection('chats').get();

  // 各ドキュメントのIDをリストで取得
  List<String> documentIds = querySnapshot.docs.map((doc) => doc.id).toList();
  return userNameMatchIds; //後々userNameMatchIdsの中身が何もなかった場合はエラーを表示させるかなんかする。（それかようこそ画面？みたいな）
}

Future<bool> doesCollectionExist(String collectionName) async {
  final snapshot =
      await FirebaseFirestore.instance
          .collection(collectionName)
          .limit(1)
          .get();
  return snapshot.docs.isNotEmpty;
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
  // コールバックを呼び出す
  if (addMessageCallback != null) {
    addMessageCallback!(uniquemessage, addcloud: false);
  } else {
    print("メッセージハンドラーが登録されていません");
  }
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
