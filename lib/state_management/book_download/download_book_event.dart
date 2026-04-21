part of 'download_book_bloc.dart';


sealed class DownloadBookEvent extends Equatable {
  const DownloadBookEvent();

  factory DownloadBookEvent.downloadBook(BookDetails bookDetails, BookSearchResult bookSearchResult) => DownloadStart(bookDetails, bookSearchResult);
}

class DownloadStart extends DownloadBookEvent{
  final BookDetails bookDetails;
  final BookSearchResult bookSearchResult;

  const DownloadStart(this.bookDetails, this.bookSearchResult);
  @override
  List<Object?> get props => [bookDetails.bookName, bookDetails.bookAuthor];
}
