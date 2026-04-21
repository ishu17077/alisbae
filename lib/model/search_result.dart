class BookSearchResult {
  String postImage;
  int id;
  String postTitle;
  String postLink;
  String bookTitle;
  String author;

  BookSearchResult({
    required this.postImage,
    required this.id,
    required this.postTitle,
    required this.postLink,
    required this.bookTitle,
    required this.author,
  });

  factory BookSearchResult.fromJSON(Map<String, dynamic> map) {
    return BookSearchResult(
      postImage: map["post_image"],
      id: map["ID"],
      postTitle: map["post_title"],
      postLink: map["post_link"],
      author: map["custom_field_Author"],
      bookTitle: map["custom_field_BookTitle"],
    );
  }
}
