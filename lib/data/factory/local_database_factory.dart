import 'dart:async';

import 'package:alisbae/data/constant/table_name.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDatabaseFactory {
  static LocalDatabaseFactory? _instance;

  LocalDatabaseFactory.createInstance();

  factory LocalDatabaseFactory() {
    _instance ??= LocalDatabaseFactory.createInstance();
    return _instance!;
  }

  static Database? _database;

  Future<Database> getDatabase() async {
    if (_database != null) {
      return _database!;
    }

    String databasePath = await getDatabasesPath();
    String dbPath = join(databasePath, "book_details.db");

    _database = await openDatabase(
      dbPath,
      onCreate: _populateDb,
      version: 4,
      onUpgrade: _upgradeDb,
      onConfigure: _configureDb,
    );
    return _database!;
  }

  Future<void> _populateDb(Database db, int version) async {
    await _createBooksTable(db);
    await _createFoldersTable(db);
    await _createIndices(db);
  }

  Future<void> _upgradeDb(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.transaction((txn) async {
        await txn.execute(
          """ALTER TABLE ${BooksTable.tableName} ADD COLUMN ${BooksTable.rating} INTEGER CHECK (${BooksTable.rating} >= 1 AND ${BooksTable.rating} <= 5);""",
        );
        await txn.execute(
          """ALTER TABLE ${BooksTable.tableName} ADD COLUMN ${BooksTable.review} TEXT;""",
        );
      });
    }
    if (oldVersion < 3) {
      await db.transaction((txn) async {
        await txn.execute(
          """ALTER TABLE ${BooksTable.tableName} ADD COLUMN ${BooksTable.description} TEXT;""",
        );

        await txn.execute(
          """ALTER TABLE ${BooksTable.tableName} ADD COLUMN ${BooksTable.imagePath} TEXT;""",
        );
      });
    }
    if (oldVersion < 4) {
      await _createFoldersTable(db);
      await db.transaction((txn) async {
        await txn.execute(
          """ALTER TABLE ${BooksTable.tableName} ADD COLUMN ${BooksTable.folderId} INTEGER 
               REFERENCES ${FoldersTable.tableName}(${FoldersTable.id})
                  ON DELETE CASCADE""",
        );
        await txn.execute(
          "CREATE UNIQUE INDEX INDEX IF NOT EXISTS uidx_books_folder ON ${BooksTable.tableName} (${BooksTable.bookName}, IFNULL(${BooksTable.author},'LABADABA AUTHOR'), IFNULL(${BooksTable.folderId}, -1))",
        );

        await txn.execute(
          "CREATE UNIQUE INDEX INDEX IF NOT EXISTS uidx_folders_name_parent_folder_id ON ${FoldersTable.tableName} (IFNULL(${FoldersTable.parentFolderId}, -1), ${FoldersTable.name})",
        );
      });
    }
  }

  Future<void> _createBooksTable(Database db) async {
    await db
        .execute("""CREATE TABLE ${BooksTable.tableName}(
    ${BooksTable.id} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    ${BooksTable.bookName} VARCHAR(255) NOT NULL CHECK(${BooksTable.bookName} <> ''),
    ${BooksTable.author} VARCHAR(255) NOT NULL,
    ${BooksTable.bookPath} TEXT NOT NULL,
    ${BooksTable.currentRead} INTEGER DEFAULT 1 NOT NULL,
    ${BooksTable.addedOn} TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    ${BooksTable.isFavorite} INTEGER DEFAULT 0 NOT NULL,
    ${BooksTable.imageUrl} TEXT,
    ${BooksTable.serverId} INTEGER,
    ${BooksTable.serverUrl} TEXT,
    ${BooksTable.lastRead} TIMESTAMP,
    ${BooksTable.rating} INTEGER CHECK (${BooksTable.rating} >= 1 AND ${BooksTable.rating} <= 5),
    ${BooksTable.description} TEXT,
    ${BooksTable.imagePath} TEXT,
    ${BooksTable.review} TEXT,
    ${BooksTable.folderId} INTEGER,
    FOREIGN KEY (${BooksTable.folderId}) 
      REFERENCES ${FoldersTable.tableName}(${FoldersTable.id})
        ON DELETE CASCADE
    )""")
        .then((_) {
          debugPrint("Successfully created ${BooksTable.tableName} table");
        })
        .catchError((e) {
          debugPrint("${BooksTable.tableName} creation failed");
        });
  }

  Future<void> _createFoldersTable(Database db) async {
    await db
        .execute("""CREATE TABLE ${FoldersTable.tableName}(
    ${FoldersTable.id} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    ${FoldersTable.name} VARCHAR(255) NOT NULL CHECK(${FoldersTable.name} <> ''),
    ${FoldersTable.color} VARCHAR(255),
    ${FoldersTable.parentFolderId} INTEGER,
    FOREIGN KEY (${FoldersTable.parentFolderId}) 
      REFERENCES ${FoldersTable.tableName}(${FoldersTable.id}) 
        ON DELETE CASCADE
    )""")
        .then(
          (_) => debugPrint(
            "Successfully created ${FoldersTable.tableName} table",
          ),
        )
        .catchError(
          (e) =>
              debugPrint("Table ${FoldersTable.tableName} creation failed: $e"),
        );
  }

  Future<void> _createIndices(Database db) async {
    try {
      final batch = db.batch();
      //! Essencial indices to prevent data conflicts
      batch.execute(
        "CREATE UNIQUE INDEX IF NOT EXISTS uidx_books ON ${BooksTable.tableName} (${BooksTable.bookName}, ${BooksTable.author})",
      );

      batch.execute(
        "CREATE UNIQUE INDEX IF NOT EXISTS uidx_books_folder ON ${BooksTable.tableName} (IFNULL(${BooksTable.bookName},'LABADABA BOOK'), IFNULL(${BooksTable.author},'LABADABA AUTHOR'), IFNULL(${BooksTable.folderId}, -1))",
      );

      batch.execute(
        "CREATE UNIQUE INDEX IF NOT EXISTS uidx_folders_name_parent_folder_id ON ${FoldersTable.tableName} (${FoldersTable.name}, IFNULL(${FoldersTable.parentFolderId}, -1))",
      );

      await batch.commit(noResult: true);
      //TODO: Non essential queries to improve performance
    } catch (e) {
      debugPrint("Indices creation failed $e");
    }
  }

  Future<void> _configureDb(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
    // await db.execute('PRAGMA recursive_triggers = ON');
  }
}
