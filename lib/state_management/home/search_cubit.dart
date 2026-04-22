import 'package:alisbae/model/search_result.dart';
import 'package:alisbae/viewmodel/book/book_view_mode.dart';
import 'package:bloc/bloc.dart';

class BookSearchCubit extends Cubit<List<BookSearchResult>> {
  final BookViewModel bookViewModel;
  int _activeRequestId = 0;

  BookSearchCubit(this.bookViewModel) : super([]);

  Future<void> results(String search) async {
    final currentRequestId = ++_activeRequestId;
    final books = await bookViewModel.searchBooksOnline(search);

    if (currentRequestId != _activeRequestId) {
      return;
    }

    emit([...books]);
  }
}
