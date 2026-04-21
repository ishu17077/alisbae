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
    var books = await _db.query(BooksTable.tableName);
    return books.map((bookMap) {
      return BookStore.fromJSON(bookMap);
    }).toList();
  }

  @override
  Future<void> updateFavoriteStatus({
    required int id,
    required bool isFavorite,
  }) async {
    await _db.update(BooksTable.tableName, {
      BooksTable.isFavorite: isFavorite ? 1 : 0,
    });
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
}
