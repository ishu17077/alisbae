import 'dart:io';

import 'package:alisbae/model/book_details.dart';
import 'package:alisbae/data/model/book_store.dart';
import 'package:alisbae/model/search_result.dart';
import 'package:alisbae/state_management/book/book_bloc.dart';
import 'package:alisbae/state_management/book_details/book_details_cubit.dart';
import 'package:alisbae/state_management/book_download/download_book_bloc.dart';
import 'package:alisbae/ui/page/home/home_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class BookDetailsPage extends StatefulWidget {
  final BookSearchResult bookSearchResult;
  // ignore: unused_field
  final IHomeRouter _router;
  final bool isDownloaded;
  const BookDetailsPage({
    required this.bookSearchResult,
    required this._router,
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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
                      bool isLiked = downloadBookState.bookStore.isFavorite;
                      if (state is BookLikeSuccess) {
                        isLiked = true;
                      }
                      if (state is BookDislikeSuccess) {
                        isLiked = false;
                      }
                      return IconButton(
                        icon: AnimatedScale(
                          scale: isLiked ? 1.2 : 1.0,
                          curve: Curves.easeOut,
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            isLiked ? Icons.favorite : Icons.favorite_outline,
                            color: isLiked
                                ? Colors.red
                                : Theme.of(context).brightness ==
                                      Brightness.light
                                ? Colors.black
                                : Colors.white,
                          ),
                        ),
                        onPressed: () {
                          _bookBloc.add(
                            isLiked
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
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          children: [
            BlocBuilder<BookDetailsCubit, BookDetailsState>(
              builder: (context, bookDetailsState) {
                if (bookDetailsState is BookDetailsInitial) {
                  return Center(child: CircularProgressIndicator());
                } else if (bookDetailsState is BookFoundError) {
                  return Center(
                    child: Text("The book cannot be found for some reason"),
                  );
                } else if (bookDetailsState is BookFoundOnline) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 20,
                    ),
                    child: _buildBookDetailsPage(
                      author: bookDetailsState.bookDetails.bookAuthor,
                      description: bookDetailsState.bookDetails.description,
                      title: widget.bookSearchResult.bookTitle,
                      datePublished: bookDetailsState.bookDetails.datePublished,
                      imagePath: null,
                      imageUrl: bookDetailsState.bookDetails.imageLink,
                      language: bookDetailsState.bookDetails.language,
                      onlineFileName: bookDetailsState.bookDetails.fileName,
                    ),
                  );
                } else if (bookDetailsState is BookFoundLocally) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 20,
                    ),
                    child: _buildBookDetailsPage(
                      author: bookDetailsState.bookStore.author,
                      description: bookDetailsState.bookStore.description ?? '',
                      title: bookDetailsState.bookStore.name,
                      datePublished: null,
                      bookStore: bookDetailsState.bookStore,
                      imagePath: bookDetailsState.bookStore.imagePath,
                      imageUrl: bookDetailsState.bookStore.imageUrl,
                      language: null,
                      onlineFileName: null,
                    ),
                  );
                } else {
                  return Center(
                    child: Text("Error while fetching for book item."),
                  );
                }
              },
            ),
            SizedBox(height: 100),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: BlocBuilder<DownloadBooksBloc, DownloadBookState>(
                builder: (context, downloadBookState) {
                  if (downloadBookState is AlreadyDownloaded) {
                    return _buildOpenBookButton(
                      onPressed: () {
                        widget._router.onShowBookViewerUi(
                          context,
                          downloadBookState.bookStore,
                        );
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            const SizedBox(width: 12),
            BlocBuilder<BookDetailsCubit, BookDetailsState>(
              builder: (context, bookDetailsState) {
                if (bookDetailsState is BookFoundOnline) {
                  return _buildDownloadButton(bookDetailsState);
                } else if (bookDetailsState is BookFoundLocally) {
                  return _buildDownloadButton(bookDetailsState);
                }
                return SizedBox();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDownloadButton(BookDetailsState bookDetailsState) {
    return BlocBuilder<DownloadBooksBloc, DownloadBookState>(
      builder: (context, state) {
        if (state is Downloading) {
          return FloatingActionButton(
            onPressed: () {},
            child: CircularProgressIndicator(
              value: state.count == 0 ? null : state.count / state.total,
            ),
          );
        }

        if (state is DownloadSuccess) {
          _downloadBooksBloc.add(
            DownloadBookEvent.initial(widget.bookSearchResult),
          );
          _bookDetailsCubit.bookInfo(bookUrl: widget.bookSearchResult.postLink);

          return FloatingActionButton(
            onPressed: () {},
            child: Icon(Icons.download_done),
          );
        }

        if (state is AlreadyDownloaded) {
          return FloatingActionButton(
            onPressed: () {
              _downloadBooksBloc.add(DownloadBookDelete(state.bookStore.id!));
              _bookDetailsCubit.bookInfo(
                bookUrl: widget.bookSearchResult.postLink,
              );
            },
            child: Icon(Icons.remove_shopping_cart),
          );
        }
        if (state is DeleteSuccess && bookDetailsState is BookFoundLocally) {
          return FloatingActionButton(
            onPressed: () {
              _downloadBooksBloc.add(
                DownloadBookEvent.downloadBook(
                  BookDetails(
                    bookAuthor: bookDetailsState.bookStore.author,
                    bookName: bookDetailsState.bookStore.name,
                    bookUrl: bookDetailsState.bookStore.serverUrl!,
                    datePublished: DateTime.now(),
                    description: bookDetailsState.bookStore.description ?? '',
                    fileName: "",
                    imageLink: "",
                    language: "",
                  ),
                  widget.bookSearchResult,
                ),
              );
              _bookDetailsCubit.bookInfo(
                bookUrl: bookDetailsState.bookStore.serverUrl!,
              );
            },
            child: Icon(Icons.download),
          );
        } else if (state is DeleteSuccess &&
            bookDetailsState is BookFoundOnline) {
          return FloatingActionButton(
            onPressed: () {
              _downloadBooksBloc.add(
                DownloadBookEvent.downloadBook(
                  bookDetailsState.bookDetails,
                  widget.bookSearchResult,
                ),
              );
              _bookDetailsCubit.bookInfo(
                bookUrl: bookDetailsState.bookDetails.bookUrl,
              );
            },
            child: Icon(Icons.download),
          );
        }
        if (bookDetailsState is BookFoundOnline) {
          return FloatingActionButton(
            onPressed: () {
              _downloadBooksBloc.add(
                DownloadBookEvent.downloadBook(
                  bookDetailsState.bookDetails,
                  widget.bookSearchResult,
                ),
              );
              _bookDetailsCubit.bookInfo(
                bookUrl: bookDetailsState.bookDetails.bookUrl,
              );
            },
            child: Icon(Icons.download),
          );
        } else if (bookDetailsState is BookFoundLocally) {
          return FloatingActionButton(
            onPressed: () {
              _downloadBooksBloc.add(
                DownloadBookEvent.downloadBook(
                  BookDetails(
                    bookAuthor: bookDetailsState.bookStore.author,
                    bookName: bookDetailsState.bookStore.name,
                    bookUrl: bookDetailsState.bookStore.serverUrl!,
                    datePublished: DateTime.now(),
                    description: bookDetailsState.bookStore.description ?? '',
                    fileName: "",
                    imageLink: "",
                    language: "",
                  ),
                  widget.bookSearchResult,
                ),
              );
              _bookDetailsCubit.bookInfo(
                bookUrl: bookDetailsState.bookStore.serverUrl!,
              );
            },
            child: Icon(Icons.download),
          );
        }
        return SizedBox();
      },
    );
  }

  Widget _buildBookDetailsPage({
    required String title,
    required String author,
    required String description,
    BookStore? bookStore,
    String? imageUrl,
    String? imagePath,
    DateTime? datePublished,
    String? language,
    String? onlineFileName,
  }) {
    int? rating;
    String? review;
    if (bookStore != null) {
      rating = bookStore.rating;
      review = bookStore.review;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: SizedBox(
            height: 220,
            child: imagePath != null
                ? Image.file(File(imagePath))
                : imageUrl != null
                ? Image.network(imageUrl)
                : SizedBox(),
          ),
        ),
        const SizedBox(height: 20),
        Text(title, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 12),
        _InfoText(label: 'Author', value: author),
        datePublished != null
            ? _InfoText(
                label: 'Published',
                value: datePublished.toIso8601String(),
              )
            : SizedBox(),
        language != null
            ? _InfoText(label: 'Language', value: language)
            : SizedBox(),
        onlineFileName != null
            ? _InfoText(
                label: 'File Name',
                value: onlineFileName.trim().isNotEmpty == true
                    ? onlineFileName
                    : 'N/A',
              )
            : _InfoText(label: 'File', value: 'Saved'),

        bookStore != null
            ? RatingBar.builder(
                initialRating: rating?.toDouble() ?? 0.0,
                minRating: 0.0,
                maxRating: 5.0,
                allowHalfRating: false,
                itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                onRatingUpdate: (rating) async {
                  final textEdittingController = TextEditingController();
                  textEdittingController.text = review ?? '';
                  await showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        actions: [
                          TextButton(
                            child: Text("Cancel"),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                          TextButton(
                            child: Text("OK"),
                            onPressed: () {
                              review = textEdittingController.text;
                              if (textEdittingController.text.isEmpty) {
                                review = null;
                              }

                              Navigator.pop(context);
                            },
                          ),
                        ],
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("Write your review?"),
                            SizedBox(height: 10),
                            TextField(
                              controller: textEdittingController,
                              maxLines: 5,
                              minLines: 5,
                            ),
                          ],
                        ),
                      );
                    },
                  );
                  setState(() {
                    review;
                  });
                  _bookBloc.add(
                    BookUpdateRatingandReview(
                      bookStore.id!,
                      rating: rating.toInt(),
                      review: review == null
                          ? null
                          : review!.isEmpty
                          ? null
                          : review,
                    ),
                  );
                },
                itemBuilder: (context, index) =>
                    const Icon(Icons.star, color: Colors.amber),
                itemCount: 5,
                itemSize: 30.0,
                direction: Axis.horizontal,
              )
            : SizedBox(),
        const SizedBox(height: 10),
        // Optional: Show the numeric value (e.g., 4.5)
        review != null
            ? Text(
                "Review: $review",
                style: Theme.of(context).textTheme.bodySmall,
                softWrap: true,
                maxLines: 10,
              )
            : SizedBox(),
        const SizedBox(height: 16),
        Text('Description', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(description),
      ],
    );
  }

  Widget _buildOpenBookButton({required VoidCallback onPressed}) {
    return FloatingActionButton.extended(
      heroTag: 'open-book-fab',
      onPressed: onPressed,
      elevation: 6,
      backgroundColor: const Color(0xFF0B6E4F),
      foregroundColor: Colors.white,
      icon: const Icon(Icons.auto_stories_rounded, size: 22),
      label: const Text(
        'Open Book',
        style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.3),
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
