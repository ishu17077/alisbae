import 'package:alisbae/model/book_details.dart';
import 'package:alisbae/data/model/book_store.dart';
import 'package:alisbae/model/search_result.dart';
import 'package:alisbae/state_management/home/book_downloads_cubit.dart';

import 'package:alisbae/viewmodel/home/home_view_model.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'download_book_event.dart';
part 'download_book_state.dart';

class DownloadBooksBloc extends Bloc<DownloadBookEvent, DownloadBookState> {
  final BookViewModel bookViewModel;
  final BookDownloadsCubit _bookDownloadsCubit;
  DownloadBooksBloc(this.bookViewModel, this._bookDownloadsCubit)
    : super(DownloadBookState.initial()) {
    on<DownloadBookInitial>((event, emit) async {
      final ifAlreadyPresent = await bookViewModel.searchBookByServerId();
      if (ifAlreadyPresent != null) {
        emit(AlreadyDownloaded(ifAlreadyPresent));
      }
    });

    on<DownloadBookStart>((event, emit) async {
      emit(DownloadBookState.downloading(0, 100));
      final result = await bookViewModel.downloadBook(
        callback: (count, total) {
          emit(DownloadBookState.downloading(count, total));
        },
      );
      if (result == null) {
        emit(DownloadBookState.failed());
        return;
      }

      emit(DownloadBookState.success(result));
      await _bookDownloadsCubit.getBooks();
    });

    on<DownloadBookDelete>((event, emit) async {
      await bookViewModel.homeViewModel.deleteBook(event.id);

      emit(DeleteSuccess());
      await _bookDownloadsCubit.getBooks();
    });
  }
}
