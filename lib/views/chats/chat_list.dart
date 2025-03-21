import 'package:chatapp/services/user_service.dart';
import 'package:chatapp/utils/format_date.dart';
import 'package:flutter/material.dart';

import '../../model/chat_user.dart';
import '../../model/message.dart';

typedef ChatCallback = void Function(ChatUser);

class ChatList extends StatefulWidget {
  final List<ChatUser> users;

  final ChatCallback onTap;

  const ChatList({super.key,  required this.onTap, required this.users});

  @override
  State<ChatList> createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  final UserService userService = UserService();
    Message? lastMessage;
  @override
  Widget build(BuildContext context) {
    return  SingleChildScrollView(
      child: ListView.builder(
        itemCount: widget.users.length,
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        padding: EdgeInsets.all(16.0),
        itemBuilder: (context, index) {
          final currUser = widget.users.elementAt(index);
          return GestureDetector(
            onTap: () {

              widget.onTap(currUser);

            },
            child: Container(

              padding: EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                bottom: 10.0,
                top: 10.0,
              ),
              child: Row(
                children:[
                  Expanded(
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: currUser.image.isNotEmpty ? NetworkImage(currUser.image) : null,
                          maxRadius: 30,
                          child: currUser.image.isEmpty ? Icon(Icons.person, size:30) : null,
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Container(
                            color: Colors.transparent,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  currUser.name,
                                  style: TextStyle(fontSize: 16),
                                ),
                                SizedBox(height: 6),
                                StreamBuilder(
                                    stream: userService.getLastMessage(currUser),
                                    builder: (context, snapshot){
                                      switch(snapshot.connectionState){
                                        case ConnectionState.none:
                                        case ConnectionState.waiting:
                                        case ConnectionState.active:
                                        case ConnectionState.done:
                                          final messages = snapshot.data?.docs.map((msg){
                                            return Message.fromJson(msg.data());

                                          }).toList() ?? [];
                                          if(messages.isNotEmpty){
                                            lastMessage = messages.elementAt(0);
                                            if(lastMessage!.type == "text"){
                                              return Text(messages.elementAt(0).msg);
                                            }
                                            else{
                                              return Row(
                                                children: [
                                                  Icon(Icons.photo),
                                                  Text("  Photo"),
                                                ],
                                              );
                                            }
                                          }
                                          else{
                                            return Text('');
                                          }
                                      }
                                    })
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  lastMessage != null ? Text(
                    formatLastSeen(lastMessage!.sent), style:
                  TextStyle(fontWeight: lastMessage!.read.isNotEmpty ? FontWeight.bold : FontWeight.normal),
                  ) : Text(""),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

