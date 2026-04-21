part of 'book_bloc.dart';

sealed class BookEvent extends Equatable {
  const BookEvent();
  factory BookEvent.likeBook(int bookStoreId) => LikeBook(bookStoreId);

  factory BookEvent.dislikeBook(int bookStoreId) => DislikeBook(bookStoreId);

  factory BookEvent.updateLastRead(
    int bookStoreId, {
    required DateTime lastRead,
    required int currentRead,
  }) =>
      BookUpdateLastRead(bookStoreId, currentRead: currentRead, lastRead: lastRead);

  @override
  List<Object?> get props => [];
}

final class LikeBook extends BookEvent {
  final int bookStoreId;
  const LikeBook(this.bookStoreId);
  @override
  // TODO: implement props
  List<Object?> get props => [bookStoreId];
}

final class DislikeBook extends BookEvent {
  final int bookStoreId;
  const DislikeBook(this.bookStoreId);
  @override
  // TODO: implement props
  List<Object?> get props => [bookStoreId];
}

final class BookUpdateLastRead extends BookEvent {
  final int bookStoreId;
  final DateTime lastRead;
  final int currentRead;
  const BookUpdateLastRead(
    this.bookStoreId, {
    required this.currentRead,
    required this.lastRead,
  });
  @override
  // TODO: implement props
  List<Object?> get props => [bookStoreId];
}
