import 'package:fluttertoast/fluttertoast.dart';

class SearchResult {
  String postImage;
  int id;
  String postTitle;
  String postLink;
  String bookTitle;
  String author;

  SearchResult({
    required this.postImage,
    required this.id,
    required this.postTitle,
    required this.postLink,
    required this.bookTitle,
    required this.author,
  });

  factory SearchResult.fromJson(Map<String, dynamic> map) {
    return SearchResult(
      postImage: map["post_image"],
      id: map["ID"],
      postTitle: map["post_title"],
      postLink: map["post_link"],
      author: map["custom_field_Author"],
      bookTitle: map["custom_field_BookTitle"],
    );
  }
}
