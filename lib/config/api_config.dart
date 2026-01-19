import 'package:flutter/foundation.dart';

class ApiConfig {
  static const String _apiPath = '/api';
  static const String _defaultScheme = 'https';
  static const String _defaultHost = 'majdollen.com.levan-pms.com';
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
      return trimmed;
    }
    var normalized = trimmed.startsWith('/') ? trimmed : '/$trimmed';
    if (normalized.startsWith('/public/')) {
      normalized = normalized.substring('/public'.length);
    }
    return '$rootUrl$normalized';
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
    return 'PostmanRuntime/7.39.0';
  }
}
