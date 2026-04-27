import 'package:alisbae/data/constant/table_name.dart';
import 'package:alisbae/data/datasource/folder_datasource/folder_datasource_contract.dart';
import 'package:alisbae/data/model/folder_store.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class SqfliteFolderDatasourceImpl implements IFolderDatasource {
  final Database _db;
  SqfliteFolderDatasourceImpl(this._db);

  @override
  Future<int> addFolder(FolderStore folder) async {
    try {
      int id = await _db.insert(
        FoldersTable.tableName,
        folder.toJSON(),
        conflictAlgorithm: ConflictAlgorithm.rollback,
      );
      return id;
    } on DatabaseException catch (e) {
      if (e.isUniqueConstraintError()) {
        throw Exception("This folder already exists.");
      } else {
        debugPrint(e.toString());
        throw Exception(e.toString());
      }
    }
  }

  @override
  Future<void> deleteFolder(int id) async {
    try {
      await _db.delete(
        FoldersTable.tableName,
        where: "${FoldersTable.id} = ?",
        whereArgs: [id],
      );
    } on DatabaseException catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<List<FolderStore>> listFolders({int? parentFolderId}) async {
    try {
      final directories = await _db.query(
        FoldersTable.tableName,
        where: "${FoldersTable.parentFolderId} = ?",
        whereArgs: [parentFolderId],
      );
      return directories
          .map((directory) => FolderStore.fromJSON(directory))
          .toList();
    } on DatabaseException catch (e) {
      throw Exception(e.toString());
    }
  }
}
