import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:ui';
import 'barrel.dart';

// メッセージ処理用のコールバック
typedef MessageHandler = void Function(Uniquemessage message, {bool addcloud});
MessageHandler? addMessageCallback;

// クラウド送信専用のコールバック
typedef CloudSendHandler = void Function(Uniquemessage message);
CloudSendHandler? cloudSendCallback;

void ListenMethod(
  List<QueryDocumentSnapshot<Map<String, dynamic>>> datas,
  CustomUser? customuser,
) {
  if (datas.isEmpty) {
    return;
  }
  Map<String, dynamic> newestdata = Checknewestdata(datas);
  addmessageafterlisten(
    newestdata['message'],
    newestdata['to'],
    newestdata['timestamp'],
    customuser,
  );
}

Future<CustomUser?> findUserInfo(String userId) async {
  FirebaseFirestore db = FirebaseFirestore.instance;
  DocumentSnapshot doc = await db.collection("users").doc(userId).get();
  if (doc.exists) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    if (data['UserName'] == null ||
        data['password'] == null ||
        data['email'] == null ||
        data['imagePath'] == null) {
      debugPrint("Firestoreデータに不足があります");
    }
    debugPrint(
      userId +
          data['UserName'] +
          data['password'] +
          data['email'] +
          data['imagePath'],
    );
    return CustomUser(
      userId,
      data['UserName'],
      data['password'],
      data['email'],
      data['imagePath'],
      types.User(
        id: userId,
        firstName: data["UserName"],
        imageUrl: "images/genseki.png",
      ),
    );
  } else {
    debugPrint("ユーザーが見つかりません");
    return null;
  }
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
  String message,
  String to,
  int timestamp,
  CustomUser? customuser,
) {
  if (customuser == null) {
    print("ユーザー情報が取得できませんでした");
    return;
  }
  types.User user = types.User(
    id: customuser.userId,
    firstName: customuser.userName,
    imageUrl: customuser.imagePath,
  );
  //customuserによるユーザー情報の取得
  types.TextMessage textMessage = types.TextMessage(
    author: user,
    createdAt: timestamp,
    id: randomString(),
    text: message,
  );
  Uniquemessage uniquemessage = Uniquemessage(
    textMessage,
    customuser.userId,
    to,
  );
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
