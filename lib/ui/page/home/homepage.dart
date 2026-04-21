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

class _HomePageState extends State<HomePage> {
  final TextEditingController searchController = TextEditingController();
  late final BookSearchCubit _searchCubit;
  late final BookDownloadsCubit _bookDownloadsCubit;
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
    return Scaffold(
      appBar: AppBar(title: Text("Search books :)")),
      body: BlocBuilder<BookSearchCubit, List<BookSearchResult>>(
        builder: (context, searchResults) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
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
                              onTap: () => widget._router.onShowBookDetailsUi(
                                context,
                                searchResult,
                              ),
                              leading: Image.network(searchResult.postImage),
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
                      if (bookStores.isEmpty) {
                        return SizedBox();
                      }
                      return GridView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                        ),
                        itemBuilder: (context, index) {
                          BookStore bookStore = bookStores[index];
                          return Card(
                            elevation: 5.0,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10.0,
                                vertical: 2.0,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  bookStore.imageUrl != null
                                      ? Flexible(
                                          flex: 2,
                                          child: SizedBox(
                                            width: 350,
                                            child: bookStore.imageUrl != null
                                                ? Image.network(
                                                    bookStore.imageUrl!,
                                                  )
                                                : SizedBox(),
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
                          );
                        },
                        itemCount: bookStores.length,
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
