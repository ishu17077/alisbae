import 'package:alisbae/model/book_store.dart';
import 'package:alisbae/viewmodel/book/book_view_mode.dart';
import 'package:bloc/bloc.dart';

class BookDownloadsCubit extends Cubit<List<BookStore>> {
  final BookViewModel bookViewModel;

  BookDownloadsCubit(this.bookViewModel) : super([]);

  Future<List<BookStore>> getBooks() async {
    final books = await bookViewModel.listAllBooksOffline();
    return books;
  }
}
