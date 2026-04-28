import 'dart:io';

import 'package:alisbae/data/model/book_store.dart';
import 'package:flutter/material.dart';

Future<bool> buildDeleteBookAlertBox(
  BuildContext context,
  BookStore bookStore,
) async {
  bool? shouldDelete = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Column(
          children: [
            Text(
              "Do you really want to delete ${bookStore.name}?",
              style: TextStyle(fontSize: 15),
            ),
            SizedBox(height: 20),
            bookStore.imagePath != null
                ? Image.file(File(bookStore.imagePath!), height: 100)
                : SizedBox(),
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
