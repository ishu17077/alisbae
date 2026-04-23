import 'dart:io';
import 'dart:math';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;

class ImageSaver {
  Directory _dir;

  ImageSaver(this._dir);

  Future<String> saveImage(String imageUrl, String bookName) async {
    final uri = Uri.parse(imageUrl);
    http.Response res = await http.get(uri);

    String ext = extension(uri.path);
    if (ext.isEmpty) {
      ext = ".jpg";
    }
    String saveName = join(
      _dir.path,
      "${bookName}_${Random.secure().nextInt(8999999) + 1000000}$ext",
    );

    File file = File(saveName);

    await file.writeAsBytes(res.bodyBytes);

    return file.path;
  }
}
