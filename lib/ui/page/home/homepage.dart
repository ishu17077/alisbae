import 'dart:async';
import 'dart:io';

import 'package:alisbae/data/model/book_store.dart';
import 'package:alisbae/model/search_result.dart';
import 'package:alisbae/state_management/home/book_downloads_cubit.dart';
import 'package:alisbae/state_management/home/search_cubit.dart';
import 'package:alisbae/ui/page/home/home_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

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
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: CustomScrollView(
          physics: BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildTextField()),
            _buildSliverSearchResults(),
            SliverToBoxAdapter(child: SizedBox(height: 20)),
            BlocConsumer<BookDownloadsCubit, List<BookStore>>(
              listener: (context, bookStores) {
                if (bookStores.isNotEmpty) {
                  _warmUpImages(
                    bookStores.map((book) => book.imageUrl).whereType<String>(),
                  );
                }
              },
              builder: (context, downloadedBooks) {
                if (downloadedBooks.isEmpty) {
                  return SliverToBoxAdapter(child: SizedBox());
                }
                return SliverGrid.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                  ),
                  itemCount: downloadedBooks.length,
                  itemBuilder: (context, index) {
                    return _buildBookCard(
                      context,
                      downloadedBooks[index],
                      index,
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  TextField _buildTextField() {
    return TextField(
      controller: searchController,
      autofocus: false,
      decoration: InputDecoration(
        label: Text("What thy must demand?"),
        hint: Text("Procced!"),
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
    );
  }

  Widget _buildBookCard(BuildContext context, BookStore bookStore, int index) {
    bool isLiked = bookStore.isFavorite;
    return InkWell(
      onTap: () {
        widget._router.onShowBookDetailsUi(
          context,
          bookStore: bookStore,
          isDownloaded: true,
          searchResult: null,
        );
      },
      child: Card(
        elevation: 5.0,

        child: Padding(
          padding: const EdgeInsets.only(
            top: 0.0,
            left: 5.0,
            right: 5.0,
            bottom: 10.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () async {
                      await _bookDownloadsCubit.homeViewModel.deleteBook(
                        bookStore.id!,
                      );
                      _bookDownloadsCubit.getBooks();
                    },

                    icon: Icon(Icons.close),
                  ),
                  IconButton(
                    onPressed: () async {
                      setState(() {
                        isLiked = !isLiked;
                      });
                      _bookDownloadsCubit.homeViewModel.updateLikeStatus(
                        id: bookStore.id!,
                        isLiked: isLiked,
                      );
                    },
                    icon: AnimatedScale(
                      scale: isLiked ? 1.2 : 1.0,
                      curve: Curves.easeOut,
                      duration: const Duration(milliseconds: 200),
                      child: isLiked
                          ? Icon(Icons.favorite, color: Colors.red)
                          : Icon(Icons.favorite_outline),
                    ),
                  ),
                ],
              ),
              bookStore.imagePath != null && bookStore.imagePath!.isNotEmpty
                  ? Flexible(
                      flex: 2,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: _imageCover(
                          url: null,
                          path: bookStore.imagePath,
                          height: null,
                          width: 160,
                        ),
                      ),
                    )
                  : SizedBox(),
              Center(
                child: Text(
                  bookStore.name,
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Center(
                child: Text(
                  "Author: ${bookStore.author}",
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Center(
                child: Text(
                  "On page: ${bookStore.currentRead}",
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontSize: 10),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(height: 4),
              RatingBarIndicator(
                rating: bookStore.rating?.toDouble() ?? 0.0,
                itemBuilder: (context, index) =>
                    Icon(Icons.star, color: Colors.amber),
                itemCount: 5,
                itemSize: 12,
              ),
            ],
          ),
        ),
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

  void _warmUpImages(Iterable<String> pathOrUrls, {bool onDevice = false}) {
    for (var pathOrUrl in pathOrUrls) {
      final String pathUrl = pathOrUrl.trim();
      if (pathUrl.isEmpty || _warmedImageUrls.contains(pathUrl)) {
        continue;
      }
      _warmedImageUrls.add(pathUrl);
      unawaited(
        precacheImage(
          onDevice ? FileImage(File(pathUrl)) : NetworkImage(pathUrl),
          context,
        ),
      );
    }
  }

  Widget _imageCover({
    required String? url,
    required String? path,
    required double width,
    required double? height,
    BoxFit fit = BoxFit.fitHeight,
  }) {
    return Image(
      image: path != null ? FileImage(File(path)) : NetworkImage(url!),
      width: width,
      height: height,
      fit: fit,
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

  Widget _buildSliverSearchResults() {
    return BlocConsumer<BookSearchCubit, List<BookSearchResult>>(
      listener: (context, state) {
        if (state.isNotEmpty) {
          _warmUpImages(state.map((result) => result.postImage));
        }
      },
      builder: (context, searchResults) {
        if (searchController.text.trim() == "") {
          return SliverToBoxAdapter(child: SizedBox());
        }

        if (isLoading) {
          return SliverToBoxAdapter(
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (searchResults.isNotEmpty) {
          return SliverList.builder(
            itemBuilder: (context, index) {
              var searchResult = searchResults[index];
              return ListTile(
                onTap: () async {
                  widget._router.onShowBookDetailsUi(
                    context,
                    bookStore: null,
                    isDownloaded: false,
                    searchResult: searchResult,
                  );
                },
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: _imageCover(
                    url: searchResult.postImage,
                    path: null,
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

            itemCount: searchResults.length,
          );
        }
        return SliverToBoxAdapter(child: Text("Do search, please ;)"));
      },
    );
  }
}
