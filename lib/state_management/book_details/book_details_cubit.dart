import 'package:alisbae/model/book_details.dart';
import 'package:alisbae/data/model/book_store.dart';

import 'package:alisbae/viewmodel/home/home_view_model.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part './book_details_state.dart';

class BookDetailsCubit extends Cubit<BookDetailsState> {
  final BookViewModel _bookViewModel;
  BookDetailsCubit(this._bookViewModel) : super(BookDetailsInitial());

  Future<void> bookInfo() async {
    try {
      final book = await _bookViewModel.checkBookAlreadyDownloaded();
      if (book != null) {
        emit(BookFoundLocally(book));
        return;
      }
      final bookDetails = await _bookViewModel.getBookDetailsOnline();
      if (bookDetails != null) {
        emit(BookFoundOnline(bookDetails));
        return;
      }
      emit(BookFoundError());
    } catch (e) {
      emit(BookFoundError());
    }
  }
}
