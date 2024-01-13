import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/APIs/apis.dart';
import 'package:chat_app/main.dart';
import 'package:chat_app/models/chat_user.dart';
import 'package:chat_app/theme/appcolors.dart';
import 'package:chat_app/util/date_time_format.dart';
import 'package:chat_app/util/message_card.dart';
import 'package:chat_app/view/view_profile_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:chat_app/models/messages.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:image_picker/image_picker.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser user;
  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Message> _list = [];
  final _textController = TextEditingController();
  bool _showEmoji = false;
  //check if imsge is uploading or not
  bool _isUploading = false;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WillPopScope(
        onWillPop: () {
          if (_showEmoji) {
            setState(() {
              _showEmoji = !_showEmoji;
            });
            return Future.value(false);
          } else {
            return Future.value(true);
          }
        },
        child: GestureDetector(
          // To hide keyboard and emoji
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              flexibleSpace: _appBar(),
              backgroundColor: AppColor().navyblue,
            ),
            body: Column(
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    color: AppColor().chatscbgColor,
                    child: StreamBuilder(
                      stream: apis.getAllMessages(widget.user),
                      builder: (context, snapShot) {
                        switch (snapShot.connectionState) {
                          case ConnectionState.waiting:
                          case ConnectionState.none:
                            return const Center(
                              child: SizedBox(),
                            );

                          case ConnectionState.active:
                          case ConnectionState.done:
                            final data = snapShot.data!.docs;
                            // To take a json
                            // print("Data : ${jsonEncode(data[0].data())}");

                            _list = data
                                    .map((e) => Message.fromJson(e.data()))
                                    .toList() ??
                                [];

                            if (_list.isNotEmpty) {
                              return ListView.builder(
                                reverse: true,
                                physics: BouncingScrollPhysics(),
                                itemCount: _list.length,
                                itemBuilder: (context, index) {
                                  return MessageCard(
                                    message: _list[index],
                                  );
                                },
                              );
                            } else {
                              return const Center(
                                child: Text(
                                  "Say Hii... 👋",
                                  style: TextStyle(fontSize: 20),
                                ),
                              );
                            }
                        }
                      },
                    ),
                  ),
                ),

                //show is image is uploading
                if (_isUploading)
                  Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: AppColor().greyshade800,
                          ))),

                //Chat input field
                _ChatInput(),

                // Show emoji
                if (_showEmoji)
                  SizedBox(
                    height: mq.height * .32,
                    child: EmojiPicker(
                      textEditingController: _textController,
                      config: Config(
                        bgColor: AppColor().white,
                        indicatorColor: AppColor().black,
                        iconColorSelected: AppColor().black,
                        columns: 8,
                        emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _appBar() {
    return InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => ViewProfileScreen(user: widget.user)));
        },
        child: StreamBuilder(
            stream: apis.getUserInfo(widget.user),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                case ConnectionState.none:
                  return const Center(
                    child: SizedBox(),
                  );

                case ConnectionState.active:
                case ConnectionState.done:
                  final data = snapshot.data!.docs;
                  // list Getting real time data to check user online status
                  final list =
                      data.map((e) => ChatUser.fromJson(e.data())).toList() ??
                          [];

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(
                            Icons.arrow_back,
                            color: AppColor().white,
                          )),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(mq.height * .03),
                        child: CachedNetworkImage(
                          height: mq.height * .05,
                          width: mq.height * .05,
                          imageUrl: list.isNotEmpty
                              ? list[0].image
                              : widget.user.image,
                          errorWidget: (context, url, error) =>
                              const CircleAvatar(
                            child: Icon(CupertinoIcons.person),
                          ),
                        ),
                      ),
                      //
                      SizedBox(
                        width: 10,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            list.isNotEmpty ? list[0].name : widget.user.name,
                            style: TextStyle(
                                color: AppColor().white, fontSize: 17),
                          ),
                          Text(
                            list.isNotEmpty
                                ? list[0].isOnline
                                    ? 'online'
                                    : DateTimeFormat.getLastActiveTime(
                                        context: context,
                                        lastactive: list[0].lastActive)
                                : DateTimeFormat.getLastActiveTime(
                                    context: context,
                                    lastactive: widget.user.lastActive),
                            style: TextStyle(
                                color: AppColor().white, fontSize: 13),
                          )
                        ],
                      )
                    ],
                  );
              }
            }));
  }

  Widget _ChatInput() {
    return Row(
      children: [
        Expanded(
            child: Card(
          child: Row(children: [
            IconButton(
                onPressed: () {
                  setState(() {
                    // TO hide Keyboard
                    FocusScope.of(context).unfocus();
                    // To show emoji
                    _showEmoji = !_showEmoji;
                  });
                },
                icon: Icon(
                  Icons.emoji_emotions,
                  color: AppColor().navyblue,
                  size: 26,
                )),
            Expanded(
                child: TextField(
              onTap: () {
                if (_showEmoji) {
                  // TO hide emoj and show keyboard
                  setState(() {
                    _showEmoji = !_showEmoji;
                  });
                }
                ;
              },
              maxLines: 3,
              minLines: 1,
              controller: _textController,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "Message...",
                  hintStyle: TextStyle(color: AppColor().greyshade800)),
            )),
            IconButton(
                onPressed: () async {
                  final ImagePicker picker = ImagePicker();
                  // Picking an Multiple images.
                  final List<XFile> images =
                      await picker.pickMultiImage(imageQuality: 70);
                  // sending one by one in firestore
                  for (var i in images) {
                    setState(() {
                      _isUploading = true;
                    });
                    await apis.sendChatImage(widget.user, File(i.path));
                    setState(() {
                      _isUploading = false;
                    });
                  }
                },
                icon: Icon(
                  Icons.image,
                  color: AppColor().navyblue,
                  size: 26,
                )),
            IconButton(
                onPressed: () async {
                  final ImagePicker picker = ImagePicker();
                  // Pick an image.
                  final XFile? image = await picker.pickImage(
                      source: ImageSource.camera, imageQuality: 70);
                  if (image != null) {
                    setState(() {
                      _isUploading = true;
                    });
                    await apis.sendChatImage(widget.user, File(image.path));
                    setState(() {
                      _isUploading = false;
                    });
                  }
                },
                icon: Icon(
                  Icons.camera_alt_rounded,
                  color: AppColor().navyblue,
                  size: 27,
                ))
          ]),
        )),

        // Send Message Button
        MaterialButton(
          minWidth: 0,
          color: AppColor().navyblue,
          padding: EdgeInsets.only(top: 10, bottom: 10, right: 5, left: 10),
          shape: CircleBorder(),
          onPressed: () {
            if (_textController.text.isNotEmpty) {
              // Sending message for first time
              if (_list.isEmpty) {
                apis.sendFirstMessage(
                    widget.user, _textController.text.trim(), Type.text);
              } else {
                //simply sending message
                apis.sendMessage(
                    widget.user, _textController.text.trim(), Type.text);
              }

              _textController.text = '';
            }
          },
          child: Icon(Icons.send, color: AppColor().white, size: 26),
        )
      ],
    );
  }
}
