import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/seller_product_models.dart';
import 'api_http_client.dart';

class SellerProductsService {
  const SellerProductsService();

  Future<SellerProductOptions> fetchOptions({
    required String authToken,
  }) async {
    final response = await ApiHttpClient.get(
      ApiConfig.uri('/v1/multivendor/seller-products/options'),
      headers: _headers(authToken),
    );
    final decoded = _decodeResponse(response);
    final data = decoded['data'];
    if (data is Map<String, dynamic>) {
      return SellerProductOptions.fromJson(data);
    }
    return const SellerProductOptions();
  }

  Future<SellerProductListResponse> fetchProducts({
    required String authToken,
    String? searchKey,
    int? productStatus,
    int? hasVariation,
    int? discount,
    int? productFeatured,
    int? perPage,
    int? page,
  }) async {
    final query = <String, String>{};
    if (searchKey != null && searchKey.trim().isNotEmpty) {
      query['search_key'] = searchKey.trim();
    }
    if (productStatus != null) {
      query['product_status'] = productStatus.toString();
    }
    if (hasVariation != null) {
      query['has_variation'] = hasVariation.toString();
    }
    if (discount != null) {
      query['discount'] = discount.toString();
    }
    if (productFeatured != null) {
      query['product_featured'] = productFeatured.toString();
    }
    if (perPage != null) {
      query['per_page'] = perPage.toString();
    }
    if (page != null) {
      query['page'] = page.toString();
    }

    final uri = ApiConfig.uri('/v1/multivendor/seller-products')
        .replace(queryParameters: query.isEmpty ? null : query);
    final response = await ApiHttpClient.get(
      uri,
      headers: _headers(authToken),
    );
    final decoded = _decodeResponse(response);
    return SellerProductListResponse.fromJson(decoded);
  }

  Future<SellerProductDetails> fetchProductDetails({
    required String authToken,
    required int productId,
  }) async {
    final response = await ApiHttpClient.get(
      ApiConfig.uri('/v1/multivendor/seller-products/$productId'),
      headers: _headers(authToken),
    );
    final decoded = _decodeResponse(response);
    final data = decoded['data'];
    if (data is Map<String, dynamic>) {
      return SellerProductDetails.fromJson(data);
    }
    return SellerProductDetails.fromJson(decoded);
  }

  Future<SellerProductDetails> createProduct({
    required String authToken,
    required Map<String, dynamic> payload,
  }) async {
    final response = await ApiHttpClient.post(
      ApiConfig.uri('/v1/multivendor/seller-products'),
      headers: _headers(authToken),
      body: jsonEncode(payload),
    );
    final decoded = _decodeResponse(response);
    final data = decoded['data'];
    if (data is Map<String, dynamic>) {
      return SellerProductDetails.fromJson(data);
    }
    return SellerProductDetails.fromJson(decoded);
  }

  Future<SellerProductDetails> updateProduct({
    required String authToken,
    required int productId,
    required Map<String, dynamic> payload,
  }) async {
    final response = await ApiHttpClient.post(
      ApiConfig.uri('/v1/multivendor/seller-products/$productId'),
      headers: _headers(authToken),
      body: jsonEncode(payload),
    );
    final decoded = _decodeResponse(response);
    final data = decoded['data'];
    if (data is Map<String, dynamic>) {
      return SellerProductDetails.fromJson(data);
    }
    return SellerProductDetails.fromJson(decoded);
  }

  Future<void> deleteProduct({
    required String authToken,
    required int productId,
  }) async {
    final response = await ApiHttpClient.delete(
      ApiConfig.uri('/v1/multivendor/seller-products/$productId'),
      headers: _headers(authToken),
    );
    _decodeResponse(response);
  }

  Future<Map<String, dynamic>> updateStatus({
    required String authToken,
    required int productId,
    int? status,
  }) async {
    final payload = <String, dynamic>{};
    if (status != null) {
      payload['status'] = status;
    }
    final response = await ApiHttpClient.post(
      ApiConfig.uri('/v1/multivendor/seller-products/$productId/status'),
      headers: _headers(authToken),
      body: jsonEncode(payload),
    );
    return _decodeResponse(response);
  }

  Future<Map<String, dynamic>> updateDiscount({
    required String authToken,
    required int productId,
    required int discountAmountType,
    required double discountAmount,
  }) async {
    final response = await ApiHttpClient.post(
      ApiConfig.uri('/v1/multivendor/seller-products/$productId/discount'),
      headers: _headers(authToken),
      body: jsonEncode({
        'discount_amount_type': discountAmountType,
        'discount_amount': discountAmount,
      }),
    );
    return _decodeResponse(response);
  }

  Future<Map<String, dynamic>> updatePrice({
    required String authToken,
    required int productId,
    required int hasVariant,
    double? purchasePrice,
    double? unitPrice,
    List<Map<String, dynamic>> variations = const [],
  }) async {
    final payload = <String, dynamic>{
      'has_variant': hasVariant,
    };
    if (hasVariant == 1) {
      payload['variations'] = variations;
    } else {
      payload['purchase_price'] = purchasePrice ?? 0;
      payload['unit_price'] = unitPrice ?? 0;
    }
    final response = await ApiHttpClient.post(
      ApiConfig.uri('/v1/multivendor/seller-products/$productId/price'),
      headers: _headers(authToken),
      body: jsonEncode(payload),
    );
    return _decodeResponse(response);
  }

  Future<Map<String, dynamic>> updateStock({
    required String authToken,
    required int productId,
    required int hasVariant,
    int? quantity,
    List<Map<String, dynamic>> variations = const [],
  }) async {
    final payload = <String, dynamic>{
      'has_variant': hasVariant,
    };
    if (hasVariant == 1) {
      payload['variations'] = variations;
    } else {
      payload['quantity'] = quantity ?? 0;
    }
    final response = await ApiHttpClient.post(
      ApiConfig.uri('/v1/multivendor/seller-products/$productId/stock'),
      headers: _headers(authToken),
      body: jsonEncode(payload),
    );
    return _decodeResponse(response);
  }

  Future<SellerProductMediaUpload> uploadProductMedia({
    required String authToken,
    required File file,
    int? productId,
  }) async {
    final uploads = await uploadProductMediaBatch(
      authToken: authToken,
      files: [file],
      productId: productId,
    );
    if (uploads.isEmpty) {
      throw Exception('Product image upload failed.');
    }
    return uploads.first;
  }

  Future<List<SellerProductMediaUpload>> uploadProductMediaBatch({
    required String authToken,
    required List<File> files,
    int? productId,
  }) async {
    if (files.isEmpty) return const [];

    final request = http.MultipartRequest(
      'POST',
      ApiConfig.uri('/v1/multivendor/seller-products/media/upload'),
    );
    request.headers.addAll(_multipartHeaders(authToken));
    if (productId != null) {
      request.fields['product_id'] = productId.toString();
    }
    for (final file in files) {
      request.files.add(
        await http.MultipartFile.fromPath('file', file.path),
      );
    }

    final streamed = await ApiHttpClient.send(request);
    final response = await http.Response.fromStream(streamed);
    final decoded = _decodeResponse(response);

    final data = decoded['data'];
    if (data is List) {
      final uploads = data
          .whereType<Map>()
          .map(
            (entry) => SellerProductMediaUpload.fromJson(
              Map<String, dynamic>.from(entry),
            ),
          )
          .toList();
      if (uploads.isNotEmpty) {
        return uploads;
      }
    } else if (data is Map) {
      final upload = SellerProductMediaUpload.fromJson(
        Map<String, dynamic>.from(data),
      );
      if (upload.url.isNotEmpty || upload.fileId > 0) {
        return [upload];
      }
    }

    final fallback = SellerProductMediaUpload.fromJson(
      Map<String, dynamic>.from(decoded),
    );
    if (fallback.url.isNotEmpty || fallback.fileId > 0) {
      return [fallback];
    }

    return const [];
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

  Map<String, String> _multipartHeaders(String authToken) {
    return <String, String>{
      'Accept': 'application/json',
      if (authToken.isNotEmpty)
        'Authorization': 'Bearer ${_normalizeToken(authToken)}',
    };
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
            debugPrint(
              'SellerProductsService error ($statusCode): $message',
            );
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
          debugPrint(
            'SellerProductsService error ($statusCode): $message',
          );
        }
        throw Exception(message);
      }
    }

    if (statusCode == 401) {
      throw Exception('Unauthenticated.');
    }

    debugPrint(
      'SellerProductsService error ($statusCode): ${response.body}',
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

  int? _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim());
    return null;
  }
}
