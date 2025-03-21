import 'package:chatapp/views/dialog/show_generic_dialog.dart';
import 'package:flutter/material.dart';

Future<bool> showDeleteDialog({
  required BuildContext context,
}) async {
  return showGenericDialog(
    optionsBuilder: () => ({'OK': true, 'Cancel': false}),
    context: context,
    title: 'Delete',
    content: 'Are you sure to delete?',
  ).then((value) => value ?? false);
}
