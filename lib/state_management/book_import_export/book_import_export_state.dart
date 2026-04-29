part of 'book_import_export_cubit.dart';

sealed class BookImportExportState extends Equatable {
  const BookImportExportState();

  @override
  List<Object?> get props => [];
}

final class BookImportExportInitial extends BookImportExportState {}

final class BookSelected extends BookImportExportState {
  final Pdf pdf;

  const BookSelected(this.pdf);

  @override
  List<Object?> get props => [pdf];
}

// final class BookUnselect extends BookImportExportState {}

final class BookExportSuccess extends BookImportExportState {}

final class BookImportSuccess extends BookImportExportState {
  final BookStore bookStore;

  const BookImportSuccess(this.bookStore);

  @override
  List<Object?> get props => [bookStore];
}

final class BookImportExportFailed extends BookImportExportState {}
