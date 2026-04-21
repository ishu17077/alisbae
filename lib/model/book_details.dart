class BookDetails {
  String bookName;
  String bookAuthor;
  String description;
  DateTime datePublished;
  String imageLink;
  String bookUrl;
  String language;
  String? fileName;
  BookDetails({
    required this.bookName,
    required this.bookAuthor,
    required this.description,
    required this.datePublished,
    required this.imageLink,
    required this.bookUrl,
    required this.language,
    required this.fileName,
  });

  factory BookDetails.fromJSON(Map<String, dynamic> map) {
    return BookDetails(
      bookName: map["@graph"][0]["headline"]
          .toString()
          .replaceFirst("[PDF] ", "")
          .replaceFirst("[EPUB]", ""),
      bookAuthor: map["@graph"][0]["author"]["name"] as String,
      description: map["@graph"][1]['description'] as String,
      datePublished:
          DateTime.tryParse(map["@graph"][1]['datePublished'] as String) ??
          DateTime.now(),
      imageLink: map["@graph"][0]['thumbnailUrl'] as String,
      language: map["@graph"][0]['inLanguage'] as String,
      bookUrl: map["@graph"][1]['@id'],
      fileName: map["fileName"] as String?,
    );
  }
}
