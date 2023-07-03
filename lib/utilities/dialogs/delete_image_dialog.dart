import 'package:flutter/material.dart';
import 'package:holdit/utilities/dialogs/generic_dialog.dart';

Future<bool> deleteImageDialog(BuildContext context) async {
  return showGenericDialog(
    context: context,
    title: 'Delete',
    content: 'Are you sure you want to delete this image?',
    optionsBuilder: () => {'Cancel': false, 'Delete': true},
  ).then(
    (value) => value ?? false,
  );
}
