import 'package:flutter/foundation.dart';

class ApiConfig {
  static const String _apiPath = '/api';
  static const String _defaultScheme = 'https';
  static const String _defaultHost = 'majdoleen-irq.com';
  static const String _defaultPort = '';
  static String? _languageCode;

  static String? get languageCode => _languageCode;

  static void setLanguageCode(String? code) {
    _languageCode = code?.trim().isEmpty ?? true ? null : code;
  }

  static String get baseUrl {
    const override = String.fromEnvironment('API_BASE_URL');
    if (override.isNotEmpty) {
      return override;
    }

    final portSegment = _defaultPort.isEmpty ? '' : ':$_defaultPort';
    return '$_defaultScheme://$_defaultHost$portSegment$_apiPath';
  }

  static String get rootUrl {
    if (baseUrl.endsWith(_apiPath)) {
      return baseUrl.substring(0, baseUrl.length - _apiPath.length);
    }
    return baseUrl;
  }

  static Uri uri(String path) {
    return Uri.parse('$baseUrl$path');
  }

  static String resolveMediaUrl(String? path) {
    if (path == null) return '';
    final trimmed = path.trim();
    if (trimmed.isEmpty) return '';
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      final uri = Uri.tryParse(trimmed);
      if (uri == null) return trimmed;
      final root = Uri.tryParse(rootUrl);
      final isSameHost = root != null && uri.host == root.host;
      if (!isSameHost) {
        return _normalizePublicPath(trimmed);
      }
      return _normalizePublicPath(_withPublicPrefix(uri).toString());
    }
    var normalized = trimmed.startsWith('/') ? trimmed : '/$trimmed';
    if (!normalized.startsWith('/public/') && normalized != '/public') {
      normalized = '/public$normalized';
    }
    return _normalizePublicPath('$rootUrl$normalized');
  }

  static Uri _withPublicPrefix(Uri uri) {
    final path = uri.path.startsWith('/') ? uri.path : '/${uri.path}';
    if (path == '/public' || path.startsWith('/public/')) {
      return uri;
    }
    return uri.replace(path: '/public$path');
  }

  static String _normalizePublicPath(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return url;
    final normalized = uri.path.replaceAll(RegExp(r'/{2,}'), '/');
    return uri.replace(path: normalized).toString();
  }

  static bool get logRequests {
    const override = String.fromEnvironment('API_LOGS');
    if (override.isNotEmpty) {
      return override.toLowerCase() == 'true';
    }
    return !kReleaseMode;
  }

  static String get userAgent {
    const override = String.fromEnvironment('API_USER_AGENT');
    if (override.isNotEmpty) {
      return override;
    }
    return 'MajdoleenSeller/1.0.0';
  }
}
