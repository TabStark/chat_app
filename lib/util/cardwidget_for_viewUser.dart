import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/APIs/apis.dart';
import 'package:chat_app/main.dart';
import 'package:chat_app/models/chat_user.dart';
import 'package:chat_app/models/messages.dart';
import 'package:chat_app/theme/appcolors.dart';
import 'package:chat_app/util/profile_dialog.dart';
import 'package:chat_app/view/chat_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/util/date_time_format.dart';

class cardWidgetforVIewUsers extends StatefulWidget {
  final ChatUser user;
  const cardWidgetforVIewUsers({super.key, required this.user});

  @override
  State<cardWidgetforVIewUsers> createState() => _cardWidgetforVIewUsersState();
}

class _cardWidgetforVIewUsersState extends State<cardWidgetforVIewUsers> {
  Message? _message;

  @override
  Widget build(BuildContext context) {
    final ChatUser userInfo = widget.user;

    return Card(
      elevation: 0.5,
      color: AppColor().white,
      child: InkWell(
        onTap: () {
          apis.addChatUser(userInfo.email);
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ChatScreen(
                      user: userInfo,
                    )),
          );
        },
        child: StreamBuilder(
          stream: apis.getLastMessage(userInfo),
          builder: (context, snapShot) {
            if (snapShot.hasData && snapShot.data != null) {
              final data = snapShot.data!.docs;
              final list =
                  data.map((e) => Message.fromJson(e.data())).toList() ?? [];
              if (list.isNotEmpty) _message = list[0];
            }

            return ListTile(
              leading: InkWell(
                onTap: () => showDialog(
                    context: context,
                    builder: (_) => ProfileDialog(user: widget.user)),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(mq.height * .03),
                  child: CachedNetworkImage(
                    height: mq.height * .055,
                    width: mq.height * .055,
                    imageUrl: userInfo.image,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => const CircleAvatar(
                      child: Icon(CupertinoIcons.person),
                    ),
                  ),
                ),
              ),
              title: Text(userInfo.name),
              subtitle: Text(
                _message != null
                    ? _message!.type == Type.image
                        ? 'image'
                        : _message!.msg
                    : userInfo.about,
                maxLines: 1,
              ),
              trailing: _message != null
                  ? _message!.read.isEmpty && _message!.fromid != apis.user.uid
                      // Show for unread messages
                      ? Container(
                          height: 15,
                          width: 15,
                          decoration: BoxDecoration(
                              color: AppColor().green,
                              borderRadius: BorderRadius.circular(10)),
                        )
                      // show sent message time
                      : Text(DateTimeFormat.getLastMessageTime(
                          context: context, time: _message!.sent))
                  // Showing nothing when no messages sent
                  : null,
            );
          },
        ),
      ),
    );
  }
}
