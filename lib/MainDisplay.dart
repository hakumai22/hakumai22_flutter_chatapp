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
  int? _selectedIndex;
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
    );

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
      final docRef = db
          .collection("chats")
          .doc(getChatId("56023", "56024"))
          .collection("messages");
      docRef.snapshots().listen(
        (event) async => ListenMethod(event.docs, await findUserInfo("56023")),
        onError: (error) => debugPrint("Listen failed: $error"),
      );

      if (userlist.isNotEmpty && _selectedIndex == null) {
        _selectedIndex = 0;
      }

      if (mounted) {
        setState(() {});
      }

      if (!_hasInitialized) {
        _hasInitialized = true;
        FirebaseFirestore db = FirebaseFirestore.instance;
        db
            .collection('chats')
            .doc(getChatId(fromuser, karitouser))
            .collection('messages')
            .orderBy('timestamp', descending: false)
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
    });
  }

  @override
  void dispose() {
    addMessageCallback = null;
    cloudSendCallback = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> dynamicSidebarWidgets = [];
    int indexHome = 0;
    if (userlist.isNotEmpty) {
      for (var entry in userlist.asMap().entries) {
        int index = entry.key + 1;
        String userId = entry.value;

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
                padding: EdgeInsets.only(top: 20, left: 10, right: 10),
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
                  child: Chat(
                    user: _byuser,
                    messages: _messages,
                    onSendPressed: _handleSendPressed,
                    theme: DefaultChatTheme(
                      inputTextStyle: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
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
