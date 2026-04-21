part of 'book_details_cubit.dart';

sealed class BookDetailsState extends Equatable {
  const BookDetailsState();
  @override
  List<Object?> get props => [];
}

final class BookInitial extends BookDetailsState {}

final class BookFound extends BookDetailsState {
  final BookStore? bookStore;
  final BookDetails bookDetails;

  const BookFound(this.bookDetails, this.bookStore);
  @override
  // TODO: implement props
  List<Object?> get props => [bookStore, bookDetails];
}

final class BookFoundError extends BookDetailsState {}
