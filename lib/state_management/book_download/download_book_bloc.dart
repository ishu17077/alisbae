import 'package:alisbae/model/book_details.dart';
import 'package:alisbae/model/book_store.dart';
import 'package:alisbae/model/search_result.dart';
import 'package:alisbae/viewmodel/book/book_view_mode.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/physics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'download_book_event.dart';
part 'download_book_state.dart';

class DownloadBooksBloc extends Bloc<DownloadBookEvent, DownloadBookState> {
  final BookViewModel _bookViewModel;
  DownloadBooksBloc(this._bookViewModel) : super(DownloadBookState.initial()) {
    on<DownloadBookInitial>((event, emit) async {
      final ifAlreadyPresent = await _bookViewModel.dataSource
          .searchBookByServerId(event.bookSearchResult.id);
      if (ifAlreadyPresent != null) {
        emit(AlreadyDownloaded(ifAlreadyPresent));
      }
    });

    on<DownloadStart>((event, emit) async {
      final result = await _bookViewModel.downloadBook(
        bookDetails: event.bookDetails,
        bookSearchResult: event.bookSearchResult,
        callback: (count, total) {
          emit(DownloadBookState.downloading(count, total));
        },
      );
      if (result == null) {
        emit(DownloadBookState.failed());
        return;
      }
      await _bookViewModel.listAllBooksOffline();
      emit(DownloadBookState.success(result));
    });
  }
}
