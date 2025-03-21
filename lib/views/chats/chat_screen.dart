import 'dart:developer';
import 'dart:io';
import 'package:chatapp/model/chat_user.dart';
import 'package:chatapp/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import '../../model/message.dart';
import '../../utils/format_date.dart';
import 'chat_messages.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser user;
  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final TextEditingController controller;
  late final UserService userService;
  bool _isUploading = false;
  bool _showEmoji = false;

  List<Message> messages = [];
  @override
  void initState() {
    controller = TextEditingController();
    userService = UserService();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: FocusScope.of(context).unfocus,
      child: PopScope(
        canPop: false,

        onPopInvokedWithResult: (_, __) {
          if (_showEmoji) {
            setState(() => _showEmoji = !_showEmoji);
            return;
          }

          // some delay before pop
          Future.delayed(const Duration(milliseconds: 300), () {
            try {
              if (Navigator.canPop(context)) Navigator.pop(context);
            } catch (e) {
              log(e.toString());
            }
          });
        },
        child: Scaffold(
          appBar: AppBar(
            elevation: 0,
            automaticallyImplyLeading: false,
            backgroundColor: Colors.white,
            flexibleSpace: SafeArea(
              child: Container(
                padding: EdgeInsets.only(right: 2),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: Icon(Icons.arrow_back, color: Colors.black),
                    ),
                    SizedBox(width: 2),
                    CircleAvatar(
                      backgroundImage:
                          widget.user.image.isNotEmpty
                              ? NetworkImage(widget.user.image)
                              : null,
                      maxRadius: 30,
                      child:
                          widget.user.image.isEmpty
                              ? Icon(Icons.person, size: 30)
                              : null,
                    ),
                    SizedBox(width: 2),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(widget.user.name),
                          SizedBox(height: 6),
                          Text(
                            widget.user.isOnline
                                ? "Online"
                                : "Last seen: ${formatLastSeen(widget.user.lastOnline)}",
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          body: Stack(
            children: [
              StreamBuilder(
                stream: userService.getAllMessages(widget.user),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                    case ConnectionState.waiting:
                    case ConnectionState.active:
                    case ConnectionState.done:
                      messages =
                          snapshot.data?.docs.map((msg) {
                            return Message.fromJson(msg.data());
                          }).toList() ??
                          [];
                      if (messages.isNotEmpty) {
                        return ChatMessages(messages: messages);
                      } else {
                        return const Center(
                          child: Text(
                            'Say Hii! 👋',
                            style: TextStyle(fontSize: 20),
                          ),
                        );
                      }
                  }
                },
              ),
              if (_isUploading)
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),

              Align(
                alignment: Alignment.bottomLeft,
                child: Container(
                  padding: EdgeInsets.only(left: 10, bottom: 10, top: 10),
                  height: 60,
                  width: double.infinity,
                  color: Colors.white,
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          setState(() => _showEmoji = !_showEmoji);

                        },
                        icon: Icon(Icons.emoji_emotions),
                      ),
                      SizedBox(width: 15),
                      Expanded(
                        child: TextField(
                          autofocus: false,
                          autocorrect: false,
                          controller: controller,
                          decoration: InputDecoration(
                            hintText: "Write message here..",
                            border: InputBorder.none,
                            hintStyle: TextStyle(color: Colors.black54),
                          ),
                        ),
                      ),
                      SizedBox(width: 15),
                      IconButton(
                        onPressed: () async {
                          final ImagePicker picker = ImagePicker();
                          final List<XFile> multiFiles = await picker
                              .pickMultiImage(imageQuality: 70);
                          for (var image in multiFiles) {
                            setState(() {
                              _isUploading = true;
                            });
                            if(messages.isEmpty){
                              await userService.sendFirstChatMessage(
                                widget.user,
                                File(image.path),
                              );
                            }
                            else{
                              await userService.sendChatImage(
                                widget.user,
                                File(image.path),
                              );
                            }
                            setState(() {
                              _isUploading = false;
                            });
                          }
                        },
                        icon: Icon(Icons.image),
                      ),
                      IconButton(
                        onPressed: () async {
                          final ImagePicker picker = ImagePicker();
                          final XFile? image = await picker.pickImage(
                            source: ImageSource.camera,
                            imageQuality: 70,
                          );

                          if (image != null) {
                            setState(() => _isUploading = true);
                            if(messages.isEmpty){
                              await userService.sendFirstChatMessage(
                                widget.user,
                                File(image.path),
                              );
                            }
                            else{
                              await userService.sendChatImage(
                                widget.user,
                                File(image.path),
                              );
                            }

                            setState(() => _isUploading = false);
                          }
                        },
                        icon: Icon(Icons.camera_alt_outlined),
                      ),

                      FloatingActionButton(
                        mini: true,
                        onPressed: () async {
                          final message = controller.text;
                          if(messages.isEmpty){
                            await userService.sendFirstMessage(widget.user, message, "text");
                          }
                          else{
                            await userService.sendMessage(
                              widget.user,
                              message,
                              "text",
                            );
                          }
                          controller.clear();
                        },
                        backgroundColor: Colors.blue,
                        elevation: 0,
                        child: Icon(Icons.send, color: Colors.white, size: 18),
                      ),
                    ],
                  ),
                ),
              ),
              if (_showEmoji)
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Container(
                    padding: EdgeInsets.only(bottom: 60),
                    child: EmojiPicker(
                      textEditingController: controller,
                      config: const Config(),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
