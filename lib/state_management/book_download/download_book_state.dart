part of 'download_book_bloc.dart';

sealed class DownloadBookState extends Equatable {
  const DownloadBookState();
  factory DownloadBookState.initial() => DownloadInitial();

  factory DownloadBookState.downloading(int count, int total) =>
      Downloading(count, total);

  factory DownloadBookState.success(BookStore bookStore) =>
      DownloadSuccess(bookStore);

  factory DownloadBookState.failed() => DownloadFailed();

  @override
  List<Object?> get props => [];
}

class DownloadInitial extends DownloadBookState {
  const DownloadInitial();

  @override
  List<Object?> get props => [];
}

class DeleteSuccess extends DownloadBookState {
  const DeleteSuccess();
}

final class AlreadyDownloaded extends DownloadBookState {
  final BookStore bookStore;

  const AlreadyDownloaded(this.bookStore);

  @override
  // TODO: implement props
  List<Object?> get props => [bookStore];
}

class Downloading extends DownloadBookState {
  final int count;
  final int total;
  const Downloading(this.count, this.total);

  @override
  List<Object?> get props => [count, total];
}

class DownloadSuccess extends DownloadBookState {
  final BookStore bookStore;
  const DownloadSuccess(this.bookStore);

  @override
  List<Object?> get props => [bookStore];
}

class DownloadFailed extends DownloadBookState {
  @override
  List<Object?> get props => [];
}
