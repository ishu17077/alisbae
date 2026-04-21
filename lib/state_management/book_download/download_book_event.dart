part of 'download_book_bloc.dart';

sealed class DownloadBookEvent extends Equatable {
  const DownloadBookEvent();
  factory DownloadBookEvent.initial(BookSearchResult bookSearchResult) =>
      DownloadBookInitial(bookSearchResult);
  factory DownloadBookEvent.downloadBook(
    BookDetails bookDetails,
    BookSearchResult bookSearchResult,
  ) => DownloadBookStart(bookDetails, bookSearchResult);
}

class DownloadBookInitial extends DownloadBookEvent {
  final BookSearchResult bookSearchResult;

  const DownloadBookInitial(this.bookSearchResult);

  @override
  List<Object?> get props => [bookSearchResult];
}

class DownloadBookDelete extends DownloadBookEvent {
  final int id;

  const DownloadBookDelete(this.id);

  @override
  // TODO: implement props
  List<Object?> get props => [id];
}

class DownloadBookStart extends DownloadBookEvent {
  final BookDetails bookDetails;
  final BookSearchResult bookSearchResult;

  const DownloadBookStart(this.bookDetails, this.bookSearchResult);
  @override
  List<Object?> get props => [bookDetails.bookName, bookDetails.bookAuthor];
}
