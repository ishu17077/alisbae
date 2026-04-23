// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:alisbae/data/constant/table_name.dart';

class BookStore {
  int? _id;
  int? get id => _id;
  String name;
  String author;
  String bookPath;
  int currentRead;
  late DateTime addedOn;
  bool isFavorite;
  DateTime? lastRead;
  int? serverId;
  String? imageUrl;
  String? serverUrl;
  int? rating;
  String? review;
  String? imagePath;
  String? description;

  BookStore({
    required this.name,
    required this.author,
    required this.bookPath,
    required this.imageUrl,
    this.currentRead = 1,
    this.isFavorite = false,
    this.lastRead,
    this.serverId,
    this.serverUrl,
    DateTime? addedOn,
    this.rating,
    this.review,
    this.imagePath,
    this.description,
  }) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      imageUrl = null;
    }
    this.addedOn = addedOn ?? DateTime.now();

    if (rating == null || rating == 0 || rating! < 0 || rating! > 5) {
      rating = null;
    }

    if (review == null || review!.isEmpty) {
      review = null;
    }
    if (imagePath == null || imagePath!.isEmpty) {
      imagePath = null;
    }
    if (description == null || description!.isEmpty) {
      imagePath = null;
    }
  }

  Map<String, dynamic> toJSON() {
    return <String, dynamic>{
      BooksTable.bookName: name,
      BooksTable.author: author,
      BooksTable.imageUrl: imageUrl,
      BooksTable.bookPath: bookPath,
      BooksTable.currentRead: currentRead,
      BooksTable.addedOn: addedOn.millisecondsSinceEpoch,
      BooksTable.isFavorite: isFavorite ? 1 : 0,
      BooksTable.lastRead: lastRead?.millisecondsSinceEpoch,
      BooksTable.serverId: serverId,
      BooksTable.serverUrl: serverUrl,
      BooksTable.imagePath: imagePath,
      BooksTable.description: description,
    };
  }

  factory BookStore.fromJSON(Map<String, dynamic> map) {
    final bookStore = BookStore(
      name: map[BooksTable.bookName] as String,
      author: map[BooksTable.author] as String,
      bookPath: map[BooksTable.bookPath] as String,
      currentRead: map[BooksTable.currentRead] as int,
      addedOn: DateTime.fromMillisecondsSinceEpoch(
        (map[BooksTable.addedOn]) ?? DateTime.now(),
      ),
      isFavorite: map[BooksTable.isFavorite] == null
          ? false
          : map[BooksTable.isFavorite] == 1
          ? true
          : false,
      imageUrl: map[BooksTable.imageUrl],
      lastRead: map[BooksTable.lastRead] != null
          ? DateTime.fromMillisecondsSinceEpoch(map[BooksTable.lastRead])
          : null,
      serverId: map[BooksTable.serverId] != null
          ? map[BooksTable.serverId] as int
          : null,
      serverUrl: map[BooksTable.serverUrl] != null
          ? map[BooksTable.serverUrl] as String
          : null,
      rating: map[BooksTable.rating] as int,
      review: map[BooksTable.review] as String,
      imagePath: map[BooksTable.imagePath],
      description: map[BooksTable.description],
    );
    bookStore._id = map["id"] as int;
    return bookStore;
  }
}
