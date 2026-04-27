part of '../home/home_view_model.dart';

class BookViewModel {
  HomeViewModel homeViewModel;
  BookSearchResult? bookSearchResult;
  BookDetails? bookDetails;
  bool isDownloaded;
  BookStore? bookStore;
  BookViewModel(
    this.homeViewModel, {
    required this.isDownloaded,
    required this.bookStore,
    required this.bookSearchResult,
  }) {
    assert(
      isDownloaded && bookStore != null,
      "Bookstore cannot  be null if the book is already downloaded",
    );
    assert(
      !isDownloaded && bookSearchResult != null,
      "BookSearchResult cannot be null, if book is not downloaded",
    );
    checkBookAlreadyDownloaded();
  }

  Future<BookStore?> checkBookAlreadyDownloaded() async {
    if (bookStore != null) return bookStore!;
    if (!isDownloaded) {
      bookStore ??= await homeViewModel._bookDataSource.searchBookByServerId(
        bookSearchResult!.id,
      );
      if (bookStore != null) isDownloaded = true;
    }
    return bookStore;
  }

  Future<BookStore?> downloadBook({
    Function(int count, int total)? callback,
  }) async {
    if (bookStore != null) {
      return bookStore;
    }
    if (bookSearchResult == null) {
      Fluttertoast.showToast(
        msg: "Something went wrong, please contact your unpaid developer.",
      );
      return null;
    }
    await getBookDetailsOnline();
    try {
      final bookPresent = await homeViewModel._bookDataSource
          .searchBookByServerId(bookSearchResult!.id);
      if (bookPresent != null) {
        Fluttertoast.showToast(msg: "This book is already downloaded");
        return bookPresent;
      }

      final filePath = await homeViewModel._dataCrawler.downloadBook(
        fileName: bookDetails!.fileName!,
        callback: callback,
      );
      if (filePath == null || filePath.isEmpty) {
        return null;
      }
      String? imagePath;
      if (bookDetails!.imageLink.isNotEmpty) {
        imagePath = await homeViewModel._imageSaver.saveImage(
          bookDetails!.imageLink,
          bookSearchResult!.bookTitle,
        );
      }
      homeViewModel._imageSaver.saveImage(
        bookDetails!.imageLink,
        bookSearchResult!.bookTitle,
      );
      final book = BookStore(
        name: bookSearchResult!.bookTitle,
        author: bookSearchResult!.author,
        imageUrl: bookSearchResult!.postImage,
        bookPath: filePath,
        addedOn: DateTime.now(),
        currentRead: 1,
        isFavorite: false,
        lastRead: null,
        serverId: bookSearchResult!.id,
        serverUrl: bookSearchResult!.postLink,
        description: bookDetails!.description,
        rating: null,
        review: null,
        imagePath: imagePath,
      );
      final id = await homeViewModel._bookDataSource.addBook(book);
      final bookReturn = BookStore.fromJSON({...book.toJSON(), "id": id});
      bookStore = bookReturn;
      homeViewModel.books.add(bookReturn);
      return bookReturn;
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Please contact your personal unpaid developer. Wink. $e",
      );
      return null;
    }
  }

  Future<BookDetails> getBookDetailsOnline() async {
    if (bookDetails != null) {
      return bookDetails!;
    }
    bookDetails = BookDetails.fromJSON(
      await homeViewModel._dataCrawler.getBookInfo(
        bookUrl: bookSearchResult!.postLink,
      ),
    );
    return bookDetails!;
  }

  Future<void> updateLastRead({
    required int currentRead,
    required DateTime lastRead,
  }) async {
    if (bookStore == null) return;
    final book = homeViewModel.books.firstWhere(
      (book) => book.id == bookStore!.id,
    );
    book.currentRead = currentRead;
    book.lastRead = lastRead;

    await homeViewModel._bookDataSource.updateLastRead(
      id: bookStore!.id,
      currentRead: currentRead,
    );
  }

  Future<void> updateRatingandReview({int? rating, String? review}) async {
    if (bookStore == null) return;
    final book = homeViewModel.books.firstWhere(
      (book) => book.id == bookStore!.id,
    );
    if (rating != null) {
      book.rating = rating;
    }
    if (review != null || review!.isNotEmpty) {
      book.review = review;
    }

    await homeViewModel._bookDataSource.setRatingandReview(
      bookStore!.id,
      rating,
      review,
    );
  }

  Future<BookStore?> searchBookByServerId() async {
    if (bookSearchResult == null) return bookStore;
    return await homeViewModel._bookDataSource.searchBookByServerId(
      bookSearchResult!.id,
    );
  }

  Future<void> updateLikeStatus({required bool isLiked}) async {
    if (bookStore == null) return;
    await homeViewModel.updateLikeStatus(id: bookStore!.id, isLiked: isLiked);
  }
}
