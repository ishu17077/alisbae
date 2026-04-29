import 'dart:io';
import 'dart:math';

import 'package:path/path.dart';

String getSaveName({
  required Directory dir,
  required String bookName,
  required String fileName,
}) {
  String ext = extension(fileName);
  String saveName = join(
    dir.path,
    "${bookName}_${Random.secure().nextInt(899) + 1000000}$ext",
  );
  return saveName;
}
