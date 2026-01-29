import 'package:shared_preferences/shared_preferences.dart';

class SubscriptionStorage {
  static const String _planIdKey = 'seller_subscription_plan_id';

  Future<void> savePlanId(String planId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_planIdKey, planId.trim());
  }

  Future<String?> readPlanId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_planIdKey);
  }

  Future<void> clearPlanId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_planIdKey);
  }
}
