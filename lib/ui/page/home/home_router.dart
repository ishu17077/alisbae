import 'package:alisbae/data/model/book_store.dart';
import 'package:alisbae/model/search_result.dart';
import 'package:alisbae/state_management/home/book_downloads_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class IHomeRouter {
  Future<void> onShowBookDetailsUi(
    BuildContext context,
    BookSearchResult searchResult,
  );

  Future<void> onShowBookViewerUi(BuildContext context, BookStore bookStore);
}

final class HomeRouter implements IHomeRouter {
  final Widget Function(BookSearchResult searchResult) showBookDetailsUi;
  final Widget Function(BookStore bookStore) showBookViewerUi;
  HomeRouter({required this.showBookDetailsUi, required this.showBookViewerUi});

  @override
  Future<void> onShowBookDetailsUi(
    BuildContext context,
    BookSearchResult searchResult,
  ) {
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => showBookDetailsUi(searchResult)),
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
