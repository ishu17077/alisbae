import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

class Pdf {
  String fileName;
  File file;

  Pdf(this.fileName, this.file);
}

class PdfFile {
  Future<Pdf?> importBook() async {
    FilePickerResult? result = await FilePicker.pickFiles(
      allowMultiple: false,
      allowedExtensions: ["pdf"],
      dialogTitle: "Select the book",
      type: FileType.custom,
    );
    if (result == null || result.files.first.path == null) {
      return null;
    }

    return Pdf(result.files.first.name, File(result.files.first.path!));
  }

  Future<bool> exportBook(Pdf pdf) async {
    Uint8List bytes = await pdf.file.readAsBytes();
    String? res = await FilePicker.saveFile(
      dialogTitle: "Save Book",
      allowedExtensions: ["pdf"],
      fileName: pdf.fileName,
      bytes: bytes,
    );
    if (res != null) {
      return true;
    }
    return false;
  }
}
