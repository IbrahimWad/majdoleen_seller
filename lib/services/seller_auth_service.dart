import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import 'api_http_client.dart';

class SellerAuthService {
  const SellerAuthService();

  Future<Map<String, dynamic>> registerSeller({
    required String email,
    required String name,
    required String password,
    required String passwordConfirmation,
    required String phone,
    required String shopName,
    required String shopPhone,
    String? address,
    double? latitude,
    double? longitude,
    String? authToken,
  }) async {
    final payload = <String, dynamic>{
      'email': email,
      'name': name,
      'password': password,
      'password_confirmation': passwordConfirmation,
      'phone': phone,
      'shop_name': shopName,
      'shop_phone': shopPhone,
    };

    if (address != null &&
        address.isNotEmpty &&
        latitude != null &&
        longitude != null) {
      payload.addAll({
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
      });
    }

    final response = await ApiHttpClient.post(
      ApiConfig.uri('/v1/multivendor/seller-registration'),
      headers: _headers(authToken),
      body: jsonEncode(payload),
    );

    return _decodeResponse(response);
  }

  Future<Map<String, dynamic>> sendOtp({
    required String phone,
    required String password,
    required String passwordConfirmation,
  }) async {
    final response = await ApiHttpClient.post(
      ApiConfig.uri('/seller/send-otp'),
      headers: _headers(null),
      body: jsonEncode({
        'phone': phone,
        'password': password,
        'password_confirmation': passwordConfirmation,
      }),
    );

    return _decodeResponse(response);
  }

  Future<Map<String, dynamic>> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    final response = await ApiHttpClient.post(
      ApiConfig.uri('/seller/verify-otp'),
      headers: _headers(null),
      body: jsonEncode({
        'phone': phone,
        'otp': otp,
      }),
    );

    return _decodeResponse(response);
  }

  Future<Map<String, dynamic>> sendForgotPasswordOtp({
    required String phone,
  }) async {
    final response = await ApiHttpClient.post(
      ApiConfig.uri('/seller/forgot-password/send-otp'),
      headers: _headers(null),
      body: jsonEncode({
        'phone': phone,
      }),
    );

    return _decodeResponse(response);
  }

  Future<Map<String, dynamic>> verifyForgotPasswordOtp({
    required String phone,
    required String otp,
  }) async {
    final response = await ApiHttpClient.post(
      ApiConfig.uri('/seller/forgot-password/verify-otp'),
      headers: _headers(null),
      body: jsonEncode({
        'phone': phone,
        'otp': otp,
      }),
    );

    return _decodeResponse(response);
  }

  Future<Map<String, dynamic>> resetPassword({
    required String resetToken,
    required String password,
    required String passwordConfirmation,
  }) async {
    final response = await ApiHttpClient.post(
      ApiConfig.uri('/seller/forgot-password/reset'),
      headers: _headers(null),
      body: jsonEncode({
        'reset_token': resetToken,
        'password': password,
        'password_confirmation': passwordConfirmation,
      }),
    );

    return _decodeResponse(response);
  }

  Future<Map<String, dynamic>> completeRegistration({
    required String verificationToken,
    required String name,
    String? email,
    required String gender,
    required String city,
    required String birthdate,
    required String shopName,
    String? shopPhone,
    String? shopUrl,
  }) async {
    final payload = <String, dynamic>{
      'verification_token': verificationToken,
      'name': name,
      'gender': gender,
      'city': city,
      'birthdate': birthdate,
      'shop_name': shopName,
    };

    if (email != null && email.isNotEmpty) {
      payload['email'] = email;
    }
    if (shopPhone != null && shopPhone.isNotEmpty) {
      payload['shop_phone'] = shopPhone;
    }
    if (shopUrl != null && shopUrl.isNotEmpty) {
      payload['shop_url'] = shopUrl;
    }

    final response = await ApiHttpClient.post(
      ApiConfig.uri('/seller/complete-registration'),
      headers: _headers(null),
      body: jsonEncode(payload),
    );

    return _decodeResponse(response);
  }

  Future<List<String>> fetchStatesOfCountry({
    required String countryId,
  }) async {
    final response = await ApiHttpClient.post(
      ApiConfig.uri('/v1/ecommerce-core/get-states-of-countries'),
      headers: _headers(null),
      body: jsonEncode({'country_id': countryId}),
    );

    final decoded = _decodeResponse(response);
    final items = <dynamic>[];
    final data = decoded['data'] ?? decoded['states'] ?? decoded['cities'];

    if (data is List) {
      items.addAll(data);
    } else if (data is Map<String, dynamic>) {
      final nested = data['states'] ?? data['cities'] ?? data['data'];
      if (nested is List) {
        items.addAll(nested);
      }
    }

    final cities = <String>[];
    for (final item in items) {
      if (item == null) continue;
      String? name;
      if (item is String) {
        name = item;
      } else if (item is Map) {
        final value = item['name'] ??
            item['state_name'] ??
            item['title'] ??
            item['city'];
        if (value != null) {
          name = value.toString();
        }
      } else {
        name = item.toString();
      }

      final trimmed = name?.trim();
      if (trimmed != null && trimmed.isNotEmpty && !cities.contains(trimmed)) {
        cities.add(trimmed);
      }
    }

    return cities;
  }

  Future<Map<String, dynamic>> login({
    required String phone,
    required String password,
  }) async {
    final response = await ApiHttpClient.post(
      ApiConfig.uri('/v1/multivendor/seller-login'),
      headers: _headers(null),
      body: jsonEncode({
        'phone': phone,
        'password': password,
      }),
    );

    return _decodeResponse(response);
  }

  Future<Map<String, dynamic>> fetchSellerShopDetails({
    required String authToken,
  }) async {
    final response = await ApiHttpClient.get(
      ApiConfig.uri('/v1/multivendor/seller-shop-details'),
      headers: _headers(authToken),
    );

    return _decodeResponse(response);
  }

  Future<Map<String, dynamic>> updateSellerShopDetails({
    required String authToken,
    required String shopName,
    required String shopPhone,
    required String shopSlug,
    String? sellerPhone,
    String? shopLogo,
    String? shopBanner,
    String? shopAddress,
    String? metaTitle,
    String? metaDescription,
    String? metaImage,
  }) async {
    final payload = <String, dynamic>{
      'shop_name': shopName,
      'shop_phone': shopPhone,
      'shop_slug': shopSlug,
    };

    if (sellerPhone != null && sellerPhone.isNotEmpty) {
      payload['seller_phone'] = sellerPhone;
    }
    if (shopLogo != null && shopLogo.isNotEmpty) {
      payload['shop_logo'] = shopLogo;
    }
    if (shopBanner != null && shopBanner.isNotEmpty) {
      payload['shop_banner'] = shopBanner;
    }
    if (shopAddress != null && shopAddress.isNotEmpty) {
      payload['shop_address'] = shopAddress;
    }
    if (metaTitle != null && metaTitle.isNotEmpty) {
      payload['meta_title'] = metaTitle;
    }
    if (metaDescription != null && metaDescription.isNotEmpty) {
      payload['meta_description'] = metaDescription;
    }
    if (metaImage != null && metaImage.isNotEmpty) {
      payload['meta_image'] = metaImage;
    }

    final response = await ApiHttpClient.post(
      ApiConfig.uri('/v1/multivendor/seller-shop-details/update'),
      headers: _headers(authToken),
      body: jsonEncode(payload),
    );

    return _decodeResponse(response);
  }

  Future<Map<String, dynamic>> uploadSellerShopImage({
    required String authToken,
    required File imageFile,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      ApiConfig.uri('/v1/multivendor/seller-shop-images/upload'),
    );
    request.headers.addAll(_multipartHeaders(authToken));
    request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
    final streamed = await ApiHttpClient.send(request);
    final response = await http.Response.fromStream(streamed);

    return _decodeResponse(response);
  }

  Future<Map<String, dynamic>> updateSellerShopImage({
    required String authToken,
    required String type,
    File? imageFile,
    int? fileId,
    bool removeOld = true,
  }) async {
    if (imageFile != null) {
      final request = http.MultipartRequest(
        'POST',
        ApiConfig.uri('/v1/multivendor/seller-shop-images/update'),
      );
      request.headers.addAll(_multipartHeaders(authToken));
      request.fields['type'] = type;
      if (!removeOld) {
        request.fields['remove_old'] = 'false';
      }
      request.files
          .add(await http.MultipartFile.fromPath('image', imageFile.path));
      final streamed = await ApiHttpClient.send(request);
      final response = await http.Response.fromStream(streamed);

      return _decodeResponse(response);
    }

    final payload = <String, dynamic>{
      'type': type,
    };
    if (!removeOld) {
      payload['remove_old'] = false;
    }
    if (fileId != null) {
      payload['file_id'] = fileId;
    }

    final response = await ApiHttpClient.post(
      ApiConfig.uri('/v1/multivendor/seller-shop-images/update'),
      headers: _headers(authToken),
      body: jsonEncode(payload),
    );

    return _decodeResponse(response);
  }

  Future<Map<String, dynamic>> updateSellerShopSeo({
    required String authToken,
    String? metaTitle,
    String? metaDescription,
    File? imageFile,
    int? metaImageId,
    bool removeOld = true,
  }) async {
    if (imageFile != null) {
      final request = http.MultipartRequest(
        'POST',
        ApiConfig.uri('/v1/multivendor/seller-shop-seo/update'),
      );
      request.headers.addAll(_multipartHeaders(authToken));
      if (metaTitle != null && metaTitle.isNotEmpty) {
        request.fields['meta_title'] = metaTitle;
      }
      if (metaDescription != null && metaDescription.isNotEmpty) {
        request.fields['meta_description'] = metaDescription;
      }
      if (!removeOld) {
        request.fields['remove_old'] = 'false';
      }
      request.files
          .add(await http.MultipartFile.fromPath('image', imageFile.path));
      final streamed = await ApiHttpClient.send(request);
      final response = await http.Response.fromStream(streamed);

      return _decodeResponse(response);
    }

    final payload = <String, dynamic>{};
    if (metaTitle != null && metaTitle.isNotEmpty) {
      payload['meta_title'] = metaTitle;
    }
    if (metaDescription != null && metaDescription.isNotEmpty) {
      payload['meta_description'] = metaDescription;
    }
    if (metaImageId != null) {
      payload['meta_image'] = metaImageId;
    }
    if (!removeOld) {
      payload['remove_old'] = false;
    }

    final response = await ApiHttpClient.post(
      ApiConfig.uri('/v1/multivendor/seller-shop-seo/update'),
      headers: _headers(authToken),
      body: jsonEncode(payload),
    );

    return _decodeResponse(response);
  }

  Future<Map<String, dynamic>> verifyFirebaseToken({
    required String idToken,
    String? name,
  }) async {
    final payload = <String, dynamic>{
      'idToken': idToken,
    };

    if (name != null && name.isNotEmpty) {
      payload['name'] = name;
    }

    final response = await ApiHttpClient.post(
      ApiConfig.uri('/auth/firebase'),
      headers: _headers(null),
      body: jsonEncode(payload),
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
              'SellerAuthService error ($statusCode): $message',
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
            'SellerAuthService error ($statusCode): $message',
          );
        }
        throw Exception(message);
      }
    }

    if (statusCode == 401) {
      throw Exception('Unauthenticated.');
    }

    debugPrint(
      'SellerAuthService error ($statusCode): ${response.body}',
    );
    throw Exception('Request failed ($statusCode).');
  }
}
