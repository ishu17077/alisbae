import 'package:alisbae/data/model/folder_store.dart';

abstract interface class IFolderDatasource {
  Future<int> addFolder(FolderStore folderStore);

  Future<void> deleteFolder(int id);

  Future<List<FolderStore>> listAllFolders({int? folderId});
}
