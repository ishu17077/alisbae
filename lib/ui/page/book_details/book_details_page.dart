import 'package:alisbae/model/book_details.dart';
import 'package:alisbae/model/search_result.dart';
import 'package:alisbae/state_management/book_details/book_details_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BookDetailsPage extends StatefulWidget {
  final SearchResult result;
  const BookDetailsPage({required this.result});

  @override
  State<BookDetailsPage> createState() => _BookDetailsPageState();
}

class _BookDetailsPageState extends State<BookDetailsPage> {
  @override
  void initState() {
    super.initState();
    context.read<BookDetailsCubit>().bookInfo(bookUrl: widget.result.postLink);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Book Info")),
      body: BlocBuilder<BookDetailsCubit, BookDetails?>(
        builder: (context, bookDetails) {
          if (bookDetails == null) {
            return Center(child: CircularProgressIndicator());
          }

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: SizedBox(
                      height: 220,
                      child: Image.network(bookDetails.imageLink),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    bookDetails.bookName,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  _InfoText(label: 'Author', value: bookDetails.bookAuthor),
                  _InfoText(
                    label: 'Published',
                    value: bookDetails.datePublished,
                  ),
                  _InfoText(label: 'Language', value: bookDetails.language),
                  _InfoText(
                    label: 'File Name',
                    value: bookDetails.fileName?.trim().isNotEmpty == true
                        ? bookDetails.fileName!
                        : 'N/A',
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(bookDetails.description),
                ],
              ),
            ),
          );
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
