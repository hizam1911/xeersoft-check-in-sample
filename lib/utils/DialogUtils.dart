import 'package:flutter/material.dart';

class DialogUtils {
  static Future<T?> showDismissDialog<T>({
    required BuildContext context,
    required String title,
    required String content,
  }) {
    return showDialog<T?>(
        context: context,
        barrierDismissible: false, // Prevents dismissing by tapping outside
        builder: (BuildContext dialogContext)
        {
          return AlertDialog(
            title: Text(title),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(content),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Approve'),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
              ),
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
              ),
            ],
          );
        });
  }

  static Future<bool?> showDialogPopup(BuildContext context, String title, String content) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: Text(title),
            content: Text(content),

            actions: [
              OutlinedButton(
                  onPressed: () {
                    Navigator.pop(dialogContext, false);
                  },
                  child: Text("Cancel")
              ),
              FilledButton(
                  onPressed: () {
                    Navigator.pop(dialogContext, true);
                  },
                  child: Text("Confirm")
              ),
            ],
          );
        }
    );
  }
}