import 'dart:io';
import 'dart:isolate';

import 'package:alisbae/data/datasource/book_datasource/book_datasource_contract.dart';
import 'package:alisbae/data/datasource/folder_datasource/folder_datasource_contract.dart';
import 'package:alisbae/data/model/book_store.dart';
import 'package:alisbae/model/book_details.dart';
import 'package:alisbae/model/search_result.dart';
import 'package:alisbae/service/image_saver/image_saver.dart';
import 'package:alisbae/service/ocean_of_pdfs/data_crawler.dart';
import 'package:fluttertoast/fluttertoast.dart';

part '../book_details/book_view_model.dart';

class HomeViewModel {
  final IBookDataSource _bookDataSource;
  final IFolderDatasource _folderDatasource;
  final DataCrawler _dataCrawler;
  final ImageSaver _imageSaver;
  List<BookStore> books = [];

  HomeViewModel(
    this._bookDataSource,
    this._folderDatasource,
    this._dataCrawler,
    this._imageSaver,
  );

  Future<List<BookSearchResult>> searchBooksOnline(String searchParam) async {
    final searchQuery = await _dataCrawler.search(searchParam: searchParam);

    final List<BookSearchResult> bookSearchResults = searchQuery
        .map((sQ) => BookSearchResult.fromJSON(sQ))
        .toList();

    return bookSearchResults;
  }

  Future<void> deleteBook(int id) async {
    final book = await _bookDataSource.searchBookById(id);
    if (book == null) {
      return;
    }
    await _bookDataSource.deleteBook(book.id!);
    await _dataCrawler.deleteDownload(book.bookPath);
    if (book.imagePath != null && book.imagePath!.isNotEmpty) {
      final imageFile = File(book.imagePath!);
      if (await imageFile.exists()) {
        await imageFile.delete();
      }
    }

    books.removeWhere((cachedBook) => cachedBook.id == id);
  }

  Future<List<BookStore>> listAllBooksOffline({
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && books.isNotEmpty) {
      return books;
    }
    books = await _bookDataSource.getDownloadedBooks();
    updateImageAndDscIfUrlPresent();
    return books;
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
        await _bookDataSource.setImagePath(book.id!, imageLocation);
      }
      if ((book.description == null || book.description!.isEmpty) &&
          book.serverUrl != null) {
        final bookDetails = BookDetails.fromJSON(
          await _dataCrawler.getBookInfo(bookUrl: book.serverUrl!),
        );
        await _bookDataSource.setDescription(book.id, bookDetails.description);
      }
    }
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

  Future<void> updateLikeStatus({
    required int id,
    required bool isLiked,
  }) async {
    final book = books.firstWhere((book) => book.id == id);
    book.isFavorite = isLiked;

    await _bookDataSource.updateFavoriteStatus(id: id, isFavorite: isLiked);
  }
}
