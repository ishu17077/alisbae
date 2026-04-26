import 'package:alisbae/model/book_details.dart';
import 'package:alisbae/data/model/book_store.dart';
import 'package:alisbae/viewmodel/book/book_view_mode.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part './book_details_state.dart';

class BookDetailsCubit extends Cubit<BookDetailsState> {
  final BookViewModel _bookViewModel;
  BookDetailsCubit(this._bookViewModel) : super(BookDetailsInitial());

  Future<void> bookInfo({required String bookUrl}) async {
    final book = _bookViewModel.books.firstWhere(
      (book) {
        if (book.serverUrl == null || book.serverUrl!.isEmpty) {
          return false;
        }
        return book.serverUrl!.replaceAll(RegExp(r'/$'), '') ==
            bookUrl.replaceAll(RegExp(r'/$'), '');
      },
      orElse: () =>
          BookStore(name: "", author: "", bookPath: "", imageUrl: null),
    );
    try {
      if (book.name.isNotEmpty &&
          book.author.isNotEmpty &&
          book.bookPath.isNotEmpty) {
        emit(BookFoundLocally(book));
        return;
      }
      final bookDetails = await _bookViewModel.getBookDetailsOnline(bookUrl);
      emit(BookFoundOnline(bookDetails));
    } catch (e) {
      emit(BookFoundError());
    }
  }
}
