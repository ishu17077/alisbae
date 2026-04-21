import 'dart:io';

import 'package:alisbae/data/datasource/datasource_contract.dart';
import 'package:alisbae/data/datasource/sqflite_datasource_impl.dart';
import 'package:alisbae/data/factory/local_database_factory.dart';
import 'package:alisbae/model/search_result.dart';
import 'package:alisbae/state_management/book_details/book_details_cubit.dart';
import 'package:alisbae/state_management/home/book_downloads_cubit.dart';
import 'package:alisbae/ui/page/book_details/book_details_page.dart';
import 'package:alisbae/ui/page/home/home_router.dart';
import 'package:alisbae/ui/page/home/homepage.dart';
import 'package:alisbae/ocean_of_pdfs/data_crawler.dart';
import 'package:alisbae/state_management/home/search_cubit.dart';
import 'package:alisbae/viewmodel/book/book_view_mode.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';

class CompositionRoot {
  static late final DataCrawler _dataCrawler;
  static late final BookViewModel _bookViewModel;
  static late final IDataSource _dataSource;
  static late final IHomeRouter _homeRouter;
  static late final Directory _dir;
  static late final BookSearchCubit _bookSearchCubit;
  static late final BookDownloadsCubit _bookDownloadsCubit;
  static late final BookDetailsCubit _bookDetailsCubit;
  static Future<void> configure() async {
    _dir = await getApplicationDocumentsDirectory();
    _dataCrawler = DataCrawler(_dir);
    LocalDatabaseFactory localDatabaseFactory = LocalDatabaseFactory();
    _dataSource = SqfliteDatasourceImpl(
      await localDatabaseFactory.getDatabase(),
    );
    _bookViewModel = BookViewModel(_dataSource, _dataCrawler);
    _homeRouter = HomeRouter(showBookDetailsUi: showBookDetailsUi);
    _bookSearchCubit = BookSearchCubit(_bookViewModel);
    _bookDetailsCubit = BookDetailsCubit(_bookViewModel);
    _bookDownloadsCubit = BookDownloadsCubit(_bookViewModel);
  }

  static Widget composeHomeUi() {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => _bookSearchCubit),
        BlocProvider(create: (context) => _bookSearchCubit),
      ],
      child: HomePage(router: _homeRouter),
    );
  }

  static Widget showBookDetailsUi(BookSearchResult searchResult) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => _bookDetailsCubit),
        BlocProvider(create: (context) => _bookDownloadsCubit),
      ],
      child: BookDetailsPage(bookSearchResult: searchResult),
    );
  }
}
