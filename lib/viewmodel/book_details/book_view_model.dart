part of '../home/home_view_model.dart';

class BookViewModel extends HomeViewModel {
  List<BookStore> books = [];
  BookViewModel(
    super._bookDataSource,
    super._folderDatasource,
    super._dataCrawler,
    super._imageSaver,
  );

  Future<BookStore?> downloadBook({
    required BookDetails bookDetails,
    required BookSearchResult bookSearchResult,
    Function(int count, int total)? callback,
  }) async {
    try {
      final bookPresent = await _bookDataSource.searchBookByServerId(
        bookSearchResult.id,
      );
      if (bookPresent != null) {
        Fluttertoast.showToast(msg: "This book is already downloaded");
        return bookPresent;
      }

      final filePath = await _dataCrawler.downloadBook(
        fileName: bookDetails.fileName!,
        callback: callback,
      );
      if (filePath == null || filePath.isEmpty) {
        return null;
      }
      String? imagePath;
      if (bookDetails.imageLink.isNotEmpty) {
        imagePath = await _imageSaver.saveImage(
          bookDetails.imageLink,
          bookSearchResult.bookTitle,
        );
      }
      _imageSaver.saveImage(bookDetails.imageLink, bookSearchResult.bookTitle);
      final book = BookStore(
        name: bookSearchResult.bookTitle,
        author: bookSearchResult.author,
        imageUrl: bookSearchResult.postImage,
        bookPath: filePath,
        addedOn: DateTime.now(),
        currentRead: 1,
        isFavorite: false,
        lastRead: null,
        serverId: bookSearchResult.id,
        serverUrl: bookSearchResult.postLink,
        description: bookDetails.description,
        rating: null,
        review: null,
        imagePath: imagePath,
      );
      final id = await _bookDataSource.addBook(book);
      final bookReturn = BookStore.fromJSON({...book.toJSON(), "id": id});
      books.add(bookReturn);
      return bookReturn;
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Please contact your personal unpaid developer. Wink. $e",
      );
      return null;
    }
  }

  Future<BookDetails> getBookDetailsOnline(String bookUrl) async {
    return BookDetails.fromJSON(
      await _dataCrawler.getBookInfo(bookUrl: bookUrl),
    );
  }

  Future<void> updateLastRead({
    required int id,
    required int currentRead,
    required DateTime lastRead,
  }) async {
    final book = books.firstWhere((book) => book.id == id);
    book.currentRead = currentRead;
    book.lastRead = lastRead;

    await _bookDataSource.updateLastRead(id: id, currentRead: currentRead);
  }

  Future<void> updateRatingandReview({
    required int id,
    int? rating,
    String? review,
  }) async {
    final book = books.firstWhere((book) => book.id == id);
    if (rating != null) {
      book.rating = rating;
    }
    if (review != null || review!.isNotEmpty) {
      book.review = review;
    }

    await _bookDataSource.setRatingandReview(id, rating, review);
  }

  Future<BookStore?> searchBookByServerId(int id) async {
    return await _bookDataSource.searchBookById(id);
  }
}
