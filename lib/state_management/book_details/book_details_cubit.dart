import 'package:alisbae/model/book_details.dart';
import 'package:alisbae/ocean_of_pdfs/data_crawler.dart';
import 'package:bloc/bloc.dart';

class BookDetailsCubit extends Cubit<BookDetails?> {
  final DataCrawler _dataCrawler;
  BookDetailsCubit(this._dataCrawler) : super(null);

  Future<void> bookInfo({required String bookUrl}) async {
    final data = await _dataCrawler.getBookInfo(bookUrl: bookUrl);
    emit(BookDetails.fromJson(data));
  }
}
