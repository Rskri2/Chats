import 'package:chatapp/model/message.dart';
import 'package:chatapp/services/user_service.dart';
import 'package:flutter/material.dart';

void showMessageUpdateDialog({
  required BuildContext context,
  required Message message
})  {
  final UserService userService = UserService();
  String updatedMessage = message.msg;
  showDialog(context: context, builder: (context){
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.message, color: Colors.blue, size: 28),
          Text('  Update message'),
        ],
      ),
      content: TextFormField(
      initialValue: updatedMessage,
       onChanged: (value){
        updatedMessage = value;
       },
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Message',
        ),
        autofocus: true,
        autocorrect: false,
      ),
      actions: [
        TextButton(onPressed: () async{

          await userService.updateMessage(message, updatedMessage);
          Navigator.of(context).pop();
        }, child:  Text('Update ')),
        TextButton(onPressed: (){
          Navigator.of(context).pop();
        }, child: Text('Cancel'))
      ]
    );
  });
}
