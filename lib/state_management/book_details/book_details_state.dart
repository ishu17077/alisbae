part of 'book_details_cubit.dart';

sealed class BookDetailsState extends Equatable {
  const BookDetailsState();
  @override
  List<Object?> get props => [];
}

final class BookDetailsInitial extends BookDetailsState {}

final class BookFoundLocally extends BookDetailsState {
  final BookStore bookStore;

  const BookFoundLocally(this.bookStore);
  @override
  // TODO: implement props
  List<Object?> get props => [bookStore];
}

final class BookFoundOnline extends BookDetailsState {
  final BookDetails bookDetails;

  const BookFoundOnline(this.bookDetails);
  @override
  List<Object?> get props => [bookDetails];
}

final class BookFoundError extends BookDetailsState {
  const BookFoundError();
}
