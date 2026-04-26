import 'package:alisbae/data/constant/table_name.dart';
import 'package:flutter/material.dart';

extension ColorToHex on Color {
  String toHex() {
    return '#${this.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}';
  }

  static Color fromHex(String hexValue) {
    return Color(
      int.tryParse(hexValue.replaceFirst('#', '0xFF')) ?? 0xFFFFFFFF,
    );
  }
}

class FolderStore {
  late int _id;
  int get id => _id;
  String name;
  int? parentFolderId;
  Color? color;

  FolderStore({required this.name, this.parentFolderId, this.color});

  Map<String, dynamic> toJSON() {
    return {
      "name": name,
      "parent_folder_id": parentFolderId,
      "color": color?.toHex(),
    };
  }

  factory FolderStore.fromJSON(Map<String, dynamic> map) {
    final folderStore = FolderStore(
      name: map[FoldersTable.name],
      color:
          (map[FoldersTable.color] as String?) != null ||
              (map[FoldersTable.color]! as String).isNotEmpty
          ? ColorToHex.fromHex(map[FoldersTable.color] as String)
          : null,
      parentFolderId: map[FoldersTable.parentFolderId] as int?,
    );
    folderStore._id = map["id"];
    return folderStore;
  }
}
