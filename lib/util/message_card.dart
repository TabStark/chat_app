import 'package:gallery_saver/gallery_saver.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/APIs/apis.dart';
import 'package:chat_app/main.dart';
import 'package:chat_app/models/messages.dart';
import 'package:chat_app/theme/appcolors.dart';
import 'package:chat_app/util/date_time_format.dart';
import 'package:chat_app/util/snackbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MessageCard extends StatefulWidget {
  const MessageCard({super.key, required this.message});

  final Message message;

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    bool isMe = apis.user.uid == widget.message.fromid;
    return InkWell(
      onLongPress: () => _showModalBottomSheet(isMe),
      child: isMe ? _sender() : _receiver(),
    );
  }

  // receiver Message
  Widget _receiver() {
    if (widget.message.read.isEmpty) {
      apis.updateMessageReadStatus(widget.message);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // To show message
            Flexible(
              child: Container(
                padding: EdgeInsets.all(widget.message.type == Type.image
                    ? mq.width * .02
                    : mq.width * .02),
                margin: EdgeInsets.only(
                    top: mq.height * .01,
                    left: mq.width * .04,
                    right: mq.width * .04),
                decoration: BoxDecoration(
                    color: AppColor().lightnavyblue,
                    border: Border.all(color: AppColor().greyshade500),
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                        bottomRight: Radius.circular(10))),
                child: widget.message.type == Type.text
                    ? Text(
                        widget.message.msg + "",
                        style: TextStyle(fontSize: 16, color: AppColor().black),
                      )
                    : ClipRRect(
                        child: CachedNetworkImage(
                          imageUrl: widget.message.msg,
                          placeholder: (context, url) => Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: AppColor().greyshade800,
                            ),
                          ),
                          errorWidget: (context, url, error) => const Icon(
                            Icons.image,
                            size: 70,
                          ),
                        ),
                      ),
              ),
            ),
            SizedBox(
              width: mq.width * .15,
            )
          ],
        ),

        // To show date
        Container(
          margin: EdgeInsets.only(
            bottom: mq.height * .01,
            left: mq.width * .04,
          ),
          child: Text(
            DateTimeFormat.getFormattedTime(
                context: context, time: widget.message.sent),
            style: TextStyle(fontSize: 12),
          ),
        )
      ],
    );
  }

  // User Message
  Widget _sender() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // To give some space
            SizedBox(
              width: mq.width * .15,
            ),
            // Message
            Flexible(
              child: Container(
                padding: EdgeInsets.all(widget.message.type == Type.image
                    ? mq.width * .02
                    : mq.width * .02),
                margin: EdgeInsets.only(
                    top: mq.height * .01,
                    left: mq.width * .04,
                    right: mq.width * .04),
                decoration: BoxDecoration(
                    color: AppColor().navyblue,
                    border: Border.all(color: AppColor().greyshade500),
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                        bottomLeft: Radius.circular(10))),
                child: widget.message.type == Type.text
                    ? Text(
                        widget.message.msg,
                        style: TextStyle(fontSize: 16, color: AppColor().white),
                      )
                    : ClipRRect(
                        child: CachedNetworkImage(
                          imageUrl: widget.message.msg,
                          placeholder: (context, url) => Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: AppColor().greyshade800,
                            ),
                          ),
                          errorWidget: (context, url, error) => const Icon(
                            Icons.image,
                            size: 70,
                          ),
                        ),
                      ),
              ),
            ),
          ],
        ),

        //  Show Time and read status
        Container(
          margin: EdgeInsets.only(
            bottom: mq.height * .01,
            right: mq.width * .04,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              widget.message.read.isNotEmpty
                  ? Icon(
                      Icons.done_all_rounded,
                      size: 20,
                      color: AppColor().blue,
                    )
                  : const Icon(
                      Icons.done_all_rounded,
                      size: 20,
                    ),
              Text(
                DateTimeFormat.getFormattedTime(
                    context: context, time: widget.message.sent),
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        )
      ],
    );
  }

  void _showModalBottomSheet(bool isMe) {
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        builder: (_) {
          return ListView(shrinkWrap: true, children: [
            Container(
              height: 4,
              margin: EdgeInsets.symmetric(
                  vertical: mq.height * .015, horizontal: mq.width * .4),
              color: AppColor().greyshade500,
            ),
            // Copy or Download Image
            widget.message.type == Type.text
                ? _OptionItem(
                    icon: Icon(
                      Icons.copy_all_rounded,
                      color: AppColor().greyshade800,
                      size: 26,
                    ),
                    name: "Copy Text",
                    onTap: () async {
                      await Clipboard.setData(
                              ClipboardData(text: widget.message.msg))
                          .then((value) {
                        Navigator.pop(context);
                        Dialogs.showSnackbar(context, "Text Copied");
                      });
                    })
                : _OptionItem(
                    icon: Icon(
                      Icons.download_rounded,
                      color: AppColor().greyshade800,
                      size: 26,
                    ),
                    name: "Save Image",
                    onTap: () async {
                      try {
                        await GallerySaver.saveImage(widget.message.msg,
                                albumName: 'AspiranChat')
                            .then((success) {
                          Navigator.pop(context);
                          if (success != null && success) {
                            Dialogs.showSnackbarforSaveImage(
                                context, "Image Successfully Saved");
                          }
                        });
                      } catch (e) {
                        print('Error while saving image $e');
                      }
                    }),

            if (isMe) Divider(),

            // Edit
            if (widget.message.type == Type.text && isMe)
              _OptionItem(
                  icon: Icon(
                    Icons.edit_rounded,
                    color: AppColor().blue,
                    size: 26,
                  ),
                  name: "Edit Text",
                  onTap: () {
                    Navigator.pop(context);
                    _showUpdateMessageDialog();
                  }),

            // Delete
            if (isMe)
              _OptionItem(
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    color: AppColor().red,
                    size: 26,
                  ),
                  name: "Delete Text",
                  onTap: () async {
                    await apis
                        .deleteMessage(widget.message)
                        .then((value) => Navigator.pop(context));
                  }),

            Divider(),

            // Sent
            _OptionItem(
                icon: Icon(
                  Icons.done_all_rounded,
                  color: AppColor().greyshade800,
                  size: 26,
                ),
                name:
                    "Sent At: ${DateTimeFormat.getMessageTime(context: context, time: widget.message.sent)}",
                onTap: () {}),

            // Read
            _OptionItem(
                icon: Icon(
                  Icons.done_all_rounded,
                  color: AppColor().blue,
                  size: 26,
                ),
                name: widget.message.read.isEmpty
                    ? "Read at : Not seen yet"
                    : "Read At: ${DateTimeFormat.getMessageTime(context: context, time: widget.message.read)}",
                onTap: () {})
          ]);
        });
  }

  void _showUpdateMessageDialog() {
    String updateMessage = widget.message.msg;
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            contentPadding:
                EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 10),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [Icon(Icons.message), Text("Update Message")],
            ),
            content: TextFormField(
              maxLines: null,
              onChanged: (value) => updateMessage = value,
              initialValue: updateMessage,
              decoration: InputDecoration(
                  contentPadding:
                      EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15))),
            ),
            actions: [
              MaterialButton(
                onPressed: () => Navigator.pop(context),
                child: Text("cancel"),
              ),
              MaterialButton(
                onPressed: () {
                  Navigator.pop(context);
                  apis.updateMessage(widget.message, updateMessage);
                },
                child: Text("Update"),
              )
            ],
          );
        });
  }
}

class _OptionItem extends StatelessWidget {
  const _OptionItem(
      {required this.icon, required this.name, required this.onTap});
  final Icon icon;
  final String name;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(),
      child: Padding(
        padding: EdgeInsets.only(
          left: mq.width * 0.03,
          top: mq.height * .012,
          bottom: mq.height * .012,
        ),
        child: Row(children: [
          icon,
          Flexible(
              child: Text(
            '   ${name}',
            style: TextStyle(fontSize: 16),
          ))
        ]),
      ),
    );
  }
}
