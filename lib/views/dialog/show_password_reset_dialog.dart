import 'package:chatapp/views/dialog/show_generic_dialog.dart';
import 'package:flutter/cupertino.dart';

Future<void> showPasswordResetDialog({
  required BuildContext context,
}) async {
  showGenericDialog(
    optionsBuilder: () => {'OK': null},
    context: context,
    title: 'Reset password',
    content: "We' have sent password reset link to the given email",
  );
}
