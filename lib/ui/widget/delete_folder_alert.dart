import 'package:alisbae/data/model/folder_store.dart';
import 'package:flutter/material.dart';

Future<bool> buildDeleteFolderAlertBox(
  BuildContext context,
  FolderStore folder,
) async {
  bool? shouldDelete = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Column(
          children: [
            Text(
              "Do you really want to delete ${folder.name} and all its content?",
              style: TextStyle(fontSize: 15),
            ),
            SizedBox(height: 20),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            child: Text("Yes", style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, false);
            },
            child: Text("No"),
          ),
        ],
      );
    },
  );
  return shouldDelete ?? false;
}
