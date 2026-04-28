import 'package:alisbae/data/model/book_store.dart';
import 'package:alisbae/data/model/folder_store.dart';
import 'package:alisbae/model/search_result.dart';
import 'package:flutter/material.dart';

abstract class IHomeRouter {
  Future<void> onShowBookDetailsUi(
    BuildContext context, {
    required bool isDownloaded,
    required BookStore? bookStore,
    required BookSearchResult? searchResult,
    FolderStore? currentFolder,
  });

  Future<void> onShowBookViewerUi(BuildContext context, BookStore bookStore);
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
  HomeRouter({required this.showBookDetailsUi, required this.showBookViewerUi});

  @override
  Future<void> onShowBookDetailsUi(
    BuildContext context, {
    required bool isDownloaded,
    required BookStore? bookStore,
    required BookSearchResult? searchResult,
    FolderStore? currentFolder,
  }) {
    return Navigator.push(
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
  Future<void> onShowBookViewerUi(BuildContext context, BookStore bookStore) {
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => showBookViewerUi(bookStore)),
    );
  }
}
