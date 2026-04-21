import 'package:alisbae/model/book_details.dart';
import 'package:alisbae/model/book_store.dart';
import 'package:alisbae/viewmodel/book/book_view_mode.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part './book_details_state.dart';

class BookDetailsCubit extends Cubit<BookDetailsState> {
  final BookViewModel _bookViewModel;
  BookDetailsCubit(this._bookViewModel) : super(BookInitial());

  Future<void> bookInfo({required String bookUrl}) async {
    try {
      final bookDetails = await _bookViewModel.getBookDetailsOnline(bookUrl);
      final book = _bookViewModel.books.firstWhere(
        (book) {
          if (book.serverUrl == null || book.serverUrl!.isEmpty) {
            return false;
          }
          return book.serverUrl!.replaceAll(RegExp(r'/$'), '') ==
              bookDetails.bookUrl.replaceAll(RegExp(r'/$'), '');
        },
        orElse: () =>
            BookStore(name: "", author: "", bookPath: "", imageUrl: null),
      );

      if (book.name.isEmpty && book.author.isEmpty && book.bookPath.isEmpty) {
        emit(BookFound(bookDetails, book));
        return;
      }
      emit(BookFound(bookDetails, null));
    } catch (e) {
      emit(BookFoundError());
    }
  }
}
