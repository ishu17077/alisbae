part of 'download_book_bloc.dart';

sealed class DownloadBookEvent extends Equatable {
  const DownloadBookEvent();
  factory DownloadBookEvent.initial() => DownloadBookInitial();
  factory DownloadBookEvent.downloadBook() => DownloadBookStart();
}

class DownloadBookInitial extends DownloadBookEvent {
  const DownloadBookInitial();

  @override
  List<Object?> get props => [];
}

class DownloadBookDelete extends DownloadBookEvent {
  final int id;

  const DownloadBookDelete(this.id);

  @override
  // TODO: implement props
  List<Object?> get props => [id];
}

class DownloadBookStart extends DownloadBookEvent {
  

  const DownloadBookStart();
  @override
  List<Object?> get props => [];
}
