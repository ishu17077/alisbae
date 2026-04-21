import 'dart:io';

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
  @override
  Widget build(BuildContext context) {
    return SfPdfViewer.asset(
      widget.bookStore.bookPath,
      onPageChanged: (details) {},
      initialPageNumber: widget.bookStore.currentRead,
    );
  }
}
