import 'package:alisbae/model/search_result.dart';
import 'package:alisbae/ocean_of_pdfs/data_crawler.dart';
import 'package:bloc/bloc.dart';

class SearchCubit extends Cubit<List<SearchResult>> {
  final DataCrawler _dataCrawler;
  SearchCubit(this._dataCrawler) : super([]);

  Future<void> results(String search) async {
    final results = await _dataCrawler.search(searchParam: search);
    final searchResults = results
        .map((result) => SearchResult.fromJson(result))
        .toList();
    emit([...searchResults]);
  }
}
