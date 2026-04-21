import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'dart:typed_data';
import 'package:brotli/brotli.dart';
import 'package:dio/dio.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class DataCrawler {
  final RegExp _bookDetailsMatch = RegExp(
    r'<script type="application\/ld\+json" class="yoast-schema-graph">([\s\S]*?)<\/script>',
  );
  final RegExp _fileNameMatch = RegExp(
    r'<input[^>]*name="filename"[^>]*value="([^"]+)"',
    caseSensitive: false,
  );

  final RegExp _downloadLinkMatch = RegExp(r'content="[^"]*url=([^"]+)"');
  final Dio dio = Dio();

  DataCrawler._createInstance(Directory dir);

  static DataCrawler? _instance;

  factory DataCrawler(Directory _savePath) {
    _instance ??= DataCrawler._createInstance(_savePath);
    return _instance!;
  }

  Future<List<Map<String, dynamic>>> search({
    required String searchParam,
  }) async {
    try {
      String apiUrl = "https://oceanofpdf.com/wp-admin/admin-ajax.php";
      http.Response res = await http.post(
        Uri.parse(apiUrl),
        body:
            "action=ajaxy_sf&sf_value=${Uri.encodeQueryComponent(searchParam)}&search=true",
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
      );
      var resp = jsonDecode(res.body)["post"][0]["all"];
      if (resp == null) {
        Fluttertoast.showToast(
          msg: "Please contact your personal unpaid developer. Wink.",
        );
      }
      return (resp as List)
          .map((resp) => resp as Map<String, dynamic>)
          .toList();
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Please contact your personal unpaid developer. Wink. $e",
      );
      return [];
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

  Future<Map<String, dynamic>> downloadBook({
    required String bookName,
    void Function(String progress)? callback,
  }) async {
    final apiUrl = "https://oceanofpdf.com/Fetching_Resource.php";
    late final String? downloadLink;
    try {
      var headlessWebView = HeadlessInAppWebView(
        initialUrlRequest: URLRequest(
          url: WebUri(apiUrl),
          method: 'POST',
          body: Uint8List.fromList(utf8.encode("id=srv3&filename=$bookName")),
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'User-Agent': 'PostmanRuntime/7.53.0',
          },
        ),
        onLoadStop: (controller, url) async {
          await Future.delayed(Duration(seconds: 1));

          String? renderedHtml = await controller.getHtml();
          developer.log(renderedHtml ?? '');
          if (renderedHtml != null) {
            final match = _downloadLinkMatch.firstMatch(renderedHtml);
            if (match != null) {
              downloadLink = match.group(1)!.replaceAll('&amp;', '&');

              debugPrint("Found Link: $downloadLink");
            }
          }
        },
      );
      await headlessWebView.run();

      if (downloadLink == null || downloadLink!.isEmpty) {
        Fluttertoast.showToast(
          msg: "Please contact your personal unpaid developer. Wink. $e",
        );
        return {}
      }
    } catch (e) {}
    return {};
  }
}
