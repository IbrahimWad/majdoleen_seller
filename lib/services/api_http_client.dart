import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';

class ApiHttpClient {
  ApiHttpClient._();

  static final http.Client _client = _LoggingClient(http.Client());

  static Future<http.Response> get(
    Uri url, {
    Map<String, String>? headers,
  }) {
    return _client.get(url, headers: headers);
  }

  static Future<http.Response> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) {
    return _client.post(url, headers: headers, body: body, encoding: encoding);
  }

  static Future<http.Response> delete(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) {
    return _client.delete(url, headers: headers, body: body, encoding: encoding);
  }

  static Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request);
  }
}

class _LoggingClient extends http.BaseClient {
  _LoggingClient(this._inner);

  final http.Client _inner;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    _applyDefaultHeaders(request);
    if (ApiConfig.logRequests) {
      _logRequest(request);
    }
    final startedAt = DateTime.now();
    final response = await _inner.send(request);
    if (ApiConfig.logRequests) {
      final elapsedMs =
          DateTime.now().difference(startedAt).inMilliseconds;
      debugPrint(
        '[API] <- ${response.statusCode} ${request.method} ${request.url} '
        '(${elapsedMs}ms)',
      );
    }
    return response;
  }

  void _applyDefaultHeaders(http.BaseRequest request) {
    if (!_hasHeader(request, 'User-Agent')) {
      request.headers['User-Agent'] = ApiConfig.userAgent;
    }
  }

  bool _hasHeader(http.BaseRequest request, String name) {
    final target = name.toLowerCase();
    for (final key in request.headers.keys) {
      if (key.toLowerCase() == target) {
        return true;
      }
    }
    return false;
  }

  void _logRequest(http.BaseRequest request) {
    debugPrint('[API] -> ${request.method} ${request.url}');
    final headers = _redactHeaders(request.headers);
    if (headers.isNotEmpty) {
      debugPrint('[API] headers: $headers');
    }
    if (request is http.Request) {
      final contentType = request.headers['Content-Type'];
      final body = _redactBody(request.body, contentType: contentType);
      if (body.isNotEmpty) {
        debugPrint('[API] body: ${_truncate(body, 1200)}');
      }
      return;
    }
    if (request is http.MultipartRequest) {
      if (request.fields.isNotEmpty) {
        debugPrint(
          '[API] fields: ${_redactFields(request.fields)}',
        );
      }
      if (request.files.isNotEmpty) {
        final files = request.files.map((file) {
          final name = file.filename ?? 'file';
          return '${file.field}($name, ${file.length} bytes)';
        }).join(', ');
        debugPrint('[API] files: $files');
      }
    }
  }

  Map<String, String> _redactHeaders(Map<String, String> headers) {
    final redacted = <String, String>{};
    headers.forEach((key, value) {
      if (key.toLowerCase() == 'authorization') {
        redacted[key] = '***';
      } else {
        redacted[key] = value;
      }
    });
    return redacted;
  }

  Map<String, String> _redactFields(Map<String, String> fields) {
    final redacted = <String, String>{};
    fields.forEach((key, value) {
      if (_isSensitiveKey(key)) {
        redacted[key] = '***';
      } else {
        redacted[key] = value;
      }
    });
    return redacted;
  }

  String _redactBody(String body, {String? contentType}) {
    final trimmed = body.trim();
    if (trimmed.isEmpty) return '';
    final type = contentType?.toLowerCase() ?? '';
    if (!type.contains('application/json')) {
      return trimmed;
    }
    try {
      final decoded = jsonDecode(trimmed);
      final redacted = _redactJson(decoded);
      return jsonEncode(redacted);
    } catch (_) {
      return trimmed;
    }
  }

  dynamic _redactJson(dynamic value) {
    if (value is Map) {
      final redacted = <String, dynamic>{};
      value.forEach((key, val) {
        final keyString = key.toString();
        if (_isSensitiveKey(keyString)) {
          redacted[keyString] = '***';
        } else {
          redacted[keyString] = _redactJson(val);
        }
      });
      return redacted;
    }
    if (value is List) {
      return value.map(_redactJson).toList();
    }
    return value;
  }

  bool _isSensitiveKey(String key) {
    final normalized = key.toLowerCase();
    return normalized == 'password' ||
        normalized == 'password_confirmation' ||
        normalized == 'token' ||
        normalized == 'access_token' ||
        normalized == 'refresh_token' ||
        normalized == 'otp' ||
        normalized == 'code' ||
        normalized == 'authorization';
  }

  String _truncate(String value, int maxLength) {
    if (value.length <= maxLength) return value;
    return '${value.substring(0, maxLength)}...';
  }
}
