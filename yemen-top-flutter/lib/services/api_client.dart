import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

/// خطأ قادم من الـ API (مع رسالة عربية وأخطاء التحقق)
class ApiException implements Exception {
  final String message;
  final int statusCode;
  final Map<String, dynamic>? errors;
  ApiException(this.message, this.statusCode, [this.errors]);

  /// أول رسالة خطأ تحقق (إن وُجدت)
  String get firstError {
    if (errors != null && errors!.isNotEmpty) {
      final first = errors!.values.first;
      if (first is List && first.isNotEmpty) return first.first.toString();
    }
    return message;
  }

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  String? _token;
  String? get token => _token;
  bool get isAuthenticated => _token != null;

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
  }

  Future<void> setToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  Map<String, String> _headers({bool json = true}) => {
        'Accept': 'application/json',
        if (json) 'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    final base = '${ApiConfig.baseUrl}/$path';
    final uri = Uri.parse(base);
    if (query == null) return uri;
    return uri.replace(queryParameters: query.map((k, v) => MapEntry(k, '$v')));
  }

  Future<dynamic> get(String path, {Map<String, dynamic>? query}) async {
    final r = await http
        .get(_uri(path, query), headers: _headers())
        .timeout(ApiConfig.timeout);
    return _process(r);
  }

  Future<dynamic> post(String path, [Map<String, dynamic>? body]) async {
    final r = await http
        .post(_uri(path), headers: _headers(), body: jsonEncode(body ?? {}))
        .timeout(ApiConfig.timeout);
    return _process(r);
  }

  Future<dynamic> put(String path, [Map<String, dynamic>? body]) async {
    final r = await http
        .put(_uri(path), headers: _headers(), body: jsonEncode(body ?? {}))
        .timeout(ApiConfig.timeout);
    return _process(r);
  }

  Future<dynamic> delete(String path, [Map<String, dynamic>? body]) async {
    final r = await http
        .delete(_uri(path), headers: _headers(), body: jsonEncode(body ?? {}))
        .timeout(ApiConfig.timeout);
    return _process(r);
  }

  /// رفع نموذج مع ملف (إيصال)
  Future<dynamic> multipart(
    String path,
    Map<String, String> fields, {
    String? filePath,
    String fileField = 'receipt_image',
  }) async {
    final req = http.MultipartRequest('POST', _uri(path));
    req.headers.addAll(_headers(json: false));
    req.fields.addAll(fields);
    if (filePath != null) {
      req.files.add(await http.MultipartFile.fromPath(fileField, filePath));
    }
    final streamed = await req.send().timeout(ApiConfig.timeout);
    final r = await http.Response.fromStream(streamed);
    return _process(r);
  }

  dynamic _process(http.Response r) {
    dynamic body;
    try {
      body = r.body.isNotEmpty ? jsonDecode(r.body) : null;
    } catch (_) {
      body = null;
    }

    if (r.statusCode >= 200 && r.statusCode < 300) return body;

    final message = (body is Map && body['message'] != null)
        ? body['message'].toString()
        : 'حدث خطأ، حاول مرة أخرى.';
    final errors = (body is Map && body['errors'] is Map)
        ? Map<String, dynamic>.from(body['errors'])
        : null;

    throw ApiException(message, r.statusCode, errors);
  }
}
