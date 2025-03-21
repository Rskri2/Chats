import 'dart:convert';
import 'dart:io';
import 'dart:developer';

import 'package:chatapp/model/chat_user.dart';
import 'package:chatapp/model/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary/cloudinary.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart';
import '../cloudinary_config.dart';
import '../notification_acess_token.dart';

class UserService {
  final users = FirebaseFirestore.instance.collection("users");

  static final UserService _shared = UserService._sharedInstance();
  UserService._sharedInstance();

  static  User user = FirebaseAuth.instance.currentUser!;
   ChatUser me = ChatUser(
    about: "Hey, I'm using We Chat!",
    createdAt: '',
    email: user.email!,
    id: user.uid,
    image: user.photoURL.toString(),
    isOnline: false,
    lastOnline: '',
    name: user.displayName.toString(),
    pushToken: '',
  );

  factory UserService() => _shared;

  Future<void> updateUserProfile() async {
    await users.doc(me.id).update({
      'name': me.name,
      'about': me.about,
    }).then((value)=>getSelfInfo());
  }

  Future<void> updateLastSeen() async {
    await users.doc(me.id).update({
      "lastOnline": DateTime.now().millisecondsSinceEpoch.toString(),
    });
  }

  Future<bool> userExists() async {
    try {
      return (await users.doc(user.uid).get()).exists;
    } catch (e) {
      log(e.toString());
    }
    return false;
  }

  Future<void> updateProfilePhoto({required File file}) async {
    try{
      final time = DateTime.now().millisecondsSinceEpoch.toString();
      final fileName = "${user.uid}_$time";
      final response = await
      cloudinary.unsignedUpload
        (
        file: file.path,
        uploadPreset: "chat_app",
        fileBytes: file.readAsBytesSync(),
        resourceType: CloudinaryResourceType.image,
        fileName: fileName,
      );
      if(response.isSuccessful) {
        await users.doc(me.id).update({
          'image': response.secureUrl
        }).then((value)=>{
          getSelfInfo()
        });

      }
    } catch(e){
      log(e.toString());
    }
  }

  Future<void> createUser() async {
    try {
      final time = DateTime.now().millisecondsSinceEpoch.toString();

      user = FirebaseAuth.instance.currentUser!;
      final ChatUser chatUser = ChatUser(
        about: "Hey, I'm using We Chat!",
        createdAt: time,
        email: user.email!,
        id: user.uid,
        image: user.photoURL.toString(),
        isOnline: false,
        name: user.displayName.toString(),
        lastOnline: time,
        pushToken: '',
      );
      await users.doc(me.id).set(chatUser.toJson());
    } catch (e) {
      log(e.toString());
    }
  }
   Future<void> sendPushNotification(
      ChatUser chatUser, String msg) async {
    try {

      final body = {
        "message": {
          "token": chatUser.pushToken,
          "notification": {
            "title": me.name, //our name should be send
            "body": msg,
          },
        }
      };
      const projectID = 'my-chat-app-for-android';

      final bearerToken = await NotificationAccessToken.getToken();


      // handle null token
      if (bearerToken == null) return;
      log(bearerToken);
      var res = await post(
        Uri.parse(
            'https://fcm.googleapis.com/v1/projects/$projectID/messages:send'),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $bearerToken'
        },
        body: jsonEncode(body),
      );

      log('Response status: ${res.statusCode}');
      log('Response body: ${res.body}');
    } catch (e) {
      log('\nsendPushNotificationE: $e');
    }
  }

  Future<void> getMessagingToken() async {
    await FirebaseMessaging.instance.requestPermission(provisional: true);
    await FirebaseMessaging.instance.getToken().then((t) {
      if (t != null) {
        me.pushToken = t;
        log(t);
      }
    });

  }

   Future<void> sendFirstMessage(
      ChatUser chatUser, String msg, String type) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(chatUser.id)
        .collection('my_users')
        .doc(user.uid)
        .set({}).then((value) => sendMessage(chatUser, msg, type));
  }
  Future<void> sendFirstChatMessage(
      ChatUser chatUser, File file) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(chatUser.id)
        .collection('my_users')
        .doc(user.uid)
        .set({}).then((value) => sendChatImage(chatUser,file));
  }
   Stream<QuerySnapshot<Map<String, dynamic>>> getMyUsersId() {
    return FirebaseFirestore.instance.collection('users')
        .doc(user.uid)
        .collection('my_users')
        .snapshots();
  }


  Future<bool> addChatUser(String email) async {
    try {

      final data = await users.where('email', isEqualTo: email).get();

      if (data.docs.isNotEmpty && data.docs.first.id != user.uid) {

        users.doc(user.uid).collection('my_users').doc(data.docs.first.id).set({});
        return true;
      } else {
        return false;
      }
    } catch (e) {
      log(e.toString());
    }
    return false;
  }

  Future<void> updateOnlineStatus(bool status) async {
    try {
      await users.doc(user.uid).update({
        'isOnline': status,
        'lastOnline': DateTime.now().millisecondsSinceEpoch.toString(),
        'pushToken': me.pushToken,
      });
    } catch (e) {
      log(e.toString());
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>>? getUserInfo(ChatUser chatUser) {
    try {
      return users.where('id', isEqualTo: chatUser.id).snapshots();
    } catch (e) {
      log(e.toString());
    }
    return null;
  }

  Future<void> getSelfInfo() async {
    await users.doc(user.uid).get().then((user) async {
      if (user.exists) {
        me = ChatUser.fromJson(user.data()!);
        await getMessagingToken();
        updateOnlineStatus(true);
      } else {
        createUser().then((value) => getSelfInfo());
      }
    });
  }

  String getConversationId(String chatUserId) {

    return chatUserId.hashCode <= user.uid.hashCode
        ? "${chatUserId}_${user.uid}"
        : "${user.uid}_$chatUserId";
  }

  Stream<QuerySnapshot<Map<String, dynamic>>>? getAllUsers(
    List<String> userIds,
  ) {


    try {
      return users.where('id', whereIn: userIds)
          .snapshots();
    } catch (e) {
      log(e.toString());
    }
    return null;
  }

  Future<void> sendMessage(ChatUser chatUser, String msg, String type) async {
    try{
      Message message = Message(
        fromId: user.uid,
        msg: msg,
        read: '',
        sent: DateTime.now().millisecondsSinceEpoch.toString(),
        toId: chatUser.id,
        type: type,
      );
      final time = DateTime.now().millisecondsSinceEpoch.toString();

       await FirebaseFirestore.instance
          .collection('chats/${getConversationId(chatUser.id)}/messages/').doc(time).set(message.toJson()).then((value){
            sendPushNotification(chatUser, msg);
       });

    } catch(e){
      log(e.toString());
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(
    ChatUser chatUser,
  ) {
    return FirebaseFirestore.instance
        .collection('chats/${getConversationId(chatUser.id)}/messages/')
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
    ChatUser chatUser,
  ) {
    return FirebaseFirestore.instance
        .collection('chats/${getConversationId(chatUser.id)}/messages/')
        .orderBy('sent')
        .snapshots();
  }

  Future<void> sendChatImage(ChatUser chatUser, File file) async {
    try{
      final time = DateTime.now().millisecondsSinceEpoch.toString();
      final fileName = "${getConversationId(chatUser.id)}_$time";
      final response = await
      cloudinary.unsignedUpload
        (
          file: file.path,
          uploadPreset: "chat_app",
          fileBytes: file.readAsBytesSync(),
          resourceType: CloudinaryResourceType.image,
          fileName: fileName,
      );
      if(response.isSuccessful) {

        await sendMessage(chatUser, response.secureUrl!, "image");
      }
    } catch(e){
      log(e.toString());
    }

  }

  Future<void> updateMessageReadStatus(Message message) async {
    await FirebaseFirestore.instance
        .collection('chats/${getConversationId(message.toId)}/messages/')
        .doc(message.sent)
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }

  Future<void> deleteMessage(Message message) async {
    await FirebaseFirestore.instance
        .collection('chats/${getConversationId(message.toId)}/messages/')
        .doc(message.sent)
        .delete();
  }

  Future<void> updateMessage(Message message, String updatedMsg) async {
    await FirebaseFirestore.instance
        .collection('chats/${getConversationId(message.toId)}/messages/')
        .doc(message.sent)
        .update({'msg': updatedMsg});
  }
}
