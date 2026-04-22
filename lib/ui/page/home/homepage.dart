import 'dart:async';

import 'package:alisbae/model/book_store.dart';
import 'package:alisbae/model/search_result.dart';
import 'package:alisbae/state_management/home/book_downloads_cubit.dart';
import 'package:alisbae/state_management/home/search_cubit.dart';
import 'package:alisbae/ui/page/home/home_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatefulWidget {
  final IHomeRouter _router;
  const HomePage({super.key, required this._router});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController searchController = TextEditingController();
  late final BookSearchCubit _searchCubit;
  late final BookDownloadsCubit _bookDownloadsCubit;
  final Set<String> _warmedImageUrls = <String>{};
  bool isLoading = false;
  @override
  void initState() {
    // TODO: implement initState
    _searchCubit = context.read<BookSearchCubit>();
    _bookDownloadsCubit = context.read<BookDownloadsCubit>();
    _bookDownloadsCubit.getBooks();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(title: Text("Search books :)")),
      body: BlocBuilder<BookSearchCubit, List<BookSearchResult>>(
        builder: (context, searchResults) {
          _warmUpImages(searchResults.map((result) => result.postImage));
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: [
                TextField(
                  controller: searchController,
                  autofocus: false,
                  decoration: InputDecoration(
                    label: Text("What thy must demand?"),
                    hint: Text("Procced!"),

                    //   labelStyle: Theme.of(context).textTheme.bodyMedium,
                    //   enabledBorder: OutlineInputBorder(
                    //     borderRadius: BorderRadius.circular(20),
                    //     borderSide: BorderSide(color: Colors.white, width: 2.5),
                    //   ),

                    //   focusedBorder: OutlineInputBorder(
                    //     borderRadius: BorderRadius.circular(20),
                    //     borderSide: BorderSide(width: 2.5),
                    //   ),
                    //   border: OutlineInputBorder(
                    //     borderRadius: BorderRadius.circular(20),
                    //     gapPadding: 5,
                    //     borderSide: BorderSide(
                    //       width: 2.5,
                    //       style: BorderStyle.solid,
                    //     ),
                    //   ),
                  ),
                  onChanged: (val) async {
                    val = val.trim();
                    if (val == "") {
                      setState(() {});
                      return;
                    }

                    setState(() {
                      isLoading = true;
                    });
                    _searchCubit.results(val).then((_) {
                      setState(() {
                        isLoading = false;
                      });
                    });
                  },
                ),
                SizedBox(height: 20),
                searchController.text.trim() == ""
                    ? Container(
                        // Here previous reads
                      )
                    : isLoading
                    ? Center(child: CircularProgressIndicator())
                    : searchResults.isNotEmpty
                    ? ListView.builder(
                        itemBuilder: (context, index) {
                          var searchResult = searchResults[index];
                          return ListTile(
                            onTap: () async {
                              widget._router.onShowBookDetailsUi(
                                context,
                                searchResult,
                              );
                            },
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: _networkCover(
                                url: searchResult.postImage,
                                width: 52,
                                height: 52,
                              ),
                            ),
                            title: Text(
                              searchResult.bookTitle,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            subtitle: Text(
                              searchResult.author,
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            trailing: SizedBox(
                              width: 30,
                              child: Text(
                                searchResult.postTitle,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          );
                        },
                        shrinkWrap: true,

                        itemCount: searchResults.length,
                      )
                    : Text("Do search, please ;)"),
                BlocBuilder<BookDownloadsCubit, List<BookStore>>(
                  builder: (context, bookStores) {
                    _warmUpImages(
                      bookStores
                          .map((book) => book.imageUrl)
                          .whereType<String>(),
                    );
                    if (bookStores.isEmpty) {
                      return SizedBox();
                    }
                    return Expanded(
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: BouncingScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                        ),
                        itemBuilder: (context, index) {
                          BookStore bookStore = bookStores[index];
                          return InkWell(
                            onTap: () {
                              widget._router.onShowBookViewerUi(
                                context,
                                bookStore,
                              );
                            },
                            child: Card(
                              elevation: 5.0,

                              child: Padding(
                                padding: const EdgeInsets.only(
                                  top: 0.0,
                                  left: 2.0,
                                  right: 2.0,
                                  bottom: 10.0,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        IconButton(
                                          onPressed: () async {
                                            await _bookDownloadsCubit
                                                .bookViewModel
                                                .deleteBook(bookStore.id!);
                                            _bookDownloadsCubit.getBooks();
                                          },
                                          icon: Icon(Icons.close),
                                        ),
                                        IconButton(
                                          onPressed: () async {
                                            await _bookDownloadsCubit
                                                .bookViewModel
                                                .updateLikeStatus(
                                                  id: bookStore.id!,
                                                  isLiked:
                                                      !bookStore.isFavorite,
                                                );
                                            _bookDownloadsCubit.getBooks();
                                          },
                                          icon: bookStore.isFavorite
                                              ? Icon(
                                                  Icons.favorite,
                                                  color: Colors.red,
                                                )
                                              : Icon(Icons.favorite_outline),
                                        ),
                                      ],
                                    ),
                                    bookStore.imageUrl != null
                                        ? Flexible(
                                            flex: 2,
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: _networkCover(
                                                url: bookStore.imageUrl!,
                                                height: null,
                                                width: 160,
                                              ),
                                            ),
                                          )
                                        : SizedBox(),
                                    Center(
                                      child: Text(
                                        bookStore.name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(fontSize: 14),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Center(
                                      child: Text(
                                        "Author: ${bookStore.author}",
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall
                                            ?.copyWith(fontSize: 12),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Center(
                                      child: Text(
                                        "On page: ${bookStore.currentRead}",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(fontSize: 10),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                        itemCount: bookStores.length,
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  void _warmUpImages(Iterable<String> urls) {
    for (final rawUrl in urls) {
      final String url = rawUrl.trim();
      if (url.isEmpty || _warmedImageUrls.contains(url)) {
        continue;
      }
      _warmedImageUrls.add(url);
      unawaited(precacheImage(NetworkImage(url), context));
    }
  }

  Widget _networkCover({
    required String url,
    required double width,
    required double? height,
    BoxFit fit = BoxFit.fitHeight,
  }) {
    final double dpr = MediaQuery.devicePixelRatioOf(context);
    return Image.network(
      url,
      width: width,
      height: height,
      fit: fit,
      cacheWidth: (width * dpr).round(),
      // cacheHeight: (height ?? 180 * dpr).round(),
      filterQuality: FilterQuality.low,
      gaplessPlayback: true,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }
        return SizedBox(
          width: width,
          height: height,
          child: const Center(
            child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return SizedBox(
          width: width,
          height: height,
          child: const Center(child: Icon(Icons.broken_image_outlined)),
        );
      },
    );
  }
}
