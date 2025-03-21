import 'package:chatapp/views/dialog/show_generic_dialog.dart';
import 'package:flutter/cupertino.dart';

Future<void> showErrorDialog({
  required BuildContext context,
  required String content,
}) async {
  return showGenericDialog(
    optionsBuilder: () => ({'OK': null}),
    context: context,
    title: ' An error occurred',
    content: content,
  );
}
