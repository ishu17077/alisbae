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
      version: 3,
      onUpgrade: _upgradeDb,
    );
    return _database!;
  }

  Future<void> _populateDb(Database db, int version) async {
    await _createBooksTable(db);
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
    ${BooksTable.imageUrl} TEXT,
    ${BooksTable.serverId} INTEGER,
    ${BooksTable.serverUrl} TEXT,
    ${BooksTable.lastRead} TIMESTAMP,
    ${BooksTable.rating} INTEGER CHECK (${BooksTable.rating} >= 1 AND ${BooksTable.rating} <= 5),
    ${BooksTable.description} TEXT,
    ${BooksTable.imagePath} TEXT,
    ${BooksTable.review} TEXT
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
