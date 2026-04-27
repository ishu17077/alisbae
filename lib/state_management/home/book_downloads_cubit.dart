import 'package:alisbae/data/model/book_store.dart';
import 'package:alisbae/viewmodel/home/home_view_model.dart';
import 'package:bloc/bloc.dart';

class BookDownloadsCubit extends Cubit<List<BookStore>> {
  final HomeViewModel homeViewModel;

  BookDownloadsCubit(this.homeViewModel) : super([]);

  Future<void> getBooks() async {
    final books = await homeViewModel.listAllBooksOffline();
    emit([...books]);
  }
}
