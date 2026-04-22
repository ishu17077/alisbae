import 'package:alisbae/model/book_store.dart';
import 'package:alisbae/state_management/home/book_downloads_cubit.dart';
import 'package:alisbae/viewmodel/book/book_view_mode.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:alisbae/model/book_details.dart';
import 'package:alisbae/model/search_result.dart';

part 'book_event.dart';
part 'book_state.dart';

class BookBloc extends Bloc<BookEvent, BookState> {
  final BookViewModel bookViewModel;
  final BookDownloadsCubit bookDownloadsCubit;
  BookBloc(this.bookViewModel, this.bookDownloadsCubit) : super(BookInitial()) {
    on<LikeBook>((event, emit) async {
      try {
        await bookViewModel.updateLikeStatus(
          id: event.bookStoreId,
          isLiked: true,
        );

        await bookDownloadsCubit.getBooks();
        emit(BookLikeSuccess());
      } catch (e) {
        emit(BookUpdateFailed());
      }
    });

    on<DislikeBook>((event, emit) async {
      try {
        await bookViewModel.updateLikeStatus(
          id: event.bookStoreId,
          isLiked: false,
        );

        await bookDownloadsCubit.getBooks();
        emit(BookDislikeSuccess());
      } catch (e) {
        emit(BookUpdateFailed());
      }
    });

    on<BookUpdateLastRead>((event, emit) async {
      try {
        await bookViewModel.updateLastRead(
          id: event.bookStoreId,
          currentRead: event.currentRead,
          lastRead: DateTime.now(),
        );
        await bookDownloadsCubit.getBooks();
        emit(BookLastReadUpdateSuccess());
      } catch (e) {
        emit(BookUpdateFailed());
      }
    });
  }
}
