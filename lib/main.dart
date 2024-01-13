import 'package:chat_app/firebase_options.dart';
import 'package:chat_app/theme/appcolors.dart';
import 'package:chat_app/view/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_notification_channel/flutter_notification_channel.dart';
import 'package:flutter_notification_channel/notification_importance.dart';


late Size mq;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // To Enter full Screen
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  // To Set Orientation
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((value) {
    _initializeFirebase();
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          iconTheme: IconThemeData(color: AppColor().white),
          titleTextStyle: TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 19,
              color: AppColor().white),
          backgroundColor: AppColor().greyshade200,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

_initializeFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  var result = await FlutterNotificationChannel.registerNotificationChannel(
    description: 'For Showing Message Notification',
    id: 'chats',
    importance: NotificationImportance.IMPORTANCE_HIGH,
    name: 'Chats',
  );
  print(result);
}
