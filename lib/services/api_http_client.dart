import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../config/api_config.dart';

class ApiHttpClient {
  ApiHttpClient._();

  static final Dio _dio = _buildDio();

  static Dio _buildDio() {
    final dio = Dio(
      BaseOptions(

        validateStatus: (_) => true,
        responseType: ResponseType.plain,
        headers: <String, dynamic>{
          'User-Agent': ApiConfig.userAgent,
        },
      ),
    );

    dio.interceptors.add(_DefaultHeadersInterceptor());

    if (ApiConfig.logRequests) {
      dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseHeader: false,
          responseBody: true,
          error: true,
          compact: true,
          maxWidth: 120,
          enabled: true,
          logPrint: (obj) {
            try {
              debugPrint(_sanitizePrettyLog(obj.toString()));
            } catch (e) {
              debugPrint(obj.toString());
              debugPrint('PrettyDioLogger sanitize failed: $e');
            }
          },
        ),
      );
    }

    return dio;
  }

  static Future<http.Response> get(
      Uri url, {
        Map<String, String>? headers,
      }) async {
    final res = await _dio.get<String>(
      url.toString(),
      options: Options(headers: headers),
    );
    return _toHttpResponse(
      res,
      method: 'GET',
      url: url,
      requestHeaders: headers,
    );
  }

  static Future<http.Response> post(
      Uri url, {
        Map<String, String>? headers,
        Object? body,
        Encoding? encoding,
      }) async {
    final prepared = _prepareBodyAndHeaders(
      headers: headers,
      body: body,
      encoding: encoding,
    );

    final res = await _dio.post<String>(
      url.toString(),
      data: prepared.data,
      options: prepared.options,
    );

    return _toHttpResponse(
      res,
      method: 'POST',
      url: url,
      requestHeaders: prepared.requestHeadersForHttp,
    );
  }

  static Future<http.Response> delete(
      Uri url, {
        Map<String, String>? headers,
        Object? body,
        Encoding? encoding,
      }) async {
    final prepared = _prepareBodyAndHeaders(
      headers: headers,
      body: body,
      encoding: encoding,
    );

    final res = await _dio.delete<String>(
      url.toString(),
      data: prepared.data,
      options: prepared.options,
    );

    return _toHttpResponse(
      res,
      method: 'DELETE',
      url: url,
      requestHeaders: prepared.requestHeadersForHttp,
    );
  }

  static Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final uri = request.url;
    final method = request.method;

    final reqHeaders = Map<String, String>.from(request.headers);
    _applyDefaultHeaders(reqHeaders);

    Object? data;
    if (request is http.Request) {
      data = request.bodyBytes;
    } else if (request is http.MultipartRequest) {
      data = await _multipartToFormData(request);
    }

    final res = await _dio.request<String>(
      uri.toString(),
      data: data,
      options: Options(
        method: method,
        headers: reqHeaders,
        responseType: ResponseType.plain,
        validateStatus: (_) => true,
        receiveDataWhenStatusError: true,
      ),
    );

    final flattenedHeaders = _flattenHeaders(res.headers.map);
    final statusCode = res.statusCode ?? 0;

    final bodyString = res.data ?? '';
    final bodyBytes = utf8.encode(bodyString);

    final isRedirect = statusCode >= 300 &&
        statusCode < 400 &&
        flattenedHeaders.keys.any((k) => k.toLowerCase() == 'location');

    return http.StreamedResponse(
      Stream<List<int>>.value(bodyBytes),
      statusCode,
      headers: flattenedHeaders,
      reasonPhrase: res.statusMessage,
      contentLength: bodyBytes.length,
      request: request,
      isRedirect: isRedirect,
    );
  }

}

class _DefaultHeadersInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers.putIfAbsent('User-Agent', () => ApiConfig.userAgent);
    handler.next(options);
  }
}

class _PreparedRequest {
  _PreparedRequest({
    required this.data,
    required this.options,
    required this.requestHeadersForHttp,
  });

  final Object? data;
  final Options options;


  final Map<String, String>? requestHeadersForHttp;
}

_PreparedRequest _prepareBodyAndHeaders({
  Map<String, String>? headers,
  Object? body,
  Encoding? encoding,
}) {
  final mergedHeaders = <String, String>{};
  if (headers != null) mergedHeaders.addAll(headers);

  Object? data = body;
  String? contentType;

  if (body is Map<String, String>) {

    contentType = mergedHeaders.entries
        .firstWhere(
          (e) => e.key.toLowerCase() == 'content-type',
      orElse: () => const MapEntry('', ''),
    )
        .value;

    if (contentType.isEmpty) {
      mergedHeaders['Content-Type'] =
      'application/x-www-form-urlencoded; charset=utf-8';
      contentType = mergedHeaders['Content-Type'];
    }

    data = body;
  } else if (body is String) {
    if (encoding != null && encoding != utf8) {
      data = Uint8List.fromList(encoding.encode(body));
    } else {
      data = body;
    }
  } else if (body is List<int>) {
    data = Uint8List.fromList(body);
  }

  _applyDefaultHeaders(mergedHeaders);

  final options = Options(
    headers: mergedHeaders,
    contentType: contentType,
    validateStatus: (_) => true,
    responseType: ResponseType.plain,
  );

  return _PreparedRequest(
    data: data,
    options: options,
    requestHeadersForHttp: mergedHeaders,
  );
}

void _applyDefaultHeaders(Map<String, String> headers) {
  final hasUserAgent = headers.keys.any((k) => k.toLowerCase() == 'user-agent');
  if (!hasUserAgent) {
    headers['User-Agent'] = ApiConfig.userAgent;
  }
}

Future<FormData> _multipartToFormData(http.MultipartRequest request) async {
  final form = FormData();

  request.fields.forEach((key, value) {
    form.fields.add(MapEntry(key, value));
  });

  for (final file in request.files) {
    final filename = file.filename ?? 'file';
    final ct = file.contentType;

    final mpFile = MultipartFile.fromStream(
          () => file.finalize(),
      file.length,
      filename: filename,
      contentType: ct == null ? null : MediaType(ct.type, ct.subtype),
    );

    form.files.add(MapEntry(file.field, mpFile));
  }

  return form;
}

http.Response _toHttpResponse(
    Response<dynamic> res, {
      required String method,
      required Uri url,
      Map<String, String>? requestHeaders,
    }) {
  final statusCode = res.statusCode ?? 0;

  final body = _extractBodyAsString(res.data);

  final headers = _flattenHeaders(res.headers.map);

  final req = http.Request(method, url);
  if (requestHeaders != null) {
    req.headers.addAll(requestHeaders);
  }

  return http.Response(
    body,
    statusCode,
    headers: headers,
    reasonPhrase: res.statusMessage,
    request: req,
  );
}

String _extractBodyAsString(dynamic data) {
  if (data == null) return '';
  if (data is String) return data;
  if (data is List<int>) return utf8.decode(data);
  try {
    return jsonEncode(data);
  } catch (_) {
    return data.toString();
  }
}

Map<String, String> _flattenHeaders(Map<String, List<String>> headers) {
  final out = <String, String>{};
  headers.forEach((key, values) {
    out[key] = values.join(', ');
  });
  return out;
}

String _sanitizePrettyLog(String input) {
  var out = input;

  // Authorization header
  out = out.replaceAllMapped(
    RegExp(
      r'^(\s*authorization\s*:\s*)(.+)$',
      multiLine: true,
      caseSensitive: false,
    ),
        (m) => '${m[1]}***',
  );


  out = out.replaceAllMapped(
    RegExp(
      r'^(\s*cookie\s*:\s*)(.+)$',
      multiLine: true,
      caseSensitive: false,
    ),
        (m) => '${m[1]}***',
  );

  // JSON keys
  out = out.replaceAllMapped(
    RegExp(
      r'"(password|password_confirmation|token|access_token|refresh_token|otp|code|authorization)"\s*:\s*"[^"]*"',
      caseSensitive: false,
    ),
        (m) => '"${m[1]}":"***"',
  );

  // simple key=value logs
  out = out.replaceAllMapped(
    RegExp(
      r'(password|password_confirmation|token|access_token|refresh_token|otp|code|authorization)\s*[:=]\s*[^\s,]+',
      caseSensitive: false,
    ),
        (m) => '${m[1]}: ***',
  );

  return out;
}
