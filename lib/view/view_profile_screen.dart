
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/main.dart';
import 'package:chat_app/models/chat_user.dart';
import 'package:chat_app/theme/appcolors.dart';
import 'package:chat_app/util/date_time_format.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class ViewProfileScreen extends StatefulWidget {
  final ChatUser user;
  const ViewProfileScreen({super.key, required this.user});

  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar
      appBar: AppBar(
        title: Text(
          widget.user.name,
          style: TextStyle(color: AppColor().white),
        ),
        backgroundColor: AppColor().navyblue,
      ),

      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Joined on ",
              style:
                  const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          Text(
              DateTimeFormat.getLastMessageTime(
                  context: context,
                  time: widget.user.createdAt,
                  showYear: true),
              style: const TextStyle(
                fontSize: 17,
              ))
        ],
      ),
      // Body
      body: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.height * .05),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * .03,
              ),
              // User Image
              ClipRRect(
                borderRadius: BorderRadius.circular(
                    MediaQuery.of(context).size.height * .09),
                child: CachedNetworkImage(
                  height: MediaQuery.of(context).size.height * .18,
                  width: MediaQuery.of(context).size.height * .18,
                  fit: BoxFit.cover,
                  imageUrl: widget.user.image,
                  errorWidget: (context, url, error) => const CircleAvatar(
                    child: Icon(CupertinoIcons.person),
                  ),
                ),
              ),

              SizedBox(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * .03,
              ),

              // User Email
              Text(
                widget.user.email,
                style: TextStyle(fontSize: 17, color: AppColor().greyshade800),
              ),
              SizedBox(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * .02,
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info_outline),
                  SizedBox(
                    width: mq.width * .02,
                  ),
                  Text(widget.user.about,
                      style: const TextStyle(
                        fontSize: 17,
                      ))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
