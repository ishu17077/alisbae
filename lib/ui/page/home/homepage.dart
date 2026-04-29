import 'dart:async';
import 'dart:io';
import 'package:alisbae/data/model/book_store.dart';
import 'package:alisbae/data/model/folder_store.dart';
import 'package:alisbae/model/search_result.dart';
import 'package:alisbae/state_management/folder_management/folder_management_bloc.dart';
import 'package:alisbae/state_management/home/book_downloads_cubit.dart';
import 'package:alisbae/state_management/home/folder_cubit.dart';
import 'package:alisbae/state_management/home/search_cubit.dart';
import 'package:alisbae/ui/page/home/home_router.dart';
import 'package:alisbae/ui/widget/delete_alert_box.dart';
import 'package:alisbae/ui/widget/delete_folder_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class HomePage extends StatefulWidget {
  final IHomeRouter _router;
  const HomePage(this._router, {super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController searchController = TextEditingController();
  late final BookSearchCubit _searchCubit;
  late final BookDownloadsCubit _bookDownloadsCubit;
  late final FolderCubit _folderCubit;
  late final FolderManagementBloc _folderManagementBloc;
  final Set<String> _warmedImageUrls = <String>{};
  bool isLoading = false;
  @override
  void initState() {
    _folderManagementBloc = context.read<FolderManagementBloc>();
    _folderCubit = context.read<FolderCubit>();
    _searchCubit = context.read<BookSearchCubit>();
    _bookDownloadsCubit = context.read<BookDownloadsCubit>();
    _bookDownloadsCubit.getBooks();
    _folderCubit.getFolders();
    super.initState();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }
        _handleBackNavigation();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Search books :)"),
          actions: [
            OutlinedButton(
              onPressed: () {
                widget._router.onShowImportBookUi(context);
              },

              style: ButtonStyle(
                elevation: WidgetStatePropertyAll(3.0),
                padding: WidgetStatePropertyAll(
                  EdgeInsets.symmetric(horizontal: 15, vertical: 2),
                ),
                side: WidgetStatePropertyAll(
                  BorderSide(
                    color: Colors.blue,
                    style: BorderStyle.solid,
                    width: 3.2,
                  ),
                ),
              ),

              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Import Book", style: TextStyle(color: Colors.blue)),
                  SizedBox(width: 5),
                  Icon(Icons.add_circle_outline, color: Colors.blue),
                ],
              ),
            ),
            SizedBox(width: 10),
          ],
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: CustomScrollView(
            physics: BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _buildTextField()),
              _buildSliverSearchResults(),
              SliverToBoxAdapter(child: SizedBox(height: 20)),
              SliverAppBar(
                leading: _folderCubit.homeViewModel.currentFolder != null
                    ? BackButton(
                        onPressed: () async {
                          await _handleBackNavigation();
                        },
                      )
                    : SizedBox(),

                title: _folderCubit.homeViewModel.currentFolder?.name != null
                    ? Text(
                        _folderCubit.homeViewModel.currentFolder!.name,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color:
                              _folderCubit.homeViewModel.currentFolder?.color,
                        ),
                      )
                    : SizedBox(),
                actions: [
                  _folderCubit.homeViewModel.currentFolder != null
                      ? IconButton(
                          onPressed: () {
                            buildDeleteFolderAlertBox(
                              context,
                              _folderCubit.homeViewModel.currentFolder!,
                            ).then((shouldDelete) {
                              if (shouldDelete) {
                                _folderManagementBloc.add(
                                  FolderManagementEvent.deleteFolder(
                                    _folderCubit.homeViewModel.currentFolder!,
                                  ),
                                );
                                _handleBackNavigation();
                              }
                            });
                          },
                          icon: Icon(Icons.remove_circle, color: Colors.red),
                        )
                      : SizedBox(),
                  IconButton(
                    onPressed: () {
                      _buildFolderAddAlertDialog(
                        (folderStore) => _folderManagementBloc.add(
                          FolderManagementEvent.addFolder(folderStore),
                        ),
                      );
                    },
                    color: Colors.teal,
                    focusColor: Colors.teal,
                    hoverColor: Colors.teal,
                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(Colors.teal),
                    ),
                    icon: Padding(
                      padding: EdgeInsetsGeometry.symmetric(
                        horizontal: 3,
                        vertical: 0,
                      ),
                      child: Row(
                        children: [
                          Text(
                            "Add Folder ",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          Icon(
                            Icons.add_circle_outline_outlined,
                            color: Colors.white,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              BlocBuilder<FolderCubit, List<FolderStore>>(
                builder: (context, folders) {
                  if (folders.isEmpty) {
                    return SliverToBoxAdapter(child: SizedBox());
                  }
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsetsGeometry.only(left: 7),
                      child: Text(
                        "Folders",
                        textScaler: TextScaler.linear(2),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  );
                },
              ),
              BlocBuilder<FolderCubit, List<FolderStore>>(
                builder: (context, folders) {
                  if (folders.isEmpty) {
                    return SliverToBoxAdapter(child: SizedBox());
                  }

                  return SliverGrid.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 5,
                      crossAxisSpacing: 5,
                    ),
                    itemBuilder: (context, index) {
                      return _buildFolderCard(folders[index]);
                    },
                    itemCount: folders.length,
                  );
                },
              ),
              SliverToBoxAdapter(child: SizedBox(height: 20)),
              BlocConsumer<BookDownloadsCubit, List<BookStore>>(
                listener: (context, bookStores) {
                  if (bookStores.isNotEmpty) {
                    _warmUpImages(
                      bookStores
                          .map((book) => book.imageUrl)
                          .whereType<String>(),
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
                      return _buildBookCard(downloadedBooks[index], index);
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleBackNavigation() async {
    if (_folderCubit.homeViewModel.currentFolder == null) {
      SystemNavigator.pop();
    }
    await _bookDownloadsCubit.getBooks(
      folderId: _folderCubit.homeViewModel.currentFolder?.parentFolderId,
    );
    await _folderCubit.getFolders(
      parentFolderId: _folderCubit.homeViewModel.currentFolder?.parentFolderId,
    );
    setState(() {
      _folderCubit.homeViewModel.currentFolder;
    });
  }

  Widget _buildTextField() {
    return Padding(
      padding: EdgeInsetsGeometry.only(top: 5),
      child: TextField(
        controller: searchController,
        autofocus: false,
        decoration: InputDecoration(
          label: Text("What thy must demand?"),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
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
      ),
    );
  }

  void _buildFolderAddAlertDialog(
    Function(FolderStore folderStore) onFolderSaveClick,
  ) async {
    final folderStore = FolderStore(
      name: '',
      parentFolderId: _folderCubit.homeViewModel.currentFolder?.id,
    );

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Add Folder"),
              SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(
                  hint: Text("Folder Name", textScaler: TextScaler.linear(0.8)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    folderStore.name = value;
                  }
                },
              ),
              SizedBox(height: 5),
              _buildColorRow((Color color) {
                folderStore.color = color;
              }),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                if (folderStore.name.isNotEmpty) {
                  onFolderSaveClick(folderStore);
                  Navigator.pop(context);
                }
              },
              child: Text("Add"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildColorRow(Function(Color color) onColorSelected) {
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.purpleAccent,
      Colors.pink,
      Colors.cyan,
      Colors.teal,
    ];
    int selectedIndex = -1;
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int i = 0; i < colors.length; i++)
                IconButton(
                  onPressed: () {
                    setState(() {
                      selectedIndex = i;
                    });
                    onColorSelected(colors[i]);
                  },
                  icon: selectedIndex == i
                      ? Icon(Icons.check_circle, color: colors[i])
                      : Icon(Icons.circle, color: colors[i]),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFolderCard(FolderStore folder) {
    return InkWell(
      onTap: () {
        _handleForwardNavigation(folder);
      },
      child: Card(
        elevation: 10.0,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 5, vertical: 3),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.folder_open_outlined, color: folder.color),
              SizedBox(
                width: 100,
                child: Center(
                  child: Text(folder.name, overflow: TextOverflow.ellipsis),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleForwardNavigation(FolderStore folder) async {
    await _folderCubit.getFolders(parentFolderId: folder.id);
    await _bookDownloadsCubit.getBooks(folderId: folder.id);
    setState(() {
      _folderCubit.homeViewModel.currentFolder;
    });
  }

  Widget _buildBookCard(BookStore bookStore, int index) {
    bool isLiked = bookStore.isFavorite;
    return InkWell(
      onTap: () {
        searchController.clear();
        _searchCubit.results("");
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
                      buildDeleteBookAlertBox(context, bookStore).then((
                        shouldDelete,
                      ) async {
                        if (shouldDelete) {
                          await _bookDownloadsCubit.homeViewModel.deleteBook(
                            bookStore.id,
                          );
                          _bookDownloadsCubit.getBooks();
                        }
                      });
                    },
                    icon: Icon(Icons.close),
                  ),
                  IconButton(
                    onPressed: () async {
                      setState(() {
                        isLiked = !isLiked;
                      });
                      _bookDownloadsCubit.homeViewModel.updateLikeStatus(
                        id: bookStore.id,
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

  void _warmUpImages(Iterable<String> pathOrUrls, {bool onDevice = false}) {
    for (var pathOrUrl in pathOrUrls) {
      final String pathUrl = pathOrUrl.trim();
      if (pathUrl.isEmpty || _warmedImageUrls.contains(pathUrl)) {
        continue;
      }
      _warmedImageUrls.add(pathUrl);
      unawaited(
        precacheImage(
          onDevice
              ? FileImage(File(pathUrl)) as ImageProvider
              : NetworkImage(pathUrl),
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
    final ImageProvider<Object> imageProvider =
        (path != null && path.isNotEmpty)
        ? FileImage(File(path)) as ImageProvider
        : NetworkImage(url!);

    return Image(
      image: imageProvider,
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
                  final result = await widget._router.onShowBookDetailsUi(
                    context,
                    bookStore: null,
                    isDownloaded: false,
                    searchResult: searchResult,
                    currentFolder: _folderCubit.homeViewModel.currentFolder,
                  );
                  if (result ?? false) {
                    searchController.clear();
                    _searchCubit.results(searchController.text);
                  }
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
