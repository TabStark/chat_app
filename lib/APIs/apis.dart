import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:chat_app/models/chat_user.dart';
import 'package:chat_app/models/messages.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart';

class apis {
  // For Firebase Auth
  static FirebaseAuth auth = FirebaseAuth.instance;

  // For StreamBuilder
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  // To fetch images from firebase storage
  static FirebaseStorage storage = FirebaseStorage.instance;

  // to return current user
  static User get user => auth.currentUser!;

  // to store current user data
  static ChatUser me = ChatUser(
      id: user.uid,
      name: user.displayName.toString(),
      email: user.email.toString(),
      about: "Hey, I'm using We Chat!",
      image: user.photoURL.toString(),
      createdAt: '',
      isOnline: false,
      lastActive: '',
      pushToken: '');

  // for Accessing firebase message (Push Notification)
  static FirebaseMessaging fMessaging = FirebaseMessaging.instance;

  // for Getting firebase message token
  static Future<void> getFirebaseMessageToken() async {
    await fMessaging.requestPermission();
    await fMessaging.getToken().then((t) {
      if (t != null) {
        me.pushToken = t;
        print("Push Token: ${t}");
      }
    });

    // Message handling
    // Foreground messages
    // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    //   print('Got a message whilst in the foreground!');
    //   print('Message data: ${message.data}');

    //   if (message.notification != null) {
    //     print('Message also contained a notification: ${message.notification}');
    //   }
    // });
  }

  // for send push notification
  static Future<void> sendPushNotification(
      ChatUser chatUser, String msg) async {
    try {
      final body = {
        "to": chatUser.pushToken,
        "notification": {
          "title": me.name,
          "body": msg,
          
          "android_channel_id": "chats",
        },
        "data": {
          "some_data": "User Id: ${me.id}",
        }
      };

      var response =
          await post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
              headers: {
                HttpHeaders.contentTypeHeader: 'application/json',
                HttpHeaders.authorizationHeader:
                    'key=AAAAWlI2aHg:APA91bH3kArzVcsi5yaNbevi-kwD0U0eGFUurLa6S5ty7G8lmFP1oCUGL-Fwy4_k4fLpPiZ2YWCVuEer26QyEkgY56i-m4wN3_cWJNxt49yu6mP6ifYZjgXB9iEhAa7vNgyxWCXQEuCT'
              },
              body: jsonEncode(body));
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
    } catch (e) {
      print('\nSendPushNotification: $e');
    }
  }

  // Checking is the user is Exist or not
  static Future<bool> userExists() async {
    return (await firestore.collection('users').doc(user.uid).get()).exists;
  }

  // Adding chat user for conversation
  static Future<bool> addChatUser(String email) async {
    final data = await firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    if (data.docs.isNotEmpty && data.docs.first.id != user.uid) {
      firestore
          .collection('users')
          .doc(user.uid)
          .collection('my_users')
          .doc(data.docs.first.id)
          .set({});
      return true;
    } else {
      return false;
    }
  }

  // To get current user data and disply in profile screen
  static Future getUserData() async {
    await firestore.collection('users').doc(user.uid).get().then((user) async {
      if (user.exists) {
        me = ChatUser.fromJson(user.data()!);
        await getFirebaseMessageToken();
        // To make initially the user is active
        apis.updateActiveStatus(true);
      } else {
        await createUser().then((value) => getUserData());
      }
    });
  }

  // to create new user
  static Future<void> createUser() async {
    // This things are getting from user email id. check in login page there is print the information there available this all things
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final chatUser = ChatUser(
        image: user.photoURL.toString(),
        about: "Hey, I am using Aspiran Chat ",
        name: user.displayName.toString(),
        createdAt: time,
        id: user.uid,
        lastActive: time,
        isOnline: false,
        pushToken: "",
        email: user.email.toString());

    return await firestore
        .collection("users")
        .doc(user.uid)
        .set(chatUser.toJson());
  }

  // To get my user id
  static Stream<QuerySnapshot<Map<String, dynamic>>> getMyUserId() {
    return firestore
        .collection('users')
        .doc(user.uid)
        .collection('my_users')
        .snapshots();
  }

  // To get all user
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUser(
      List<String> userIds) {
    return firestore
        .collection('users')
        .where('id', whereIn: userIds.isEmpty ? [''] : userIds)
        .snapshots();
  }

  // To disply who all are using this app
  // To Fetch API
  static Stream<QuerySnapshot<Map<String, dynamic>>> viewAllUsers() {
    return firestore
        .collection('users')
        .where('id', isNotEqualTo: user.uid)
        .snapshots();
  }

  // for adding user to my user when first message sent
  static Future<void> sendFirstMessage(
      ChatUser chatUser, String msg, Type type) async {
    await firestore
        .collection('users')
        .doc(chatUser.id)
        .collection('my_users')
        .doc(user.uid)
        .set({}).then((value) => sendMessage(chatUser, msg, type));
  }

  // To update user information
  static Future<void> updateUserInformation(value) async {
    if (value == 0) {
      await firestore
          .collection('users')
          .doc(user.uid)
          .update({'name': me.name.trim()});
    } else {
      await firestore
          .collection('users')
          .doc(user.uid)
          .update({'about': me.about.trim()});
    }
  }

  // Upload user profile image in storage and firebase

  // Storing image in firebase storage
  static Future<void> updateProfilePicture(File file) async {
    final ext = file.path.split('.').last;
    final ref = storage.ref().child('profile_pictures/${user.uid}.$ext');
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      print('Data transfered: ${p0.bytesTransferred / 1024} kb');
    });

    // From firebase storage to passing in firebase
    me.image = await ref.getDownloadURL();
    await firestore
        .collection('users')
        .doc(user.uid)
        .update({'image': me.image});
  }

  // get user specific info
  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(
      ChatUser chatUser) {
    return firestore
        .collection('users')
        .where('id', isEqualTo: chatUser.id)
        .snapshots();
  }

  // update online or last active status
  // get user specific info
  static Future<void> updateActiveStatus(bool isOnline) async {
    await firestore.collection('users').doc(user.uid).update({
      'is_online': isOnline,
      'last_active': DateTime.now().millisecondsSinceEpoch.toString(),
      'push_token': me.pushToken
    });
  }

  /*******************************Chat Screen API******************************/

  static String getConversationId(String id) => user.uid.hashCode <= id.hashCode
      ? '${user.uid}_$id'
      : '${id}_${user.uid}';

  // for getting all message
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
      ChatUser user) {
    return firestore
        .collection('chats/${getConversationId(user.id)}/messages/')
        .orderBy('sent', descending: true)
        .snapshots();
  }

  // for sending message
  static Future<void> sendMessage(
      ChatUser chatUser, String msg, Type type) async {
    // Message sending time and also used as id
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    final Message message = Message(
        msg: msg,
        toid: chatUser.id,
        read: '',
        type: type,
        sent: time,
        fromid: user.uid);
    final ref = firestore
        .collection('chats/${getConversationId(chatUser.id)}/messages/');
    await ref.doc(time).set(message.toJson()).then((value) =>
        sendPushNotification(chatUser, type == Type.text ? msg : "image"));
  }

  // Update Read Status of Message
  static Future<void> updateMessageReadStatus(Message message) async {
    firestore
        .collection('chats/${getConversationId(message.fromid)}/messages/')
        .doc(message.sent)
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }

  // Update Last Message and Last Seen
  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(
      ChatUser user) {
    return firestore
        .collection('chats/${getConversationId(user.id)}/messages/')
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }

  // Send image to opposite person
  static Future<void> sendChatImage(ChatUser chatUser, File file) async {
    final ext = file.path.split('.').last;
    final ref = storage.ref().child(
        'images/${getConversationId(chatUser.id)}/${DateTime.now().millisecondsSinceEpoch}.$ext');
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      print('Data transfered: ${p0.bytesTransferred / 1024} kb');
    });

    // From firebase storage to passing in firebase
    final imageUrl = await ref.getDownloadURL();
    await sendMessage(chatUser, imageUrl, Type.image);
  }

  // Delete Message
  static Future<void> deleteMessage(Message message) async {
    await firestore
        .collection('chats/${getConversationId(message.toid)}/messages/')
        .doc(message.sent)
        .delete();
    if (message.type == Type.image)
      await storage.refFromURL(message.msg).delete();
  }

  // update Message
  static Future<void> updateMessage(Message message, String updateMsg) async {
    await firestore
        .collection('chats/${getConversationId(message.toid)}/messages/')
        .doc(message.sent)
        .update({"msg": updateMsg});
  }
}
