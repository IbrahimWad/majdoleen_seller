import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/image_slider_model.dart';
import 'api_http_client.dart';

class ImageSliderService {
  const ImageSliderService();

  Future<List<ImageSlider>> fetchImageSliders() async {
    final response = await ApiHttpClient.get(
      ApiConfig.uri('/v1/multivendor/image-sliders'),
      headers: _headers(),
    );
    final decoded = _decodeResponse(response);
    
    // Handle nested data structure: data.sliders array
    final dataObj = decoded['data'] as Map<String, dynamic>?;
    final slidersList = dataObj?['sliders'] as List<dynamic>? ?? [];
    
    return slidersList
        .map((json) => ImageSlider.fromJson(json as Map<String, dynamic>))
        .where((slider) => slider.isActive)
        .toList();
  }

  Map<String, String> _headers() {
    return <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
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
            debugPrint('ImageSliderService error ($statusCode): $message');
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
        debugPrint('ImageSliderService error ($statusCode): $message');
        throw Exception(message);
      }
    }

    debugPrint(
      'ImageSliderService error ($statusCode): ${response.body}',
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