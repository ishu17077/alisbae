import 'package:alisbae/data/model/book_store.dart';
import 'package:alisbae/data/model/folder_store.dart';
import 'package:alisbae/model/search_result.dart';
import 'package:flutter/material.dart';

abstract class IHomeRouter {
  Future<T?> onShowBookDetailsUi<T>(
    BuildContext context, {
    required bool isDownloaded,
    required BookStore? bookStore,
    required BookSearchResult? searchResult,
    FolderStore? currentFolder,
  });

  Future<T?> onShowBookViewerUi<T>(BuildContext context, BookStore bookStore);

  Future<T?> onShowImportBookUi<T>(BuildContext context);

  
}

final class HomeRouter implements IHomeRouter {
  final Widget Function({
    required bool isDownloaded,
    required BookStore? bookStore,
    required BookSearchResult? searchResult,
    FolderStore? currentFolder,
  })
  showBookDetailsUi;
  final Widget Function(BookStore bookStore) showBookViewerUi;
  final Widget Function() showImportBookUi;
  HomeRouter({
    required this.showBookDetailsUi,
    required this.showBookViewerUi,
    required this.showImportBookUi,
  });

  @override
  Future<T?> onShowBookDetailsUi<T>(
    BuildContext context, {
    required bool isDownloaded,
    required BookStore? bookStore,
    required BookSearchResult? searchResult,
    FolderStore? currentFolder,
  }) {
    return Navigator.push<T>(
      context,
      MaterialPageRoute(
        builder: (context) => showBookDetailsUi(
          isDownloaded: isDownloaded,
          bookStore: bookStore,
          searchResult: searchResult,
          currentFolder: currentFolder,
        ),
      ),
    );
  }

  @override
  Future<T?> onShowBookViewerUi<T>(BuildContext context, BookStore bookStore) {
    return Navigator.push<T>(
      context,
      MaterialPageRoute(builder: (context) => showBookViewerUi(bookStore)),
    );
  }

  @override
  Future<T?> onShowImportBookUi<T>(BuildContext context) {
    return Navigator.push<T>(
      context,
      MaterialPageRoute(builder: (context) => showImportBookUi()),
    );
  }
}
