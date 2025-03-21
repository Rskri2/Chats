import 'package:chatapp/services/bloc/auth_bloc.dart';
import 'package:chatapp/services/bloc/auth_event.dart';
import 'package:chatapp/services/user_service.dart';
import 'package:chatapp/views/chats/chat_screen.dart';
import 'package:chatapp/views/dialog/show_logout_dialog.dart';
import 'package:chatapp/views/auth/update_profile_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../model/chat_user.dart';
import 'chat_list.dart';

class ChatHome extends StatefulWidget {
  const ChatHome({super.key});

  @override
  State<ChatHome> createState() => _ChatHomeState();
}

enum MenuAction { logout, profile }

class _ChatHomeState extends State<ChatHome> {
  List<ChatUser> _list = [];
  late final UserService userService;
  late final ChatUser myProfile;
  bool isSearching = false;
  List<ChatUser> _searchList = [];
  @override
  void initState() {
    super.initState();
    userService = UserService();
    userService.getSelfInfo();
    myProfile = userService.me;
    SystemChannels.lifecycle.setMessageHandler((message) {
      if (message.toString().contains('resume')) {
        userService.updateOnlineStatus(true);
      } else {
        userService.updateOnlineStatus(false);
      }
      return Future.value(message);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: FocusScope.of(context).unfocus,

      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (_, __) {
          if (isSearching) {
            setState(() => isSearching = !isSearching);
            return;
          }

          // some delay before pop
          Future.delayed(
            const Duration(milliseconds: 300),
            SystemNavigator.pop,
          );
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text('Chat app', textAlign: TextAlign.left),
            centerTitle: true,
            actions: [
              IconButton(
                tooltip: 'Search',
                onPressed: () => setState(() => isSearching = !isSearching),
                icon: Icon(Icons.search),
              ),
              PopupMenuButton<MenuAction>(
                onSelected: (value) async {
                  if (value == MenuAction.logout) {
                    final shouldLogout = await showLogoutDialog(
                      context: context,
                    );
                    if (shouldLogout) {
                      context.read<AuthBloc>().add(AuthEventLogout());
                    }
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => UpdateProfileView(myProfile: myProfile),
                      ),
                    );
                  }
                },
                itemBuilder: (context) {
                  return [
                    PopupMenuItem<MenuAction>(
                      value: MenuAction.logout,
                      child: Text('Logout'),
                    ),
                    PopupMenuItem<MenuAction>(
                      value: MenuAction.profile,
                      child: Text('Profile'),
                    ),
                  ];
                },
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(

            onPressed: showAddUserDialog,

            child: Icon(Icons.add),
          ),
          body: Column(
            children: [
              isSearching
                  ? Padding(
                    padding: EdgeInsets.all(10),
                    child: TextField(
                      onChanged: (val) {
                        _searchList.clear();
                        if(val.isEmpty){
                          _searchList = _list;
                        }
                        else{
                          for (var i in _list) {
                            if (i.name.toLowerCase().contains(val) ||
                                i.email.toLowerCase().contains(val)) {
                              _searchList.add(i);
                            }
                          }
                        }

                        setState(() => _searchList);
                      },
                      decoration: InputDecoration(
                        hintText: "Search...",
                        hintStyle: TextStyle(color: Colors.grey.shade600),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.grey.shade600,
                          size: 20,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        contentPadding: EdgeInsets.all(8),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(color: Colors.grey.shade100),
                        ),
                      ),
                    ),
                  )
                  : Padding(padding: EdgeInsets.all(0)),
              StreamBuilder(
                stream: userService.getMyUsersId(),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                    case ConnectionState.waiting:
                      return Center(child: CircularProgressIndicator());
                    case ConnectionState.done:
                    case ConnectionState.active:
                      return StreamBuilder(
                        stream: userService.getAllUsers(
                          snapshot.data?.docs.map((e) {
                                return e.id;
                              }).toList() ??
                              [],
                        ),

                        builder: (context, snapshot) {
                          switch (snapshot.connectionState) {
                            case ConnectionState.none:
                            case ConnectionState.waiting:
                            case ConnectionState.active:
                            case ConnectionState.done:
                              _list = snapshot.data?.docs.map((user) {
                                return ChatUser.fromJson(
                                  user.data(),
                                );
                              }).toList() ??
                                  [];
                              final  toSend =
                                  isSearching ? _searchList : _list;
                              if (toSend.isNotEmpty) {
                                return ChatList(
                                  users: toSend,
                                  onTap: (user) async {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ChatScreen(user: user),
                                      ),
                                    );
                                  },
                                );
                              } else {
                                return Text(
                                  'No conversations found!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 20),
                                );
                              }
                          }
                        },
                      );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showAddUserDialog() {
    String email = "";
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.person_add, color: Colors.blue, size: 28),
                Text('  Add User'),
              ],
            ),
            content: TextFormField(
              onChanged: (value) => email = value,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Email address',
                prefixIcon: Icon(Icons.email),
              ),

              keyboardType: TextInputType.emailAddress,
              autofocus: true,
              autocorrect: false,
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  if (email.trim().isNotEmpty) {
                    if (email.trim() == myProfile.email) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text(
                            'Email entered is same as your email id',
                          ),
                        ),
                      );
                    } else {
                      await userService
                          .addChatUser(email.trim())
                          .then(
                            (value) => {
                              if (!value)
                                {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text(
                                        'User does not exists',
                                      ),
                                    ),
                                  ),
                                },
                            },
                          );
                    }
                  }
                },
                child: const Text('Add user'),
              ),
            ],
          ),
    );
  }
}
