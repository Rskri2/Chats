import 'package:chatapp/model/message.dart';
import 'package:chatapp/views/chats/message_card.dart';
import 'package:flutter/material.dart';

class ChatMessages extends StatefulWidget {
  final List<Message> messages;
  const ChatMessages({super.key, required this.messages});
  @override
  State<ChatMessages> createState() => _ChatMessagesState();
}

class _ChatMessagesState extends State<ChatMessages> {

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 60,
      ),
      child: ListView.builder(
        itemCount: widget.messages.length,
        padding: EdgeInsets.only(top: 10, bottom: 10),
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          Message message = widget.messages.elementAt(index);
          return MessageCard(message: message);
        },
      ),
    );
  }
}
