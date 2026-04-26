import 'package:alisbae/data/model/book_store.dart';
import 'package:alisbae/viewmodel/book/book_view_mode.dart';
import 'package:bloc/bloc.dart';

class BookDownloadsCubit extends Cubit<List<BookStore>> {
  final BookViewModel bookViewModel;

  BookDownloadsCubit(this.bookViewModel) : super([]);

  Future<void> getBooks() async {
    final books = await bookViewModel.listAllBooksOffline();
    emit([...books]);
  }
}
