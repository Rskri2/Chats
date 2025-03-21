import 'package:chatapp/views/dialog/show_generic_dialog.dart';
import 'package:flutter/material.dart';

Future<bool> showLogoutDialog({
  required BuildContext context,
}) async {
  return showGenericDialog(
    optionsBuilder: () => ({'OK': true, 'Cancel': false}),
    context: context,
    title: 'Logout',
    content: 'Are you sure to logout?',
  ).then((value) => value ?? false);
}
