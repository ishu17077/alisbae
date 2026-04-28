part of './folder_management_bloc.dart';

sealed class FolderManagementEvent extends Equatable {
  const FolderManagementEvent();
  factory FolderManagementEvent.addFolder(FolderStore folder) =>
      FolderAddEvent(folder);
  factory FolderManagementEvent.deleteFolder(FolderStore folder) =>
      FolderDeleteEvent(folder);

  factory FolderManagementEvent.changeBookFolder({
    required BookStore book,
    required int? folderId,
  }) => ChangeBookFolder(book: book, folderId: folderId);

  @override
  List<Object?> get props => [];
}

final class FolderDeleteEvent extends FolderManagementEvent {
  final FolderStore folder;
  const FolderDeleteEvent(this.folder);

  @override
  List<Object?> get props => [folder];
}

final class FolderAddEvent extends FolderManagementEvent {
  final FolderStore folder;
  const FolderAddEvent(this.folder);

  @override
  List<Object?> get props => [folder];
}

final class ChangeBookFolder extends FolderManagementEvent {
  final BookStore book;
  final int? folderId;

  const ChangeBookFolder({required this.book, required this.folderId});

  @override
  List<Object?> get props => [book, folderId];
}
