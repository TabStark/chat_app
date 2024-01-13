import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/main.dart';
import 'package:chat_app/models/chat_user.dart';
import 'package:chat_app/theme/appcolors.dart';
import 'package:chat_app/view/view_profile_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProfileDialog extends StatelessWidget {
  const ProfileDialog({super.key, required this.user});
  final ChatUser user;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColor().white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: SizedBox(
        width: mq.width * .6,
        height: mq.height * .3,
        child: Stack(
          children: [
            //User Name
            Positioned(
              width: mq.width * .55,
              child: Text(
                user.name,
                style: TextStyle(fontSize: 19),
              ),
            ),

            // User Image
            Positioned(
              top: mq.height * .06,
              left: mq.width * .06,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(mq.height * .11),
                child: CachedNetworkImage(
                  width: mq.height * .22,
                  fit: BoxFit.cover,
                  imageUrl: user.image,
                  errorWidget: (context, url, error) => const CircleAvatar(
                    child: Icon(CupertinoIcons.person),
                  ),
                ),
              ),
            ),

            // More Icon
            Align(
              alignment: Alignment.topRight,
              child: InkWell(
                onTap: () => {
                  Navigator.pop(context),
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => ViewProfileScreen(user: user))),
                },
                child: Icon(
                  Icons.info_outline,
                  size: 26,
                  color: AppColor().greyshade800,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
