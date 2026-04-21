import 'package:alisbae/model/book_details.dart';
import 'package:alisbae/model/search_result.dart';
import 'package:alisbae/state_management/book/book_bloc.dart';
import 'package:alisbae/state_management/book_details/book_details_cubit.dart';
import 'package:alisbae/state_management/book_download/download_book_bloc.dart';
import 'package:alisbae/state_management/home/book_downloads_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BookDetailsPage extends StatefulWidget {
  final BookSearchResult bookSearchResult;
  final bool isDownloaded;
  const BookDetailsPage({
    required this.bookSearchResult,
    this.isDownloaded = false,
  });

  @override
  State<BookDetailsPage> createState() => _BookDetailsPageState();
}

class _BookDetailsPageState extends State<BookDetailsPage> {
  late final DownloadBooksBloc _downloadBooksBloc;
  late final BookDetailsCubit _bookDetailsCubit;
  late final BookBloc _bookBloc;

  @override
  void initState() {
    super.initState();
    _bookDetailsCubit = context.read<BookDetailsCubit>();
    _downloadBooksBloc = context.read<DownloadBooksBloc>();
    _bookBloc = context.read<BookBloc>();
    _bookDetailsCubit.bookInfo(bookUrl: widget.bookSearchResult.postLink);
    _downloadBooksBloc.add(DownloadBookEvent.initial(widget.bookSearchResult));
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Book Info"),
            BlocBuilder<DownloadBooksBloc, DownloadBookState>(
              builder: (context, downloadBookState) {
                if (downloadBookState is AlreadyDownloaded) {
                  return BlocBuilder<BookBloc, BookState>(
                    builder: (context, state) {
                      if (state is BookLikeSuccess) {
                        downloadBookState.bookStore.isFavorite = true;
                      }
                      if (state is BookDislikeSuccess) {
                        downloadBookState.bookStore.isFavorite = false;
                      }
                      return IconButton(
                        icon: Icon(
                          downloadBookState.bookStore.isFavorite
                              ? Icons.favorite
                              : Icons.favorite_outline,
                          color: downloadBookState.bookStore.isFavorite
                              ? Colors.red
                              : Theme.of(context).brightness == Brightness.light
                              ? Colors.black
                              : Colors.white,
                        ),
                        onPressed: () {
                          _bookBloc.add(
                            downloadBookState.bookStore.isFavorite
                                ? BookEvent.dislikeBook(
                                    downloadBookState.bookStore.id!,
                                  )
                                : BookEvent.likeBook(
                                    downloadBookState.bookStore.id!,
                                  ),
                          );
                        },
                      );
                    },
                  );
                }
                return SizedBox();
              },
            ),
          ],
        ),
      ),
      body: BlocBuilder<BookDetailsCubit, BookDetailsState>(
        builder: (context, bookDetailsState) {
          if (bookDetailsState is BookDetailsInitial) {
            return Center(child: CircularProgressIndicator());
          } else if (bookDetailsState is BookFoundError) {
            return Center(
              child: Text("The book cannot be found for some reason"),
            );
          } else if (bookDetailsState is BookFound) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: SizedBox(
                        height: 220,
                        child: Image.network(
                          bookDetailsState.bookDetails.imageLink,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      widget.bookSearchResult.bookTitle,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 12),
                    _InfoText(
                      label: 'Author',
                      value: widget.bookSearchResult.author,
                    ),
                    _InfoText(
                      label: 'Published',
                      value: bookDetailsState.bookDetails.datePublished,
                    ),
                    _InfoText(
                      label: 'Language',
                      value: bookDetailsState.bookDetails.language,
                    ),
                    _InfoText(
                      label: 'File Name',
                      value:
                          bookDetailsState.bookDetails.fileName
                                  ?.trim()
                                  .isNotEmpty ==
                              true
                          ? bookDetailsState.bookDetails.fileName!
                          : 'N/A',
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Description',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(bookDetailsState.bookDetails.description),
                  ],
                ),
              ),
            );
          }
          return Center(child: Text("Uh! Oh! Do contact your unpaid dev."));
        },
      ),
      floatingActionButton: BlocBuilder<BookDetailsCubit, BookDetailsState>(
        builder: (context, bookDetailsState) {
          if (bookDetailsState is BookFound) {
            return BlocBuilder<DownloadBooksBloc, DownloadBookState>(
              builder: (context, state) {
                if (state is Downloading) {
                  return FloatingActionButton(
                    onPressed: () {},
                    child: CircularProgressIndicator(
                      value: state.count / state.total,
                    ),
                  );
                }

                if (state is DownloadSuccess) {
                  Future.delayed(Duration(seconds: 5)).then((value) {
                    _downloadBooksBloc.add(
                      DownloadBookEvent.initial(widget.bookSearchResult),
                    );
                  });
                  return FloatingActionButton(
                    onPressed: () {},
                    child: Icon(Icons.download_done),
                  );
                }

                if (state is AlreadyDownloaded) {
                  return FloatingActionButton(
                    onPressed: () {},
                    child: Icon(Icons.remove_shopping_cart),
                  );
                }
                return FloatingActionButton(
                  onPressed: () {
                    _downloadBooksBloc.add(
                      DownloadBookEvent.downloadBook(
                        bookDetailsState.bookDetails,
                        widget.bookSearchResult,
                      ),
                    );
                  },
                  child: Icon(Icons.download),
                );
              },
            );
          }
          return SizedBox();
        },
      ),
    );
  }
}

class _InfoText extends StatelessWidget {
  final String label;
  final String value;

  const _InfoText({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.bodyLarge,
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}
