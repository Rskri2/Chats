import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapp/services/user_service.dart';
import 'package:chatapp/utils/format_date.dart';
import 'package:chatapp/views/dialog/show_message_update_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import '../../model/message.dart';

class MessageCard extends StatefulWidget {
  final Message message;
  const MessageCard({super.key, required this.message});

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  final UserService userService = UserService();
  Future<void> updateMessageStatus(Message message) async {
    if (message.fromId != userService.me.id && message.sent.isEmpty) {
      await userService.updateMessageReadStatus(message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: updateMessageStatus(widget.message),
      builder: (context, snapshot) {
        return GestureDetector(
          onLongPress: () {
            showBottomDialog();
          },
          child: Container(
            padding: EdgeInsets.only(left: 14, right: 14),
            child: Align(
              alignment:
                  widget.message.fromId == userService.me.id
                      ? Alignment.topRight
                      : Alignment.topLeft,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color:
                      widget.message.fromId == userService.me.id
                          ? Colors.blue[200]
                          : Colors.grey.shade200,
                ),
                padding: EdgeInsets.all(16),
                child:
                    widget.message.type == "text"
                        ? Text(
                          widget.message.msg,
                          style: TextStyle(fontSize: 15),
                        )
                        : ClipRRect(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(15),
                          ),
                          child: CachedNetworkImage(
                            imageUrl: widget.message.msg,
                            fit: BoxFit.cover,
                            placeholder:
                                (context, url) => const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                            errorWidget:
                                (context, url, error) =>
                                    const Icon(Icons.image, size: 70),
                          ),
                        ),
              ),
            ),
          ),
        );
      },
    );
  }

  void showBottomDialog() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) {
        final size = MediaQuery.of(context).size;
        return SizedBox(
          height: size.height * 0.4,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              if (widget.message.fromId == userService.me.id &&
                  widget.message.type == "text")
                GestureDetector(
                  onTap: () {
                    showMessageUpdateDialog(
                      context: context,
                      message: widget.message,
                    );
                  },
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: size.width * .05,
                      top: size.height * .015,
                      bottom: size.height * .015,
                    ),
                    child: Row(
                      children: [Icon(Icons.message), Text("Update message")],
                    ),
                  ),
                ),

              widget.message.type == "text"
                  ? GestureDetector(
                    onTap: () async {
                      await Clipboard.setData(
                        ClipboardData(text: widget.message.msg),
                      ).then((value) {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Text copied to clipboard!')),
                        );
                      });
                    },
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: size.width * .05,
                        top: size.height * .015,
                        bottom: size.height * .015,
                      ),
                      child: Row(
                        children: [Icon(Icons.copy_all), Text("Copy text")],
                      ),
                    ),
                  )
                  : GestureDetector(
                    onTap: () async {
                      await GallerySaver.saveImage(
                        widget.message.msg,
                        albumName: 'We chat',
                      ).then((value) {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Image successfully saved!'),
                          ),
                        );
                      });
                    },
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: size.width * .05,
                        top: size.height * .015,
                        bottom: size.height * .015,
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.delete),
                          Text("Save image to gallery"),
                        ],
                      ),
                    ),
                  ),
              if (widget.message.fromId == userService.me.id)
                Divider(
                  color: Colors.black54,
                  endIndent: size.width * .04,
                  indent: size.width * .04,
                ),

              if (widget.message.fromId == userService.me.id &&
                  widget.message.type == "text")
                GestureDetector(
                  onTap: () async {
                    await userService.deleteMessage(widget.message);
                  },
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: size.width * .05,
                      top: size.height * .015,
                      bottom: size.height * .015,
                    ),
                    child: Row(
                      children: [Icon(Icons.delete), Text("Delete message")],
                    ),
                  ),
                ),
              if (widget.message.fromId == userService.me.id &&
                  widget.message.type == "text")
                Divider(
                  color: Colors.black54,
                  endIndent: size.width * .04,
                  indent: size.width * .04,
                ),
              Padding(
                padding: EdgeInsets.only(
                  left: size.width * .05,
                  top: size.height * .015,
                  bottom: size.height * .015,
                ),
                child: Row(
                  children: [
                    Icon(Icons.remove_red_eye, color: Colors.blue),
                    Text('Sent At: ${formatLastSeen(widget.message.sent)}'),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  left: size.width * .05,
                  top: size.height * .015,
                  bottom: size.height * .015,
                ),
                child: Row(
                  children: [
                    Icon(Icons.remove_red_eye, color: Colors.green),
                    Text(
                      'Read At: ${widget.message.read.isEmpty ? 'Not seen yet' : formatLastSeen(widget.message.sent)}',
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
