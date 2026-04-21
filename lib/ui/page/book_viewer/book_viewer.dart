import 'dart:io';
import 'dart:typed_data';
import 'package:alisbae/state_management/book/book_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:alisbae/model/book_store.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class BookViewer extends StatefulWidget {
  final BookStore bookStore;
  const BookViewer({required this.bookStore, super.key});

  @override
  State<BookViewer> createState() => _BookViewerState();
}

class _BookViewerState extends State<BookViewer> {
  final PdfViewerController _pdfViewerController = PdfViewerController();
  late final BookBloc _bookBloc;

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
  void initState() {
    _bookBloc = context.read<BookBloc>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.black
          : Colors.white60,
      body: SafeArea(
        child: Stack(
          children: [
            ColorFiltered(
              colorFilter: Theme.of(context).brightness == Brightness.dark
                  ? ColorFilter.matrix([
                      -1, 0, 0, 0, 255, // Red
                      0, -1, 0, 0, 255, // Green
                      0, 0, -1, 0, 255, // Blue
                      0, 0, 0, 1, 0, // Alpha
                    ])
                  : ColorFilter.matrix([
                      -1, 0, 0, 0, 255, // Red
                      0, -1, 0, 0, 255, // Green
                      0, 0, -1, 0, 255, // Blue
                      0, 0, 0, 1, 0, // Alpha
                    ]),
              child: SfPdfViewer.file(
                File(widget.bookStore.bookPath),
                enableDoubleTapZooming: true,
                pageSpacing: 0.5,
                enableDocumentLinkAnnotation: true,
                enableTextSelection: true,
                canShowScrollHead: true,
                canShowScrollStatus: true,
                enableHyperlinkNavigation: true,
                controller: _pdfViewerController,
                onPageChanged: (details) {
                  _bookBloc.add(
                    BookEvent.updateLastRead(
                      widget.bookStore.id!,
                      lastRead: DateTime.now(),
                      currentRead: details.newPageNumber,
                    ),
                  );
                },
                initialPageNumber: widget.bookStore.currentRead,
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildAnnotationRibbon(),
                  TextButton(
                    onPressed: !isSaveLoading ? _saveWithAnnotations : () {},

                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(Colors.black87),
                    ),
                    child: isSaveLoading
                        ? SizedBox(
                            height: 10,
                            child: CircularProgressIndicator(),
                          )
                        : Text("Save", style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnnotationRibbon() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.black
            : Colors.grey[200],
      ),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
      icon: Icon(icon),
      onPressed: () {
        // Toggle the annotation mode
        _pdfViewerController.annotationMode = mode;
      },
      tooltip: label,
    );
  }
}
