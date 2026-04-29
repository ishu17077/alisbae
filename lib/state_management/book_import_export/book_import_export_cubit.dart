import 'package:alisbae/data/model/book_store.dart';
import 'package:alisbae/service/pdf_file/pdf_file.dart';
import 'package:alisbae/state_management/home/book_downloads_cubit.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';

part 'book_import_export_state.dart';

class BookImportExportCubit extends Cubit<BookImportExportState> {
  final BookDownloadsCubit _bookDownloadsCubit;
  BookImportExportCubit(this._bookDownloadsCubit)
    : super(BookImportExportInitial());

  Future<void> selectBook() async {
    try {
      final pdf = await _bookDownloadsCubit.homeViewModel.selectBook();
      if (pdf != null) {
        emit(BookSelected(pdf));
        return;
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> importBook(
    Pdf pdf, {
    required String bookName,
    required String author,
    int? folderId,
  }) async {
    try {
      final bookStore = await _bookDownloadsCubit.homeViewModel.importBook(
        bookName: bookName,
        author: author,
        pdf: pdf,
      );
      _bookDownloadsCubit.getBooks(folderId: folderId);
      emit(BookImportSuccess(bookStore));
    } catch (e) {
      Fluttertoast.showToast(msg: "Book Import failed, please try again.");
      debugPrint(e.toString());
      emit(BookImportExportFailed());
    }
  }

  Future<void> exportBook(BookStore bookStore) async {
    try {
      await _bookDownloadsCubit.homeViewModel.exportBook(bookStore: bookStore);
      emit(BookExportSuccess());
    } catch (e) {
      Fluttertoast.showToast(msg: "Book export failed, please try again.");
      debugPrint(e.toString());
      emit(BookImportExportFailed());
    }
  }
}
