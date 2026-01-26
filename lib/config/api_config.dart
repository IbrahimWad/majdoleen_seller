import 'package:flutter/foundation.dart';

class ApiConfig {
  static const String _apiPath = '/api';
  static const String _defaultScheme = 'https';
  static const String _defaultHost = 'majdoleen-irq.com';
  // static const String _defaultHost = 'majdollen.com.levan-pms.com';
  static const String _defaultPort = '';

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
      return _normalizePublicPath(trimmed);
    }
    var normalized = trimmed.startsWith('/') ? trimmed : '/$trimmed';
    if (!normalized.startsWith('/public/')) {
      if (normalized.startsWith('/uploaded/') ||
          normalized.startsWith('/uploads/') ||
          normalized.startsWith('/storage/') ||
          normalized.startsWith('/image-sliders/')) {
        normalized = '/public$normalized';
      }
    }
    return _normalizePublicPath('$rootUrl$normalized');
  }

  static String _normalizePublicPath(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return url;
    final path = uri.path;
    if (path.startsWith('/public/')) {
      return url;
    }
    if (path.startsWith('/uploaded/') ||
        path.startsWith('/uploads/') ||
        path.startsWith('/storage/') ||
        path.startsWith('/image-sliders/')) {
      return uri.replace(path: '/public$path').toString();
    }
    return url;
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
