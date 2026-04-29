import 'dart:io';
import 'package:alisbae/state_management/book/book_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:alisbae/data/model/book_store.dart';
import 'package:flutter/material.dart';
import 'package:async/async.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class BookViewer extends StatefulWidget {
  final BookStore bookStore;
  const BookViewer({required this.bookStore, super.key});

  @override
  State<BookViewer> createState() => _BookViewerState();
}

class _BookViewerState extends State<BookViewer> {
  final PdfViewerController _pdfViewerController = PdfViewerController();
  final GlobalKey<SfPdfViewerState> _pdfViewerKey =
      GlobalKey<SfPdfViewerState>();
  late final BookBloc _bookBloc;
  // late final AppLifecycleListener _listener;
  late bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
  bool _showToolbar = false;
  CancelableOperation? cancelableOperation;
  PdfTextSearchResult? _searchResult;

  bool isSaveLoading = false;
  void _saveWithAnnotations() async {
    setState(() {
      isSaveLoading = true;
    });
    final List<int> bytes = await _pdfViewerController.saveDocument();
    final file = File(widget.bookStore.bookPath);
    await file.writeAsBytes(bytes);
    setState(() {
      isSaveLoading = false;
    });
  }

  @override
  void dispose() {
    _searchResult?.clear();
    _bookBloc.add(
      BookEvent.updateLastRead(
        widget.bookStore.id,
        lastRead: DateTime.now(),
        currentRead: _pdfViewerController.pageNumber,
      ),
    );
    super.dispose();
  }

  @override
  void initState() {
    _bookBloc = context.read<BookBloc>();
    // _listener =
    AppLifecycleListener(
      onPause: () => BookEvent.updateLastRead(
        widget.bookStore.id,
        lastRead: DateTime.now(),
        currentRead: _pdfViewerController.pageNumber,
      ),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                widget.bookStore.name,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Switch(
              value: isDarkMode,
              thumbIcon: WidgetStateProperty.resolveWith<Icon>((states) {
                if (states.contains(WidgetState.selected)) {
                  return Icon(Icons.dark_mode);
                }
                return Icon(Icons.sunny);
              }),
              onChanged: (val) => {
                setState(() {
                  isDarkMode = val;
                }),
              },
            ),
          ],
        ),
      ),
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.black
          : Colors.white60,
      body: SafeArea(
        child: Stack(
          children: [
            SfPdfViewerTheme(
              data: SfPdfViewerThemeData(
                backgroundColor: isDarkMode ? Colors.white : Colors.black,
                bookmarkViewStyle: PdfBookmarkViewStyle(
                  backgroundColor: isDarkMode ? Colors.white : Colors.black,
                  headerBarColor: isDarkMode
                      ? Colors.grey.shade200
                      : Colors.grey.shade900,
                  closeIconColor: isDarkMode ? Colors.black : Colors.white,
                  backIconColor: isDarkMode ? Colors.black : Colors.white,
                  navigationIconColor: isDarkMode ? Colors.black : Colors.white,
                  selectionColor: isDarkMode
                      ? Colors.grey.shade300
                      : Colors.grey.shade800,
                  titleSeparatorColor: isDarkMode
                      ? Colors.grey.shade400
                      : Colors.grey.shade700,
                  titleTextStyle: TextStyle(
                    color: isDarkMode ? Colors.black : Colors.white,
                  ),
                  headerTextStyle: TextStyle(
                    color: isDarkMode ? Colors.black : Colors.white,
                  ),
                ),
              ),
              child: ColorFiltered(
                colorFilter: isDarkMode
                    ? ColorFilter.matrix([
                        -1, 0, 0, 0, 255, // Red
                        0, -1, 0, 0, 255, // Green
                        0, 0, -1, 0, 255, // Blue
                        0, 0, 0, 1, 0, // Alpha
                      ])
                    : ColorFilter.mode(Colors.black, BlendMode.difference),
                child: SfPdfViewer.file(
                  File(widget.bookStore.bookPath),
                  key: _pdfViewerKey,
                  enableDoubleTapZooming: true,
                  pageSpacing: 0.5,
                  enableDocumentLinkAnnotation: true,
                  scrollDirection: PdfScrollDirection.vertical,
                  pageLayoutMode: PdfPageLayoutMode.continuous,
                  enableTextSelection: true,
                  canShowScrollHead: true,
                  canShowScrollStatus: true,
                  enableHyperlinkNavigation: true,
                  controller: _pdfViewerController,
                  onTap: (details) {
                    if (cancelableOperation != null &&
                        !cancelableOperation!.isCanceled) {
                      cancelableOperation!.cancel();
                    }
                    setState(() {
                      _showToolbar = true;
                    });

                    cancelableOperation = CancelableOperation.fromFuture(
                      Future.delayed(const Duration(seconds: 5)).then((_) {
                        setState(() {
                          _showToolbar = false;
                        });
                      }),
                    );
                  },

                  onPageChanged: (details) {
                    widget.bookStore.currentRead = details.newPageNumber;
                  },
                  initialPageNumber: widget.bookStore.currentRead,
                ),
              ),
            ),
            _buildToolbar(),
          ],
        ),
      ),
    );
  }

  Widget _buildToolbar() {
    return Padding(
      padding: EdgeInsetsGeometry.symmetric(vertical: 10),
      child: ClipRRect(
        child: AnimatedSwitcher(
          duration: Duration(milliseconds: 500),
          transitionBuilder: (child, animation) {
            final offsetAnimation = Tween<Offset>(
              begin: const Offset(0.0, -1.0),
              end: const Offset(0.0, 0.0),
            ).animate(animation);

            return SlideTransition(position: offsetAnimation, child: child);
          },
          child: _showToolbar
              ? Align(
                  alignment: Alignment.topCenter,
                  child: Wrap(
                    key: UniqueKey(),
                    alignment: WrapAlignment.center,
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _buildToolbarAction(
                        icon: Icons.bookmark,
                        label: 'Bookmarks',
                        onPressed: _openBookmarks,
                      ),
                      _buildToolbarAction(
                        icon: Icons.search,
                        label: 'Search',
                        onPressed: _showSearchDialog,
                      ),
                      _buildAnnotationRibbon(),
                      _buildSaveButton(),
                    ],
                  ),
                )
              : SizedBox(key: UniqueKey()),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return TextButton(
      onPressed: !isSaveLoading ? _saveWithAnnotations : () {},
      style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.black)),
      child: isSaveLoading
          ? SizedBox(height: 10, child: CircularProgressIndicator())
          : Text("Save", style: TextStyle(color: Colors.red)),
    );
  }

  Widget _buildAnnotationRibbon() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.black
            : Colors.grey[200],
      ),

      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _ribbonButton(
            Icons.border_color,
            "Highlight",
            PdfAnnotationMode.highlight,
          ),
          _ribbonButton(
            Icons.format_underlined,
            "Underline",
            PdfAnnotationMode.underline,
          ),
          _ribbonButton(
            Icons.strikethrough_s,
            "Strike",
            PdfAnnotationMode.strikethrough,
          ),
          _ribbonButton(Icons.block, "None", PdfAnnotationMode.none),
        ],
      ),
    );
  }

  Widget _ribbonButton(IconData icon, String label, PdfAnnotationMode mode) {
    return IconButton(
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
      visualDensity: VisualDensity.compact,
      iconSize: 18,
      icon: Icon(icon),
      onPressed: () {
        _pdfViewerController.annotationMode = mode;
      },
      tooltip: label,
    );
  }

  Widget _buildToolbarAction({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Theme.of(context).brightness == Brightness.dark
          ? Colors.black
          : Colors.grey[200],
      borderRadius: BorderRadius.circular(20),
      child: IconButton(icon: Icon(icon), tooltip: label, onPressed: onPressed),
    );
  }

  void _openBookmarks() {
    _pdfViewerKey.currentState?.openBookmarkView();
  }

  Future<void> _showSearchDialog() async {
    String searchQuery = '';

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Search in book'),
          content: TextField(
            textInputAction: TextInputAction.search,
            decoration: const InputDecoration(hintText: 'Enter search text'),
            onChanged: (value) {
              searchQuery = value;
            },
            onSubmitted: (value) {
              _runSearch(value);
              Navigator.pop(dialogContext);
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                _searchResult?.clear();
                Navigator.pop(dialogContext);
              },
              child: const Text('Close'),
            ),
            TextButton(
              onPressed: () {
                final query = searchQuery.trim();
                if (query.isEmpty) {
                  return;
                }
                _runSearch(query);
                Navigator.pop(dialogContext);
              },
              child: const Text('Search'),
            ),
          ],
        );
      },
    );
  }

  void _runSearch(String query) {
    final text = query.trim();
    if (text.isEmpty) {
      return;
    }

    _searchResult?.clear();
    final searchResult = _pdfViewerController.searchText(text);
    setState(() {
      _searchResult = searchResult;
    });
  }
}
