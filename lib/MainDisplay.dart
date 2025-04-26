import 'dart:convert';
import 'package:flutter/material.dart';
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
  String karifromuser = "56023";
  String karitouser = "56024";
  List<String> userlist = [];
  bool _hasInitialized = false;
  List<bool> isSelected = [];
  List<Widget> sidebarWidgets = [];
  types.User _byuser = types.User(
    id: "56023",
    firstName: "hakumai22",
    imageUrl: "images/genseki.png",
  );
  @override
  void initState() {
    super.initState();
    addMessageCallback = _addMessage;
    cloudSendCallback = CloudMessagesendonly;
    String fromuser = widget.userId;
    if (fromuser == null) {
      debugPrint("userIdがnull");
      fromuser = karifromuser;
    }
    _byuser = types.User(
      id: fromuser,
      firstName: "hakumai22",
      imageUrl: "images/genseki.png",
    ); //後でcustomuser.userにする
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
      FirebaseFirestore db = FirebaseFirestore.instance;
      //docrefの56024の部分を複数の人のために相手リストをforeachで回す。
      final docRef = db
          .collection("chats")
          .doc(getChatId("56023", "56024"))
          .collection("messages");
      docRef.snapshots().listen(
        (event) async => ListenMethod(event.docs, await findUserInfo("56023")),
        onError: (error) => debugPrint("Listen failed: $error"),
      );
      //--------------------------------------ユーザー一覧をサイドバーに表示する作業----------------------------------------------------
      isSelected = List.generate(userlist.length, (index) => false);
      for (var i in userlist.asMap().entries) {
        int index = i.key;
        String userId = i.value;
        sidebarWidgets.add(
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
                  borderRadius: BorderRadius.circular(50.0), // 非常に大きな値で楕円形に
                ),
                selectedTileColor:
                    Theme.of(context).colorScheme.primaryContainer,
                selectedColor: Color(0xFF000000),
                selected: isSelected[index],
                onTap: () {
                  debugPrint("tapped");
                  isSelected.fillRange(0, userlist.length, false);
                  isSelected[index] = true;
                  setState(() {});
                  debugPrint(isSelected.toString());
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
      //--------------------------------------------終----------------------------------------
      if (!_hasInitialized) {
        _hasInitialized = true;
        FirebaseFirestore db = FirebaseFirestore.instance;
        db
            .collection('chats')
            .doc(getChatId(fromuser, karitouser))
            .collection('messages')
            .orderBy('timestamp', descending: false) // 昇順（古い順）
            .get()
            .then((snapshot) {
              snapshot.docs.forEach((doc) {
                addmessageafterlisten(
                  doc.data()["message"],
                  karitouser,
                  doc.data()["timestamp"],
                  customuser,
                );
              });
            });
      }
    }); //サイドバーのユーザーIDから伝えられた情報を代入するようにする
    // コールバックの登録
  }

  @override
  void dispose() {
    // コールバックの解除
    addMessageCallback = null;
    cloudSendCallback = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  child: Align(
                    child: Text(
                      "Chats",
                      style: TextStyle(
                        fontSize: 25,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    alignment: Alignment.centerLeft,
                  ),
                  padding: EdgeInsets.only(left: 20),
                ),
              ),
              Divider(
                color: Theme.of(context).colorScheme.secondaryFixedDim,
                height: 1,
                thickness: 1,
                indent: 16,
                endIndent: 16,
              ),
              ...sidebarWidgets,
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
  void _addMessage(
    Uniquemessage message, {
    int timestamp = 0,
    bool addcloud = true,
  }) {
    // String chatId = getChatId(karifromuser, karitouser);
    setState(() {
      _messages.insert(0, message.message);
    });
    if (addcloud) {
      CloudMessagesendonly(message);
    }
  }

  void CloudMessagesendonly(Uniquemessage message) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    String chatId = getChatId(karifromuser, karitouser);
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
    CloudMessagesendonly(Uniquemessage(textMessage, karifromuser, karitouser));
  }
}
