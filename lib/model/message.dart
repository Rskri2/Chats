class Message {
  final String fromId;
  final String msg;
  final String read;
  final String sent;
  final String toId;
  final String type;

  const Message({
    required this.fromId,
    required this.msg,
    required this.read,
    required this.sent,
    required this.toId,
    required this.type,
  });

  Map<String, dynamic> toJson(){
    final data = <String, dynamic>{};
    data['fromId'] = fromId;
    data['msg'] = msg;
    data['read'] = read;
    data['sent'] = sent;
    data['toId'] = toId;
    data['type'] = type;

    return data;
  }
  static Message fromJson(Map<String, dynamic> data){
    return Message(
        fromId: data['fromId'] ??  '',
        msg: data['msg'] ??  '',
        read: data['read'] ?? '',
        sent: data['sent'] ??  '',
        toId: data['toId'] ?? '',
        type: data['type'] ?? 'text',
    );
  }
}
