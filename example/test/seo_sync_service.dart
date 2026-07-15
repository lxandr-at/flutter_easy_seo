import 'dart:io';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:http_parser/http_parser.dart'; // Required for setting explicit MediaType

class SEOSyncService {
  final apiKey = "changeme";
  final apiUrl = "https://localhost/api";
  final appName = "example";

  Future<void> _sendMultipart({
    required Uri url,
    required http.MultipartFile file,
    required Map<String, String> fields,
    required String context,
    bool forceIOClient = false,
  }) async {
    final request = http.MultipartRequest('POST', url);
    request.headers.addAll({
      'Accept': 'application/json',
      'X-API-Key': apiKey,
    });
    request.fields.addAll(fields);
    request.files.add(file);

    IOClient? ioClient;
    try {
      final http.StreamedResponse streamedResponse;

      if (forceIOClient) {
        // Create the base HttpClient
        final baseHttpClient = HttpClient();

        // Configure bad certificate bypass strictly for local environments
        if (kDebugMode) {
          baseHttpClient.badCertificateCallback =
              (X509Certificate cert, String host, int port) {
            final isLocal = host == 'localhost' ||
                host == '127.0.0.1' ||
                host.startsWith('10.0.2.'); // Android emulator fallback
            return isLocal;
          };
        }

        ioClient = IOClient(baseHttpClient);
        streamedResponse = await ioClient.send(request);
      } else {
        streamedResponse = await request.send();
      }

      final response = await http.Response.fromStream(streamedResponse);
      _logResponse(context, response);
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Network Error during $context: $e');
      }
      rethrow;
    } finally {
      ioClient?.close();
    }
  }

  Future<void> sendGeneratedData({
    required String html,
    required String path,
    bool forceIOClient = false,
  }) async {
    final url = Uri.parse('$apiUrl/generatedSEOPage');
    final file = http.MultipartFile.fromString(
      'file',
      html,
      filename: 'index.html',
      contentType: MediaType('text', 'html'),
    );
    await _sendMultipart(
      url: url,
      file: file,
      fields: {'path': path.isEmpty ? '/' : path, 'app_name': appName},
      context: 'SEO Sync',
      forceIOClient: forceIOClient,
    );
  }

  Future<void> sendSitemap({
    required String sitemapXmlContent,
    String filename = 'sitemap.xml',
    bool forceIOClient = false,
  }) async {
    final url = Uri.parse('$apiUrl/generatedSitemap');
    final file = http.MultipartFile.fromString(
      'file',
      sitemapXmlContent,
      filename: filename,
      contentType: MediaType('application', 'xml'),
    );
    await _sendMultipart(
      url: url,
      file: file,
      fields: {'app_name': appName},
      context: 'Sitemap Sync',
      forceIOClient: forceIOClient,
    );
  }

  /// Centralized logging helper for consistent response management
  void _logResponse(String context, http.Response response) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      if (kDebugMode) {
        print('✅ $context Successful: ${response.body}');
      }
    } else {
      if (kDebugMode) {
        print('❌ $context Failed: ${response.statusCode} - ${response.body}');
      }
      throw HttpException('$context failed with status code ${response.statusCode}');
    }
  }
}
