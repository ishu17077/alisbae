import 'package:alisbae/data/model/book_store.dart';
import 'package:alisbae/data/model/folder_store.dart';
import 'package:alisbae/state_management/home/book_downloads_cubit.dart';
import 'package:alisbae/state_management/home/folder_cubit.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fluttertoast/fluttertoast.dart';

part './folder_management_event.dart';
part './folder_management_state.dart';

class FolderManagementBloc
    extends Bloc<FolderManagementEvent, FolderManagementState> {
  final FolderCubit _folderCubit;
  final BookDownloadsCubit _bookDownloadsCubit;

  FolderManagementBloc(this._folderCubit, this._bookDownloadsCubit)
    : super(FolderManagementInitial()) {
    assert(
      _folderCubit.homeViewModel == _bookDownloadsCubit.homeViewModel,
      "Home view model should stay same across both cubits",
    );

    on<FolderAddEvent>((event, emit) async {
      try {
        final folderStore = await _folderCubit.homeViewModel.createNewFolder(
          event.folder,
        );

        await _folderCubit.getFolders(
          parentFolderId: event.folder.parentFolderId,
        );

        await _bookDownloadsCubit.getBooks(
          folderId: event.folder.parentFolderId,
        );

        emit(FolderAddSuccess(folderStore));
      } catch (e) {
        Fluttertoast.showToast(msg: e.toString());
        emit(FolderOperationFailed());
      }
    });

    on<FolderDeleteEvent>((event, emit) async {
      try {
        await _folderCubit.homeViewModel.deleteFolder(event.folder.id);

        await _folderCubit.getFolders(
          parentFolderId: event.folder.parentFolderId,
        );

        await _bookDownloadsCubit.getBooks(
          folderId: event.folder.parentFolderId,
        );

        emit(FolderDeleteSuccess());
      } catch (e) {
        Fluttertoast.showToast(msg: e.toString());
        emit(FolderOperationFailed());
      }
    });

    on<ChangeBookFolder>((event, emit) async {
      try {
        await _folderCubit.homeViewModel.bookFolderChange(
          bookId: event.book.id,
          folderId: event.folderId,
        );
        _bookDownloadsCubit.getBooks(folderId: event.book.folderId);
        // _folderCubit.homeViewModel.listFolders(parentFolderId: event.folderId);
        emit(ChangeBookFolderSuccess());
      } catch (e) {
        Fluttertoast.showToast(msg: e.toString());
        emit(FolderOperationFailed());
      }
    });
  }
}
