import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapp/model/chat_user.dart';
import 'package:chatapp/services/user_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UpdateProfileView extends StatefulWidget {
  final ChatUser myProfile;
  const UpdateProfileView({super.key, required this.myProfile});

  @override
  State<UpdateProfileView> createState() => _UpdateProfileViewState();
}

class _UpdateProfileViewState extends State<UpdateProfileView> {
  late final GlobalKey<FormState> _formKey;
  late final UserService userService;
  String? _image;
  @override
  void initState() {
    _formKey = GlobalKey<FormState>();

    userService = UserService();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: EdgeInsets.all(16.0),
          child: const Text(
            'Profile Screen',
            style: TextStyle(color: Colors.white),
          ),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(15),
                          ),
                          child:
                              _image == null
                                  ? ClipRRect(
                                  borderRadius: BorderRadius.all(Radius.circular(MediaQuery.of(context).size.height*0.2)),
                                  child: CachedNetworkImage(
                                    width: MediaQuery.of(context).size.height*0.2,
                                    height: MediaQuery.of(context).size.height*0.2,
                                    fit: BoxFit.cover,
                                    imageUrl: userService.me.image,
                                    errorWidget: (context, url, error) =>
                                    const CircleAvatar(child: Icon(CupertinoIcons.person)),
                                  ),)
                                  : Image.file(
                                    File(_image!),
                                    width: mq.height * .2,
                                    height: mq.height * .2,
                                    fit: BoxFit.cover,
                                  ),
                        ),
                        Positioned(
                          child: ElevatedButton(
                            onPressed: () {
                              showBottomDialog();
                            },
                            child: Icon(Icons.add_a_photo),
                          ),
                        ),
                      ],
                    ),

                    Padding(
                      padding: EdgeInsets.all(2.0),
                      child: Text(
                        widget.myProfile.email,
                        style: TextStyle(color: Colors.black54, fontSize: 16),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(2.0),
                      child: TextFormField(
                        onSaved: (value) => userService.me.name = value ?? '',
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Name cant be empty';
                          }
                          return null;
                        },
                        initialValue: widget.myProfile.name,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Name',
                          prefixIcon: Icon(Icons.person),
                        ),

                        keyboardType: TextInputType.text,
                        autofocus: true,
                        autocorrect: false,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(2.0),
                      child: TextFormField(
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'About cant be empty';
                          }
                          return null;
                        },
                        initialValue: widget.myProfile.about,
                        onSaved: (value) => userService.me.about = value ?? '',

                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'About',

                          prefixIcon: Icon(Icons.info),
                        ),
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        autofocus: true,
                        autocorrect: false,
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2.0,
                      ),
                      child: Center(
                        child: ElevatedButton(
                          onPressed: () async {
                            userService.updateUserProfile().then(
                              (value) => {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text(
                                      'Profile updated successfully',
                                    ),
                                  ),
                                ),
                              },
                            );
                          },

                          child: const Text('Update Profile'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
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
          height: size.height / 4,
            child: Column(
          children: [
            Text(
              "Pick Profile Picture",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: size.height * .02),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: const CircleBorder(),
                    fixedSize: Size(
                      MediaQuery.of(context).size.width * .3,
                      MediaQuery.of(context).size.height * .15,
                    ),
                  ),
                  onPressed: () async {
                    final ImagePicker picker = ImagePicker();
                    final XFile? image = await picker.pickImage(
                      source: ImageSource.gallery,
                      imageQuality: 70,
                    );

                    if (image != null) {
                      setState(() => _image = image.path);
                      await userService.updateProfilePhoto(
                        file: File(image.path),
                      );
                      if (mounted) Navigator.pop(context);
                    }
                  },
                  child: Icon(Icons.image, size: 30,),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: const CircleBorder(),
                    fixedSize: Size(
                      MediaQuery.of(context).size.width * .3,
                      MediaQuery.of(context).size.height * .15,
                    ),
                  ),
                  onPressed: () async {
                    final ImagePicker picker = ImagePicker();
                    final XFile? image = await picker.pickImage(
                      source: ImageSource.camera,
                      imageQuality: 70,
                    );

                    if (image != null) {
                      setState(() => _image = image.path);
                      await userService.updateProfilePhoto(
                        file: File(image.path),
                      );
                      if (mounted) Navigator.pop(context);
                    }
                  },
                  child: Icon(Icons.camera, size: 30,),
                ),
              ],
            ),
          ],
        ));
      },
    );
  }
}
