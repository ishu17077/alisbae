// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class BookDetails {
  String bookName;
  String bookAuthor;
  String description;
  String datePublished;
  String imageLink;
  String language;
  String? fileName;
  BookDetails({
    required this.bookName,
    required this.bookAuthor,
    required this.description,
    required this.datePublished,
    required this.imageLink,
    required this.language,
    required this.fileName,
  });

  factory BookDetails.fromJson(Map<String, dynamic> map) {
    return BookDetails(
      bookName: map["@graph"][0]["headline"]
          .toString()
          .replaceFirst("[PDF] ", "")
          .replaceFirst("[EPUB]", ""),
      bookAuthor: map["@graph"][0]["author"]["name"] as String,
      description: map["@graph"][1]['description'] as String,
      datePublished: map["@graph"][1]['datePublished'] as String,
      imageLink: map["@graph"][0]['thumbnailUrl'] as String,
      language: map["@graph"][0]['inLanguage'] as String,
      fileName: map["fileName"] as String?,
    );
  }
}
