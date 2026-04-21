import 'dart:io';

import 'package:alisbae/model/search_result.dart';
import 'package:alisbae/state_management/book_details/book_details_cubit.dart';
import 'package:alisbae/ui/page/book_details/book_details_page.dart';
import 'package:alisbae/ui/page/home/home_router.dart';
import 'package:alisbae/ui/page/home/homepage.dart';
import 'package:alisbae/ocean_of_pdfs/data_crawler.dart';
import 'package:alisbae/state_management/home/search_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';

class CompositionRoot {
  static late final DataCrawler _dataCrawler;
  static late final IHomeRouter _homeRouter;
  static late final Directory _dir;
  static Future<void> configure() async {
    _dir = await getApplicationDocumentsDirectory();
    _dataCrawler = DataCrawler(_dir);

    _homeRouter = HomeRouter(showBookDetailsUi: showBookDetailsUi);
  }

  static Widget composeHomeUi() {
    return BlocProvider(
      create: (context) => SearchCubit(_dataCrawler),
      child: HomePage(router: _homeRouter),
    );
  }

  static Widget showBookDetailsUi(BookSearchResult searchResult) {
    _dataCrawler.downloadBook(
      fileName: "Dex_Dutch_Edition_-_Hillers_Miranda.pdf",
    );
    return BlocProvider(
      create: (context) => BookDetailsCubit(_dataCrawler),
      child: BookDetailsPage(result: searchResult),
    );
  }
}
