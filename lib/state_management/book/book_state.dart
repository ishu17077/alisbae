part of 'book_bloc.dart';

sealed class BookState extends Equatable {
  @override
  List<Object?> get props => [];
}

final class BookInitial extends BookState {}

final class BookLikeSuccess extends BookState {}

final class BookDislikeSuccess extends BookState {}

final class BookLastReadUpdateSuccess extends BookState {}

final class BookUpdateFailed extends BookState {}

final class BookRatingandReviewUpdateSuccess extends BookState {}
