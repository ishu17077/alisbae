import 'package:alisbae/model/book_details.dart';
import 'package:alisbae/ocean_of_pdfs/data_crawler.dart';
import 'package:alisbae/viewmodel/book/book_view_mode.dart';
import 'package:bloc/bloc.dart';

class BookDetailsCubit extends Cubit<BookDetails?> {
  final BookViewModel _bookViewModel;
  BookDetailsCubit(this._bookViewModel) : super(null);

  Future<void> bookInfo({required String bookUrl}) async {
    final bookDetails = await _bookViewModel.getBookDetails(bookUrl);
    emit(bookDetails);
  }
}
