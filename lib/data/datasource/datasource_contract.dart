import 'package:alisbae/model/book_store.dart';

abstract class IDataSource {
  Future<int> addBook(BookStore book);
  Future<List<BookStore>> getDownloadedBooks();
  Future<void> deleteBook(int id);
  Future<void> updateLastRead({
    required int id,
    required int currentRead,
    DateTime? lastRead,
  });
  Future<void> updateFavoriteStatus({
    required int id,
    required bool isFavorite,
  });
  Future<BookStore?> searchBookByServerId(int serverId);
  Future<BookStore?> searchBookById(int id);
  Future<void> setImagePath(int id, String path);
  Future<void> setImageUrl(int id, String imageUrl);
  Future<void> setRatingandReview(int id, int? rating, String? review);
}
