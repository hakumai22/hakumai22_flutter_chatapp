import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:ui';
import 'barrel.dart';

class MainDisplay extends StatefulWidget {
  final String userId;
  MainDisplay({required this.userId});
  @override
  _MainDisplayState createState() => _MainDisplayState();
}

class _MainDisplayState extends State<MainDisplay> {
  static List<types.Message> _messages = [];
  List<String> userlist = [];
  bool _hasInitialized = false;
  int? _selectedIndex;
  types.User _byuser = types.User(
    id: "56023",
    firstName: "hakumai22",
    imageUrl: "images/genseki.png",
  );
  //ここはまだ仮のデータ
  String fromuser = "56023";
  String touser = "Home";
  StreamSubscription? subscription;
  StreamSubscription? startsubscription(String user, String tuser) {
    FirebaseFirestore db = FirebaseFirestore.instance;
    var docRef = db
        .collection("chats")
        .doc(getChatId(user, tuser))
        .collection("messages");

    bool isFirstSnapshot = true; // 初回のスナップショットかどうかを追跡

    return docRef.snapshots().listen((event) async {
      if (isFirstSnapshot) {
        isFirstSnapshot = false; // 初回のスナップショットをスキップ
        return;
      }

      // 変更があった場合のみListenMethodを呼び出す
      if (event.docChanges.isNotEmpty) {
        ListenMethod(event.docs, await findUserInfo(fromuser));
      }
    }, onError: (error) => debugPrint("Listen failed: $error"));
  }

  void cancelsubscription(StreamSubscription? subscription) {
    if (subscription != null) {
      subscription.cancel();
    } else {
      return;
    }
  }

  @override
  void initState() {
    super.initState();
    addMessageCallback = _addMessage;
    cloudSendCallback = CloudMessagesendonly;
    fromuser = widget.userId;
    if (fromuser == null) {
      debugPrint("userIdがnull");
      fromuser = "56023"; //仮のデータ
      //後でここでエラーを吐くようにする
    }

    CustomUser? customuser;
    Future(() async {
      userlist = await SearchbyuserId(fromuser);
      customuser = await findUserInfo(fromuser);
      if (customuser != null) {
        _byuser = customuser!.user;
      }
      if (customuser == null) {
        debugPrint("finduserInfoがnull");
        customuser = CustomUser(
          fromuser,
          "hakumai22",
          "password",
          "email",
          "images/genseki.png",
          _byuser,
        );
      }
      _byuser = types.User(
        id: fromuser,
        firstName: customuser!.userName,
        imageUrl: "images/genseki.png",
      );

      if (userlist.isNotEmpty && _selectedIndex == null) {
        _selectedIndex = 0;
      }

      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    addMessageCallback = null;
    cloudSendCallback = null;
    super.dispose();
  }

  Widget _buildChatWidget(String chattouser) {
    if (chattouser != "Home") {
      return Chat(
        user: _byuser,
        messages: _messages,
        onSendPressed: _handleSendPressed,
        theme: DefaultChatTheme(
          inputTextStyle: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      );
    } else {
      return Center(child: Text("Get Started"));
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> dynamicSidebarWidgets = [];
    List<String> userIdList = [];
    int indexHome = 0;

    if (userlist.isNotEmpty) {
      for (var entry in userlist.asMap().entries) {
        int index = entry.key + 1;
        String userId = entry.value;
        userIdList.add(userId);
        debugPrint("userId: $userId");
        dynamicSidebarWidgets.add(
          Padding(
            padding: EdgeInsets.only(top: 20, left: 10, right: 10),
            child: Material(
              color: Colors.transparent,
              child: ListTile(
                title: Text(userId),
                leading: CircleAvatar(
                  backgroundImage: AssetImage("images/genseki.png"),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50.0),
                ),
                selectedTileColor:
                    Theme.of(context).colorScheme.primaryContainer,
                selectedColor: Color(0xFF000000),
                selected: _selectedIndex == index,
                onTap: () {
                  setState(() {
                    touser =
                        index == 0 || index == null
                            ? "Home"
                            : userlist[index! - 1]; //最初のタイルはHomeなので-1している
                    if (_selectedIndex != index) {
                      _messages.clear();
                      cancelsubscription(subscription);
                      subscription = startsubscription(fromuser, touser);
                      FirebaseFirestore db = FirebaseFirestore.instance;
                      db
                          .collection('chats')
                          .doc(getChatId(fromuser, touser))
                          .collection('messages')
                          .orderBy('timestamp', descending: false)
                          .get()
                          .then((snapshot) async {
                            for (var doc in snapshot.docs) {
                              // forEachの代わりにfor-inを使用
                              // 非同期で取得したユーザー情報を待機
                              final userInfo = await findUserInfo(fromuser);
                              // userInfoを使用してメッセージを追加
                              addmessageafterlisten(
                                doc.data()["message"],
                                touser,
                                doc.data()["timestamp"],
                                userInfo, // 解決済みの値を渡す
                              );
                            }
                          });
                    }
                    _selectedIndex = index;
                  });

                  debugPrint("tapped index: $index, user: $userId");
                },
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 4.0,
                ),
              ),
            ),
          ),
        );
      }
    }

    Widget chatContent = _buildChatWidget(touser);

    return Scaffold(
      drawer: Drawer(
        child: Container(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          child: ListView(
            children: [
              Container(
                height: 80,
                color: Theme.of(context).colorScheme.surfaceContainerLow,
                child: Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Chats",
                      style: TextStyle(
                        fontSize: 25,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              ),
              Divider(
                color: Theme.of(context).colorScheme.secondaryFixedDim,
                height: 1,
                thickness: 1,
                indent: 16,
                endIndent: 16,
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: 20,
                  left: 10,
                  right: 10,
                  bottom: 20,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: ListTile(
                    title: Text("Home"),
                    leading: Icon(Icons.home),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50.0),
                    ),
                    selectedTileColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    selectedColor: Color(0xFF000000),
                    selected: _selectedIndex == indexHome,
                    onTap: () {
                      setState(() {
                        touser =
                            indexHome == 0 || indexHome == null
                                ? "Home"
                                : userlist[_selectedIndex!]; //最初のタイルはHomeなので-1している
                        if (_selectedIndex != indexHome) {
                          _messages.clear();
                          cancelsubscription(subscription);
                        }
                        _selectedIndex = indexHome;
                      });
                    },
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 4.0,
                    ),
                  ),
                ),
              ),
              Divider(
                color: Theme.of(context).colorScheme.secondaryFixedDim,
                height: 1,
                thickness: 1,
                indent: 16,
                endIndent: 16,
              ),
              ...dynamicSidebarWidgets,
            ],
          ),
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
      appBar: AppBar(
        title: Text("テスト用のルーム"),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
        actions: [
          Material(
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
                width: kToolbarHeight,
                height: kToolbarHeight,
                margin: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    fit: BoxFit.scaleDown,
                    image: AssetImage("images/genseki.png"),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Row(
        children: [
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
                  child: chatContent,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _addMessage(
    Uniquemessage message, {
    int timestamp = 0,
    bool addcloud = true,
  }) {
    setState(() {
      _messages.insert(0, message.message);
    });
    if (addcloud) {
      CloudMessagesendonly(message);
    }
  }

  void CloudMessagesendonly(Uniquemessage message) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    String chatId = getChatId(fromuser, touser);
    await firestore.collection('chats').doc(chatId).collection('messages').add({
      'from': fromuser,
      'to': touser,
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
    if (touser == "Home") {
      return;
    }
    CloudMessagesendonly(Uniquemessage(textMessage, fromuser, touser));
  }
}
//実装目標
//4.Passwordの確認 
//5.メッセージの中のto,fromからの依存をなくす（getchatidの第一引数、第２引数を参照する）