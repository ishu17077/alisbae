import 'package:alisbae/data/constant/table_name.dart';
import 'package:alisbae/data/datasource/datasource_contract.dart';
import 'package:alisbae/model/book_store.dart';
import 'package:sqflite/sqflite.dart';

class SqfliteDatasourceImpl implements IDataSource {
  final Database _db;

  const SqfliteDatasourceImpl(this._db);
  @override
  Future<int> addBook(BookStore book) async {
    int id = await _db.insert(
      BooksTable.tableName,
      book.toJSON(),
      conflictAlgorithm: ConflictAlgorithm.rollback,
    );
    return id;
  }

  @override
  Future<void> deleteBook(int id) async {
    await _db.delete(
      BooksTable.tableName,
      where: "${BooksTable.id} = ?",
      whereArgs: [id],
    );
  }

  @override
  Future<List<BookStore>> getDownloadedBooks() async {
    var books = await _db.query(
      BooksTable.tableName,
      orderBy: "${BooksTable.lastRead} DESC, ${BooksTable.isFavorite} DESC",
    );
    return books.map((bookMap) {
      return BookStore.fromJSON(bookMap);
    }).toList();
  }

  @override
  Future<void> updateFavoriteStatus({
    required int id,
    required bool isFavorite,
  }) async {
    await _db.update(
      BooksTable.tableName,
      {BooksTable.isFavorite: isFavorite ? 1 : 0},
      where: "id = ?",
      whereArgs: [id],
    );
  }

  @override
  Future<void> updateLastRead({
    required int id,
    required int currentRead,
    DateTime? lastRead,
  }) async {
    lastRead ??= DateTime.now();

    await _db.update(BooksTable.tableName, {
      BooksTable.lastRead: lastRead.millisecondsSinceEpoch,
      BooksTable.currentRead: currentRead,
    });
  }

  @override
  Future<BookStore?> searchBookByServerId(int serverId) async {
    final bookMap = await _db.query(
      BooksTable.tableName,
      where: "${BooksTable.serverId} = ?",
      whereArgs: [serverId],
      limit: 1,
    );
    if (bookMap.isEmpty) {
      return null;
    }

    return BookStore.fromJSON(bookMap.first);
  }

  @override
  Future<BookStore?> searchBookById(int id) async {
    final bookMap = await _db.query(
      BooksTable.tableName,
      where: "${BooksTable.id} = ?",
      whereArgs: [id],
      limit: 1,
    );
    if (bookMap.isEmpty) {
      return null;
    }

    return BookStore.fromJSON(bookMap.first);
  }
}
