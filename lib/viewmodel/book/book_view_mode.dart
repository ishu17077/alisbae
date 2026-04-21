import 'package:alisbae/data/datasource/datasource_contract.dart';
import 'package:alisbae/model/book_details.dart';
import 'package:alisbae/model/book_store.dart';
import 'package:alisbae/model/search_result.dart';
import 'package:alisbae/ocean_of_pdfs/data_crawler.dart';
import 'package:fluttertoast/fluttertoast.dart';

class BookViewModel {
  final IDataSource dataSource;
  final DataCrawler _dataCrawler;

  List<BookStore> books = [];
  BookViewModel(this.dataSource, this._dataCrawler);

  Future<BookStore?> downloadBook({
    required BookDetails bookDetails,
    required BookSearchResult bookSearchResult,
    Function(int count, int total)? callback,
  }) async {
    try {
      final bookPresent = await dataSource.searchBookByServerId(
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
      );
      final id = await dataSource.addBook(book);
      return BookStore.fromJSON({...book.toJSON(), "id": id});
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

  Future<List<BookStore>> listAllBooksOffline() async {
    books = await dataSource.getDownloadedBooks();
    return books;
  }
}
