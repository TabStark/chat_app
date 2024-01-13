import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateTimeFormat {
  // for getting formatted time from millisecondepoch
  static String getFormattedTime(
      {required BuildContext context, required String time}) {
    final date = DateTime.fromMillisecondsSinceEpoch(int.parse(time));
    return TimeOfDay.fromDateTime(date).format(context);
  }

  // Get time for sent and Read
  static String getMessageTime({
    required BuildContext context,
    required String time,
  }) {
    final DateTime sent = DateTime.fromMillisecondsSinceEpoch(int.parse(time));
    final DateTime now = DateTime.now();

    final formattedTime = TimeOfDay.fromDateTime(sent).format(context);

    if (now.day == sent.day &&
        now.month == sent.month &&
        now.year == sent.year) {
      return formattedTime;
    }
    return now.year == sent.year
        ? '$formattedTime - ${sent.day} ${returnMonth(sent)} ${sent.year}'
        : '$formattedTime -  ${sent.day} ${returnMonth(sent)}';
  }

  // get last message time and when user created account
  static String getLastMessageTime(
      {required BuildContext context,
      required String time,
      bool showYear = false}) {
    final DateTime sentTime =
        DateTime.fromMillisecondsSinceEpoch(int.parse(time));
    final DateTime now = DateTime.now();
    if (showYear) {
      return '${sentTime.day} ${returnMonth(sentTime)} ${sentTime.year}';
    } else {
      if (now.day == sentTime.day &&
          now.month == sentTime.month &&
          now.year == sentTime.year) {
        return TimeOfDay.fromDateTime(sentTime).format(context);
      }
    }
    return showYear
        ? '${sentTime.day} ${returnMonth(sentTime)} ${sentTime.year}'
        : '${sentTime.day} ${returnMonth(sentTime)}';
  }

  // Last seen Date time format
  static String getLastActiveTime(
      {required BuildContext context, required String lastactive}) {
    final int i = int.tryParse(lastactive) ?? -1;

    // if time is not available then return below statement
    if (i == -1) return 'Last seen not available';

    // If last is today
    DateTime time = DateTime.fromMillisecondsSinceEpoch(i);
    DateTime now = DateTime.now();

    String formattedTime = TimeOfDay.fromDateTime(time).format(context);
    if (time.day == now.day &&
        time.month == now.month &&
        time.year == now.year) {
      return 'Last seen today at ${formattedTime}';
    }

    // If last is yesterday
    if ((now.difference(time).inHours / 24).round() == 1) {
      return 'Last seen yesterday at ${formattedTime}';
    }

    String month = returnMonth(time);
    return 'Last seen on ${time.day} $month at ${formattedTime}';
  }

  // Return Month from date
  static String returnMonth(DateTime sent) {
    return new DateFormat.MMM().format(sent);
  }
}
