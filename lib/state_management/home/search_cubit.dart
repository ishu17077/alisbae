import 'package:alisbae/model/search_result.dart';
import 'package:alisbae/ocean_of_pdfs/data_crawler.dart';
import 'package:alisbae/viewmodel/book/book_view_mode.dart';
import 'package:bloc/bloc.dart';

class SearchCubit extends Cubit<List<BookSearchResult>> {
  final BookViewModel bookViewModel;
  SearchCubit(this.bookViewModel) : super([]);

  Future<void> results(String search) async {
    final books = await bookViewModel.searchBooks(search);
    emit([...books]);
  }
}
