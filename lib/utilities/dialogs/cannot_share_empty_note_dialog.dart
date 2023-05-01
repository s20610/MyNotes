import 'package:first_flutter_app/utilities/dialogs/generic_dialog.dart';
import 'package:flutter/material.dart';

Future<void> showCannotShareEmptyNoteDialog(
  BuildContext context,
) {
  return showGenericDialog<void>(
      context: context,
      title: "Can't share note",
      content: "You can't share empty notes, write something first!",
      optionsBuilder: () => {'OK': null});
}
