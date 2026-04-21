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
  }) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      imageUrl = null;
    }
    this.addedOn = addedOn ?? DateTime.now();
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
    };
  }

  factory BookStore.fromJSON(Map<String, dynamic> map) {
    final bookStore = BookStore(
      name: map[BooksTable.bookName] as String,
      author: map[BooksTable.author] as String,
      bookPath: map[BooksTable.bookPath] as String,
      currentRead: map[BooksTable.currentRead] as int,
      addedOn: DateTime.fromMicrosecondsSinceEpoch(
        (map[BooksTable.addedOn] ?? 0),
      ),
      isFavorite: map[BooksTable.isFavorite] ?? 0 == 1 ? true : false,
      imageUrl: map[BooksTable.imageUrl],
      lastRead: map[BooksTable.lastRead] != null
          ? DateTime.fromMicrosecondsSinceEpoch(map[BooksTable.lastRead] as int)
          : null,
      serverId: map[BooksTable.serverId] != null
          ? map['serverId'] as int
          : null,
      serverUrl: map[BooksTable.serverUrl] != null
          ? map['serverUrl'] as String
          : null,
    );
    bookStore._id = map["id"] as int;
    return bookStore;
  }
}
