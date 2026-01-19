import 'package:shared_preferences/shared_preferences.dart';

class AuthStorage {
  static const String _tokenKey = 'seller_access_token';

  Future<void> saveToken(String token) async {
    final normalized = _normalizeToken(token);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, normalized);
  }

  Future<String?> readToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  String _normalizeToken(String token) {
    var normalized = token.trim();
    if (normalized.toLowerCase().startsWith('bearer ')) {
      normalized = normalized.substring('bearer '.length).trim();
    }
    return normalized;
  }
}
