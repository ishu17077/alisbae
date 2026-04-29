import 'package:alisbae/model/search_result.dart';
import 'package:alisbae/viewmodel/home/home_view_model.dart';
import 'package:bloc/bloc.dart';

class BookSearchCubit extends Cubit<List<BookSearchResult>> {
  final HomeViewModel _homeViewModel;
  int _activeRequestId = 0;

  BookSearchCubit(this._homeViewModel) : super([]);

  Future<void> results(String search) async {
    if (search.isEmpty) {
      emit([]);
      return;
    }
    final currentRequestId = ++_activeRequestId;
    final books = await _homeViewModel.searchBooksOnline(search);

    if (currentRequestId != _activeRequestId) {
      return;
    }

    emit([...books]);
  }
}
