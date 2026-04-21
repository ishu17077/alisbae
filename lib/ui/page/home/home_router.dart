import 'package:alisbae/model/search_result.dart';
import 'package:flutter/material.dart';

abstract class IHomeRouter {
  Future<void> onShowBookDetailsUi(
    BuildContext context,
    SearchResult searchResult,
  );
}

final class HomeRouter implements IHomeRouter {
  final Widget Function(SearchResult searchResult) showBookDetailsUi;

  HomeRouter({required this.showBookDetailsUi});

  @override
  Future<void> onShowBookDetailsUi(
    BuildContext context,
    SearchResult searchResult,
  ) {
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => showBookDetailsUi(searchResult)),
    );
  }
}
