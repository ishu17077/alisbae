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

    _database = await openDatabase(dbPath, onCreate: _populateDb);
    return _database!;
  }

  Future<void> _populateDb(Database db, int version) async {
    await _createBooksTable(db);
    await _createIndices(db);
  }

  Future<void> _createBooksTable(Database db) async {
    await db
        .execute("""CREATE TABLE ${BooksTable.tableName}(
    ${BooksTable.id} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    ${BooksTable.bookName} VARCHAR(255) NOT NULL,
    ${BooksTable.author} VARCHAR(255) NOT NULL,
    ${BooksTable.bookPath} TEXT NOT NULL,
    ${BooksTable.currentRead} INTEGER DEFAULT 1 NOT NULL,
    ${BooksTable.addedOn} TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    ${BooksTable.isFavorite} INTEGER DEFAULT 0 NOT NULL,
    ${BooksTable.serverId} INTEGER,
    ${BooksTable.serverUrl} TEXT,
    ${BooksTable.lastRead} TIMESTAMP
    )""")
        .then((_) {
          debugPrint("Successfully created ${BooksTable.tableName} table");
        })
        .catchError((e) {
          debugPrint("${BooksTable.tableName} creation failed");
        });
  }

  Future<void> _createIndices(Database db) async {
    final batch = db.batch();
    try {
      batch.execute(
        "CREATE UNIQUE INDEX uidx_books ON ${BooksTable.tableName} (${BooksTable.bookName}, ${BooksTable.author})",
      );
    } catch (e) {
      debugPrint("Indices creation failed $e");
    }
  }
}
