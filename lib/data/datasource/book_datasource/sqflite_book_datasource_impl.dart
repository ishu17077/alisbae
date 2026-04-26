part of '../sqflite_datasource_impl.dart';

class SqfliteBookDatasourceImpl implements IBookDataSource {
  final Database _db;
  SqfliteBookDatasourceImpl(this._db);

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

    await _db.update(
      BooksTable.tableName,
      {
        BooksTable.lastRead: lastRead.millisecondsSinceEpoch,
        BooksTable.currentRead: currentRead,
      },
      where: "${BooksTable.id} = ?",
      whereArgs: [id],
    );
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

  @override
  Future<void> setImagePath(int id, String path) async {
    await _db.update(
      BooksTable.tableName,
      {BooksTable.imagePath: path},
      where: "${BooksTable.id} = ?",
      whereArgs: [id],
    );
  }

  @override
  Future<void> setImageUrl(int id, String imageUrl) async {
    await _db.update(
      BooksTable.tableName,
      {BooksTable.imageUrl: imageUrl},
      where: "${BooksTable.id} = ?",
      whereArgs: [id],
    );
  }

  @override
  Future<void> setRatingandReview(int id, int? rating, String? review) async {
    await _db.update(
      BooksTable.tableName,
      {
        BooksTable.rating: rating,
        BooksTable.review: review != null
            ? review.isEmpty
                  ? null
                  : review
            : null,
      },
      where: "${BooksTable.id} = ?",
      whereArgs: [id],
    );
  }

  @override
  Future<void> setDescription(int id, String description) async {
    await _db.update(
      BooksTable.tableName,
      {BooksTable.description: description},
      where: "${BooksTable.id} = ?",
      whereArgs: [id],
    );
  }

  @override
  Future<void> setFolder({required int? folderId}) async {
    await _db.update(BooksTable.tableName, {BooksTable.folderId: folderId});
  }
}
