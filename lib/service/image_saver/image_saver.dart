import 'dart:io';
import 'dart:math';
import 'package:alisbae/service/common/get_file_name.dart';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;

class ImageSaver {
  Directory _dir;

  ImageSaver(this._dir);

  Future<String> saveImage(String imageUrl, String bookName) async {
    final uri = Uri.parse(imageUrl);
    http.Response res = await http.get(uri);

    String saveName = getSaveName(
      dir: _dir,
      bookName: bookName,
      fileName: uri.path,
    );

    File file = File(saveName);

    await file.writeAsBytes(res.bodyBytes);

    return file.path;
  }
}
