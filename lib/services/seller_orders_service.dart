import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/seller_order_models.dart';
import 'api_http_client.dart';

class SellerOrdersService {
  const SellerOrdersService();

  Future<SellerOrderListResponse> fetchOrders({
    required String authToken,
    String? deliveryStatus,
    String? paymentStatus,
    String? orderCode,
    String? orderDate,
    String? perPage,
    int? page,
  }) async {
    final query = <String, String>{};
    if (deliveryStatus != null && deliveryStatus.trim().isNotEmpty) {
      query['delivery_status'] = deliveryStatus.trim();
    }
    if (paymentStatus != null && paymentStatus.trim().isNotEmpty) {
      query['payment_status'] = paymentStatus.trim();
    }
    if (orderCode != null && orderCode.trim().isNotEmpty) {
      query['order_code'] = orderCode.trim();
    }
    if (orderDate != null && orderDate.trim().isNotEmpty) {
      query['order_date'] = orderDate.trim();
    }
    if (perPage != null && perPage.trim().isNotEmpty) {
      query['per_page'] = perPage.trim();
    }
    if (page != null) {
      query['page'] = page.toString();
    }

    final uri = ApiConfig.uri('/v1/multivendor/seller-orders')
        .replace(queryParameters: query.isEmpty ? null : query);
    final response = await ApiHttpClient.get(uri, headers: _headers(authToken));
    final decoded = _decodeResponse(response);
    return SellerOrderListResponse.fromJson(decoded);
  }

  Future<SellerOrderCounters> fetchCounters({
    required String authToken,
  }) async {
    final response = await ApiHttpClient.get(
      ApiConfig.uri('/v1/multivendor/seller-orders/counters'),
      headers: _headers(authToken),
    );
    final decoded = _decodeResponse(response);
    return SellerOrderCounters.fromJson(decoded);
  }

  Future<SellerOrderDetails> fetchOrderDetails({
    required String authToken,
    required int orderId,
  }) async {
    final response = await ApiHttpClient.get(
      ApiConfig.uri('/v1/multivendor/seller-orders/$orderId'),
      headers: _headers(authToken),
    );
    final decoded = _decodeResponse(response);
    return SellerOrderDetails.fromJson(decoded);
  }

  Future<Map<String, dynamic>> updateOrderStatus({
    required String authToken,
    required int orderId,
    required List<int> productIds,
    required int deliveryStatus,
    required int paymentStatus,
    String? comment,
    Map<int, String>? tracking,
  }) async {
    final payload = <String, dynamic>{
      'product': productIds,
      'delivery_status': deliveryStatus,
      'payment_status': paymentStatus,
    };
    if (comment != null && comment.trim().isNotEmpty) {
      payload['comment'] = comment.trim();
    }
    if (tracking != null && tracking.isNotEmpty) {
      payload['tracking'] =
          tracking.map((key, value) => MapEntry(key.toString(), value));
    }

    final response = await ApiHttpClient.post(
      ApiConfig.uri('/v1/multivendor/seller-orders/$orderId/status'),
      headers: _headers(authToken),
      body: jsonEncode(payload),
    );
    return _decodeResponse(response);
  }

  Future<Map<String, dynamic>> acceptOrder({
    required String authToken,
    required int orderId,
  }) async {
    final response = await ApiHttpClient.post(
      ApiConfig.uri('/v1/multivendor/seller-orders/$orderId/accept'),
      headers: _headers(authToken),
    );
    return _decodeResponse(response);
  }

  Future<Map<String, dynamic>> cancelOrder({
    required String authToken,
    required int orderId,
  }) async {
    final response = await ApiHttpClient.post(
      ApiConfig.uri('/v1/multivendor/seller-orders/$orderId/cancel'),
      headers: _headers(authToken),
    );
    return _decodeResponse(response);
  }

  Future<Map<String, dynamic>> cancelOrderItem({
    required String authToken,
    required int orderId,
    required int itemId,
  }) async {
    final response = await ApiHttpClient.post(
      ApiConfig.uri(
        '/v1/multivendor/seller-orders/$orderId/items/$itemId/cancel',
      ),
      headers: _headers(authToken),
    );
    return _decodeResponse(response);
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
            debugPrint('SellerOrdersService error ($statusCode): $message');
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
          debugPrint('SellerOrdersService error ($statusCode): $message');
        }
        throw Exception(message);
      }
    }

    if (statusCode == 401) {
      throw Exception('Unauthenticated.');
    }

    debugPrint(
      'SellerOrdersService error ($statusCode): ${response.body}',
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
