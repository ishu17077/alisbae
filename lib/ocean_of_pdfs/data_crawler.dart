import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

class DataCrawler {
  final RegExp _bookDetailsMatch = RegExp(
    r'<script type="application\/ld\+json" class="yoast-schema-graph">([\s\S]*?)<\/script>',
  );
  final RegExp _fileNameMatch = RegExp(
    r'<input[^>]*name="filename"[^>]*value="([^"]+)"',
    caseSensitive: false,
  );

  CancelToken? _searchCancelToken;
  final Dio dio = Dio();

  Directory _dir;

  DataCrawler._createInstance(this._dir);

  static DataCrawler? _instance;

  factory DataCrawler(Directory _savePath) {
    _instance ??= DataCrawler._createInstance(_savePath);
    return _instance!;
  }

  Future<List<Map<String, dynamic>>> search({
    required String searchParam,
  }) async {
    final activeCancelToken = CancelToken();
    try {
      String apiUrl = "https://oceanofpdf.com/wp-admin/admin-ajax.php";
      final previousToken = _searchCancelToken;
      _searchCancelToken = activeCancelToken;
      previousToken?.cancel('Cancelled due to a newer search request.');
      Response res = await dio.post(
        apiUrl,
        data:
            "action=ajaxy_sf&sf_value=${Uri.encodeQueryComponent(searchParam)}&search=true",
        options: Options(
          headers: {"Content-Type": "application/x-www-form-urlencoded"},
        ),
        cancelToken: activeCancelToken,
      );

      // A newer search may have started while this request was in-flight.
      if (!identical(_searchCancelToken, activeCancelToken)) {
        return [];
      }

      var resp = jsonDecode(res.data)["post"][0]["all"];
      if (resp == null) {
        Fluttertoast.showToast(
          msg: "Please contact your personal unpaid developer. Wink.",
        );
      }
      return (resp as List)
          .map((resp) => resp as Map<String, dynamic>)
          .toList();
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) {
        return [];
      }
      debugPrint(e.toString());
      Fluttertoast.showToast(
        msg: "Please contact your personal unpaid developer. Wink. $e",
      );
      return [];
    } catch (e) {
      debugPrint(e.toString());
      Fluttertoast.showToast(
        msg: "Please contact your personal unpaid developer. Wink. $e",
      );
      return [];
    } finally {
      if (_searchCancelToken == activeCancelToken) {
        _searchCancelToken = null;
      }
    }
  }

  Future<Map<String, dynamic>> getBookInfo({required String bookUrl}) async {
    try {
      http.Response res = await http.get(Uri.parse(bookUrl));
      final bookData = _bookDetailsMatch.firstMatch(res.body)?.group(1);
      if (bookData == null || bookData.isEmpty) {
        Fluttertoast.showToast(
          msg: "Please contact your personal unpaid developer. Wink.",
        );
        return {};
      }
      final decoded = jsonDecode(bookData);
      decoded["fileName"] = _fileNameMatch.firstMatch(res.body)?.group(1);
      if (decoded["fileName"] == null ||
          (decoded["fileName"] as String).isEmpty) {
        Fluttertoast.showToast(
          msg: "Please contact your personal unpaid developer. Wink.",
        );
        return decoded as Map<String, dynamic>;
      }

      return decoded;
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Please contact your personal unpaid developer. Wink. $e",
      );
    }
    return {};
  }

  Future<String?> downloadBook({
    required String fileName,
    void Function(int count, int total)? callback,
  }) async {
    final apiUrl = "https://oceanofpdf.com/Fetching_Resource.php";
    late final String? downloadLink;
    Completer<void> pageLoadCompleter = Completer<void>();
    try {
      var headlessWebView = HeadlessInAppWebView(
        initialUrlRequest: URLRequest(
          url: WebUri(apiUrl),
          method: 'POST',
          body: Uint8List.fromList(utf8.encode("id=srv3&filename=$fileName")),
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'User-Agent': 'PostmanRuntime/7.53.0',
          },
        ),
        onDownloadStartRequest: (controller, downloadStartRequest) async {
          if (!pageLoadCompleter.isCompleted) {
            pageLoadCompleter.complete();
          }
          downloadLink = downloadStartRequest.url.toString();
        },
        onLoadStop: (controller, url) async {
          // await Future.delayed(Duration(seconds: 10));

          // String? renderedHtml = await controller.getHtml();
          // developer.log(renderedHtml ?? '');
          // if (renderedHtml != null) {
          //   final match = _downloadLinkMatch.firstMatch(renderedHtml);
          //   if (match != null) {
          //     downloadLink = match.group(1)!.replaceAll('&amp;', '&');
          //     debugPrint("Found Link: $downloadLink");
          //   }
          // }
        },
      );
      await headlessWebView.run();
      await pageLoadCompleter.future;
      var filePath = join(_dir.path, fileName);
      if (downloadLink == null || downloadLink!.isEmpty) {
        Fluttertoast.showToast(
          msg: "Please contact your personal unpaid developer. Wink.",
        );
        return null;
      }

      await dio.download(
        downloadLink!,
        filePath,
        onReceiveProgress: callback,
        deleteOnError: true,
        fileAccessMode: FileAccessMode.write,
      );

      if (downloadLink == null || downloadLink!.isEmpty) {
        Fluttertoast.showToast(
          msg: "Please contact your personal unpaid developer. Wink.",
        );
        return null;
      }

      return filePath;
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Please contact your personal unpaid developer. Wink. $e",
      );
    }
    return null;
  }

  Future<void> deleteDownload(String path) async {
    File file = File(path);
    if (await file.exists()) {
      await file.delete();
      debugPrint("File deleted successfully");
    }
  }
}
