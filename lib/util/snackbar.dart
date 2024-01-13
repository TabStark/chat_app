import 'package:chat_app/theme/appcolors.dart';
import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';


class Dialogs {
  static void showSnackbar(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: AppColor().navyblue,
      behavior: SnackBarBehavior.floating,
    ));
  }

  static void showSnackbarforSaveImage(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        msg,
        style: TextStyle(color: AppColor().white),
      ),
      backgroundColor: AppColor().navyblue,
      behavior: SnackBarBehavior.floating,
    ));
  }

  static void showSnackbaraddUser(BuildContext context, String msg) {
    Flushbar(
      message: msg,
      duration: Duration(seconds: 3),
    )..show(context);
    
  }
}
