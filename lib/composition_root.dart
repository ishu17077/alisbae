import 'dart:io';
import 'package:alisbae/data/datasource/book_datasource/book_datasource_contract.dart';
import 'package:alisbae/data/datasource/book_datasource/sqflite_book_datasource_impl.dart';
import 'package:alisbae/data/datasource/folder_datasource/folder_datasource_contract.dart';
import 'package:alisbae/data/datasource/folder_datasource/sqflite_folder_datasource_impl.dart';
import 'package:alisbae/data/factory/local_database_factory.dart';
import 'package:alisbae/data/model/book_store.dart';
import 'package:alisbae/model/search_result.dart';
import 'package:alisbae/service/image_saver/image_saver.dart';
import 'package:alisbae/state_management/book/book_bloc.dart';
import 'package:alisbae/state_management/book_details/book_details_cubit.dart';
import 'package:alisbae/state_management/book_download/download_book_bloc.dart';
import 'package:alisbae/state_management/home/book_downloads_cubit.dart';
import 'package:alisbae/state_management/home/folder_cubit.dart';
import 'package:alisbae/ui/page/book_details/book_details_page.dart';
import 'package:alisbae/ui/page/book_viewer/book_viewer.dart';
import 'package:alisbae/ui/page/home/home_router.dart';
import 'package:alisbae/ui/page/home/homepage.dart';
import 'package:alisbae/service/ocean_of_pdfs/data_crawler.dart';
import 'package:alisbae/state_management/home/search_cubit.dart';
import 'package:alisbae/viewmodel/home/home_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class CompositionRoot {
  static late final DataCrawler _dataCrawler;
  static late final IBookDataSource _bookDataSource;
  static late final IFolderDatasource _folderDatasource;
  static late final IHomeRouter _homeRouter;
  static late final Directory _dir;
  static late final BookSearchCubit _bookSearchCubit;
  static late final BookDownloadsCubit _bookDownloadsCubit;
  static late final FolderCubit _folderCubit;
  static late final ImageSaver _imageSaver;
  static late final HomeViewModel _homeViewModel;

  static Future<void> configure() async {
    _dir = await getApplicationDocumentsDirectory();
    final imageDir = await getApplicationDocumentsDirectory();
    _dataCrawler = DataCrawler(_dir);
    LocalDatabaseFactory localDatabaseFactory = LocalDatabaseFactory();
    final db = await localDatabaseFactory.getDatabase();
    _bookDataSource = SqfliteBookDatasourceImpl(db);
    _folderDatasource = SqfliteFolderDatasourceImpl(db);
    _imageSaver = ImageSaver(imageDir);
    _homeViewModel = HomeViewModel(
      _bookDataSource,
      _folderDatasource,
      _dataCrawler,
      _imageSaver,
    );
    _homeRouter = HomeRouter(
      showBookDetailsUi: showBookDetailsUi,
      showBookViewerUi: showBookViewerUi,
    );
    _folderCubit = FolderCubit(_homeViewModel);
    _bookDownloadsCubit = BookDownloadsCubit(_homeViewModel);
    _bookSearchCubit = BookSearchCubit(_homeViewModel);
  }

  static Widget composeHomeUi() {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => _folderCubit),
        BlocProvider(create: (context) => _bookSearchCubit),
        BlocProvider(create: (context) => _bookDownloadsCubit),
      ],
      child: HomePage(_homeRouter),
    );
  }

  static Widget showBookDetailsUi({
    required bool isDownloaded,
    required BookSearchResult? searchResult,
    required BookStore? bookStore,
  }) {
    final bookViewModel = BookViewModel(
      _homeViewModel,
      isDownloaded: isDownloaded,
      bookSearchResult: searchResult,
      bookStore: bookStore,
    );
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => BookDetailsCubit(bookViewModel)),
        BlocProvider(
          create: (context) =>
              DownloadBooksBloc(bookViewModel, _bookDownloadsCubit),
        ),
        BlocProvider(
          create: (context) => BookBloc(bookViewModel, _bookDownloadsCubit),
        ),
      ],
      child: BookDetailsPage(_homeRouter),
    );
  }

  static Widget showBookViewerUi(BookStore bookStore) {
    final bookViewModel = BookViewModel(
      _homeViewModel,
      isDownloaded: true,
      bookStore: bookStore,
      bookSearchResult: null,
    );
    return BlocProvider(
      create: (context) => BookBloc(bookViewModel, _bookDownloadsCubit),
      child: BookViewer(bookStore: bookStore),
    );
  }
}
