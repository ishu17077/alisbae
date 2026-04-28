part of './folder_management_bloc.dart';

sealed class FolderManagementState extends Equatable {
  const FolderManagementState();
  factory FolderManagementState.folderAddSuccess(FolderStore folder) =>
      FolderAddSuccess(folder);

  factory FolderManagementState.folderDeleteSuccess() => FolderDeleteSuccess();

  @override
  List<Object?> get props => [];
}

final class FolderManagementInitial extends FolderManagementState {}

final class FolderDeleteSuccess extends FolderManagementState {}

final class FolderAddSuccess extends FolderManagementState {
  final FolderStore folder;

  const FolderAddSuccess(this.folder);

  @override
  List<Object?> get props => [folder];
}

final class ChangeBookFolderSuccess extends FolderManagementState {
  // final BookStore bookStore;

  const ChangeBookFolderSuccess();

  @override
  List<Object?> get props => [];
}

final class FolderOperationFailed extends FolderManagementState {}
