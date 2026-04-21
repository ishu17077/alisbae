part of 'download_book_bloc.dart';

sealed class DownloadBookEvent extends Equatable {
  const DownloadBookEvent();
  factory DownloadBookEvent.initial(BookSearchResult bookSearchResult) =>
      DownloadBookInitial(bookSearchResult);
  factory DownloadBookEvent.downloadBook(
    BookDetails bookDetails,
    BookSearchResult bookSearchResult,
  ) => DownloadStart(bookDetails, bookSearchResult);
}

class DownloadBookInitial extends DownloadBookEvent {
  final BookSearchResult bookSearchResult;

  const DownloadBookInitial(this.bookSearchResult);

  @override
  List<Object?> get props => [bookSearchResult];
}

class DownloadStart extends DownloadBookEvent {
  final BookDetails bookDetails;
  final BookSearchResult bookSearchResult;

  const DownloadStart(this.bookDetails, this.bookSearchResult);
  @override
  List<Object?> get props => [bookDetails.bookName, bookDetails.bookAuthor];
}
