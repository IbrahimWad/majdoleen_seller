import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/seller_stats_models.dart';
import 'api_http_client.dart';

class SellerStatsService {
  const SellerStatsService();

  Future<SellerShopStats> fetchShopStats({
    required String authToken,
  }) async {
    final response = await ApiHttpClient.get(
      ApiConfig.uri('/v1/multivendor/seller-shop-stats'),
      headers: _headers(authToken),
    );
    final decoded = _decodeResponse(response);
    return SellerShopStats.fromJson(decoded);
  }

  Future<SellerStats> fetchSellerStats({
    required String authToken,
    String? range,
    String? from,
    String? to,
    String? timezone,
  }) async {
    final query = <String, String>{};
    if (range != null && range.trim().isNotEmpty) {
      query['range'] = range.trim();
    }
    if (from != null && from.trim().isNotEmpty) {
      query['from'] = from.trim();
    }
    if (to != null && to.trim().isNotEmpty) {
      query['to'] = to.trim();
    }
    if (timezone != null && timezone.trim().isNotEmpty) {
      query['timezone'] = timezone.trim();
    }

    final uri = ApiConfig.uri('/v1/multivendor/seller-stats')
        .replace(queryParameters: query.isEmpty ? null : query);
    final response = await ApiHttpClient.get(uri, headers: _headers(authToken));
    final decoded = _decodeResponse(response);
    return SellerStats.fromJson(decoded);
  }

  Map<String, String> _headers(String? authToken) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (authToken != null && authToken.isNotEmpty) {
      final normalized = _normalizeToken(authToken);
      if (normalized.isNotEmpty) {
        headers['Authorization'] = 'Bearer $normalized';
      }
    }
    return headers;
  }

  String _normalizeToken(String token) {
    var normalized = token.trim();
    if (normalized.toLowerCase().startsWith('bearer ')) {
      normalized = normalized.substring('bearer '.length).trim();
    }
    return normalized;
  }

  Map<String, dynamic> _decodeResponse(http.Response response) {
    final body = response.body.trim();
    final decoded = body.isEmpty ? null : jsonDecode(body);
    final statusCode = response.statusCode;

    if (statusCode >= 200 && statusCode < 300) {
      if (decoded is Map<String, dynamic>) {
        if (decoded['success'] == false) {
          final message = _extractMessage(decoded['message'] ?? decoded['error']);
          if (message != null && message.isNotEmpty) {
            debugPrint('SellerStatsService error ($statusCode): $message');
            throw Exception(message);
          }
        }
        return decoded;
      }
      return <String, dynamic>{'data': decoded};
    }

    if (decoded is Map<String, dynamic>) {
      final message = _extractMessage(decoded['message'] ?? decoded['error']);
      if (message != null && message.isNotEmpty) {
        if (statusCode != 401) {
          debugPrint('SellerStatsService error ($statusCode): $message');
        }
        throw Exception(message);
      }
    }

    if (statusCode == 401) {
      throw Exception('Unauthenticated.');
    }

    debugPrint(
      'SellerStatsService error ($statusCode): ${response.body}',
    );
    throw Exception('Request failed ($statusCode).');
  }

  String? _extractMessage(dynamic message) {
    if (message is String) {
      return message.trim().isEmpty ? null : message.trim();
    }
    if (message is List && message.isNotEmpty) {
      return _extractMessage(message.first);
    }
    if (message is Map) {
      for (final value in message.values) {
        final extracted = _extractMessage(value);
        if (extracted != null && extracted.isNotEmpty) {
          return extracted;
        }
      }
    }
    return null;
  }
}
