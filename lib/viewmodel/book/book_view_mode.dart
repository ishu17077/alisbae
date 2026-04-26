import 'dart:io';
import 'dart:isolate';

import 'package:alisbae/data/datasource/book_datasource/book_datasource_contract.dart';
import 'package:alisbae/data/datasource/folder_datasource/folder_datasource_contract.dart';
import 'package:alisbae/model/book_details.dart';
import 'package:alisbae/data/model/book_store.dart';
import 'package:alisbae/model/search_result.dart';
import 'package:alisbae/service/image_saver/image_saver.dart';
import 'package:alisbae/service/ocean_of_pdfs/data_crawler.dart';
import 'package:fluttertoast/fluttertoast.dart';

class BookViewModel {
  final IBookDataSource bookDataSource;
  final IFolderDatasource folderDatasource;
  final DataCrawler _dataCrawler;
  final ImageSaver _imageSaver;

  List<BookStore> books = [];
  BookViewModel(
    this.bookDataSource,
    this.folderDatasource,
    this._dataCrawler,
    this._imageSaver,
  );

  Future<BookStore?> downloadBook({
    required BookDetails bookDetails,
    required BookSearchResult bookSearchResult,
    Function(int count, int total)? callback,
  }) async {
    try {
      final bookPresent = await bookDataSource.searchBookByServerId(
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
      final id = await bookDataSource.addBook(book);
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

  Future<List<BookSearchResult>> searchBooksOnline(String searchParam) async {
    final searchQuery = await _dataCrawler.search(searchParam: searchParam);

    final List<BookSearchResult> bookSearchResults = searchQuery
        .map((sQ) => BookSearchResult.fromJSON(sQ))
        .toList();

    return bookSearchResults;
  }

  Future<BookDetails> getBookDetailsOnline(String bookUrl) async {
    return BookDetails.fromJSON(
      await _dataCrawler.getBookInfo(bookUrl: bookUrl),
    );
  }

  Future<List<BookStore>> listAllBooksOffline({
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && books.isNotEmpty) {
      return books;
    }
    books = await bookDataSource.getDownloadedBooks();
    updateImageAndDscIfUrlPresent();
    return books;
  }

  Future<void> deleteBook(int id) async {
    final book = await bookDataSource.searchBookById(id);
    if (book == null) {
      return;
    }
    await bookDataSource.deleteBook(book.id!);
    await _dataCrawler.deleteDownload(book.bookPath);
    if (book.imagePath != null && book.imagePath!.isNotEmpty) {
      final imageFile = File(book.imagePath!);
      if (await imageFile.exists()) {
        await imageFile.delete();
      }
    }

    books.removeWhere((cachedBook) => cachedBook.id == id);
  }

  Future<void> updateLastRead({
    required int id,
    required int currentRead,
    required DateTime lastRead,
  }) async {
    final book = books.firstWhere((book) => book.id == id);
    book.currentRead = currentRead;
    book.lastRead = lastRead;

    await bookDataSource.updateLastRead(id: id, currentRead: currentRead);
  }

  Future<void> updateLikeStatus({
    required int id,
    required bool isLiked,
  }) async {
    final book = books.firstWhere((book) => book.id == id);
    book.isFavorite = isLiked;

    await bookDataSource.updateFavoriteStatus(id: id, isFavorite: isLiked);
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

    await bookDataSource.setRatingandReview(id, rating, review);
  }

  static List<BookStore> _filterBooks(List<BookStore> books) {
    return books
        .where(
          (book) =>
              (book.imagePath == null &&
                  (book.imageUrl != null && book.imageUrl!.isNotEmpty)) ||
              book.description == null,
        )
        .toList();
  }

  Future<void> updateImageAndDscIfUrlPresent() async {
    final books = this.books;
    final List<BookStore> booksWithoutImagesOrDsc = await Isolate.run(
      () => _filterBooks(books),
    );
    for (var book in booksWithoutImagesOrDsc) {
      if (book.imagePath == null || book.imagePath!.isEmpty) {
        final imageLocation = await _imageSaver.saveImage(
          book.imageUrl!,
          book.name,
        );
        await bookDataSource.setImagePath(book.id!, imageLocation);
      }
      if ((book.description == null || book.description!.isEmpty) &&
          book.serverUrl != null) {
        final bookDetails = BookDetails.fromJSON(
          await _dataCrawler.getBookInfo(bookUrl: book.serverUrl!),
        );
        await bookDataSource.setDescription(book.id!, bookDetails.description);
      }
    }
  }
}
