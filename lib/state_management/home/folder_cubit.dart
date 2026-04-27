import 'package:alisbae/data/model/folder_store.dart';
import 'package:alisbae/viewmodel/home/home_view_model.dart';
import 'package:bloc/bloc.dart';

class FolderCubit extends Cubit<List<FolderStore>> {
  HomeViewModel homeViewModel;

  FolderCubit(this.homeViewModel) : super([]);

  Future<void> getFolders({int? parentFolderId}) async {
    final folders = await homeViewModel.listFolders(
      parentFolderId: parentFolderId,
    );
    emit([...folders]);
  }
}
