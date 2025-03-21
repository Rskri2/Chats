class ChatUser {
   String about;
   String createdAt;
   String email;
   String id;
   String image;
   bool isOnline;
   String lastOnline;
   String name;
   String pushToken;
   ChatUser({
     required this.about,
    required this.createdAt,
    required this.email,
    required this.id,
    required this.image,
    required this.isOnline,
    required this.lastOnline,
    required this.name,
    required this.pushToken
  });
  Map<String, dynamic> toJson(){
    final data = <String, dynamic>{};

    data['about'] = about ;
    data['createdAt'] = createdAt;
    data['email'] = email;
    data['id'] = id;
    data['image'] = image;
    data['isOnline'] = isOnline;
    data['lastOnline'] = lastOnline;
    data['name'] = name;
    data['pushToken'] = pushToken;
    return data;
  }

  static ChatUser fromJson(Map<dynamic, dynamic> data){
    return ChatUser(
        about: data['about'] ??  '',
        createdAt: data['createdAt'] ??  '',
        email: data['email'] ?? '',
        id: data['id'] ??  '',
        image: data['image'] ?? '',
        isOnline: data['isOnline'] ?? false,
        lastOnline: data['lastOnline'] ?? '',
        name: data['name'] ?? '',
        pushToken: data['pushToken'] ?? ''
    );
  }
}
