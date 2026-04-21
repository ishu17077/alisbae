import 'package:alisbae/model/book_store.dart';
import 'package:alisbae/viewmodel/book/book_view_mode.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'book_event.dart';
part 'book_state.dart';

class BookBloc extends Bloc<BookEvent, BookState> {
  final BookViewModel bookViewModel;
  BookBloc(this.bookViewModel) : super(BookInitial()) {
    on<LikeBook>((event, emit) async {
      try {
        await bookViewModel.dataSource.updateFavoriteStatus(
          id: event.bookStoreId,
          isFavorite: true,
        );

        await bookViewModel.listAllBooksOffline();
        emit(BookLikeSuccess());
      } catch (e) {
        emit(BookUpdateFailed());
      }
    });

    on<DislikeBook>((event, emit) async {
      try {
        await bookViewModel.dataSource.updateFavoriteStatus(
          id: event.bookStoreId,
          isFavorite: false,
        );
        await bookViewModel.listAllBooksOffline();
        emit(BookDislikeSuccess());
      } catch (e) {
        emit(BookUpdateFailed());
      }
    });

    on<BookUpdateLastRead>((event, emit) async {
      try {
        await bookViewModel.dataSource.updateLastRead(
          id: event.bookStoreId,
          currentRead: event.currentRead,
          lastRead: DateTime.now(),
        );
        await bookViewModel.listAllBooksOffline();
        emit(BookLastReadUpdateSuccess());
      } catch (e) {
        emit(BookUpdateFailed());
      }
    });
  }
}
