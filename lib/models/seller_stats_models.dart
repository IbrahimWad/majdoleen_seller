class SellerShopStats {
  final ShopInfo shop;
  final ProductsStats products;
  final OrdersStats orders;
  final EarningsStats earnings;
  final int followers;
  final ReviewSummary reviewSummary;

  const SellerShopStats({
    required this.shop,
    required this.products,
    required this.orders,
    required this.earnings,
    required this.followers,
    required this.reviewSummary,
  });

  factory SellerShopStats.fromJson(Map<String, dynamic> json) {
    return SellerShopStats(
      shop: ShopInfo.fromJson(_asMap(json['shop'])),
      products: ProductsStats.fromJson(_asMap(json['products'])),
      orders: OrdersStats.fromJson(_asMap(json['orders'])),
      earnings: EarningsStats.fromJson(_asMap(json['earnings'])),
      followers: _parseInt(json['followers']) ?? 0,
      reviewSummary: ReviewSummary.fromJson(_asMap(json['review_summary'])),
    );
  }
}

class ShopInfo {
  final int id;
  final String name;
  final String slug;
  final int status;

  const ShopInfo({
    required this.id,
    required this.name,
    required this.slug,
    required this.status,
  });

  factory ShopInfo.fromJson(Map<String, dynamic> json) {
    return ShopInfo(
      id: _parseInt(json['id']) ?? 0,
      name: _parseString(json['name']) ?? '',
      slug: _parseString(json['slug']) ?? '',
      status: _parseInt(json['status']) ?? 0,
    );
  }
}

class ProductsStats {
  final int total;
  final int active;
  final int inactive;
  final int approved;
  final int pendingApproval;
  final int featured;

  const ProductsStats({
    required this.total,
    required this.active,
    required this.inactive,
    required this.approved,
    required this.pendingApproval,
    required this.featured,
  });

  factory ProductsStats.fromJson(Map<String, dynamic> json) {
    return ProductsStats(
      total: _parseInt(json['total']) ?? 0,
      active: _parseInt(json['active']) ?? 0,
      inactive: _parseInt(json['inactive']) ?? 0,
      approved: _parseInt(json['approved']) ?? 0,
      pendingApproval: _parseInt(json['pending_approval']) ?? 0,
      featured: _parseInt(json['featured']) ?? 0,
    );
  }
}

class OrdersStats {
  final int totalOrders;
  final int totalOrderItems;
  final Map<String, int> deliveryStatus;
  final Map<String, int> paymentStatus;
  final Map<String, int> returnStatus;
  final double grossSales;
  final double paidSales;

  const OrdersStats({
    required this.totalOrders,
    required this.totalOrderItems,
    required this.deliveryStatus,
    required this.paymentStatus,
    required this.returnStatus,
    required this.grossSales,
    required this.paidSales,
  });

  factory OrdersStats.fromJson(Map<String, dynamic> json) {
    return OrdersStats(
      totalOrders: _parseInt(json['total_orders']) ?? 0,
      totalOrderItems: _parseInt(json['total_order_items']) ?? 0,
      deliveryStatus: _parseIntMap(json['delivery_status']),
      paymentStatus: _parseIntMap(json['payment_status']),
      returnStatus: _parseIntMap(json['return_status']),
      grossSales: _parseDouble(json['gross_sales']) ?? 0,
      paidSales: _parseDouble(json['paid_sales']) ?? 0,
    );
  }
}

class EarningsStats {
  final double approved;
  final double pending;
  final double refunded;

  const EarningsStats({
    required this.approved,
    required this.pending,
    required this.refunded,
  });

  factory EarningsStats.fromJson(Map<String, dynamic> json) {
    return EarningsStats(
      approved: _parseDouble(json['approved']) ?? 0,
      pending: _parseDouble(json['pending']) ?? 0,
      refunded: _parseDouble(json['refunded']) ?? 0,
    );
  }
}

class ReviewSummary {
  final String avgReview;
  final int totalReviews;
  final int one;
  final int two;
  final int three;
  final int four;
  final int five;
  final String positiveRatings;

  const ReviewSummary({
    required this.avgReview,
    required this.totalReviews,
    required this.one,
    required this.two,
    required this.three,
    required this.four,
    required this.five,
    required this.positiveRatings,
  });

  factory ReviewSummary.fromJson(Map<String, dynamic> json) {
    return ReviewSummary(
      avgReview: _parseString(json['avg_review']) ?? '0',
      totalReviews: _parseInt(json['total_reviews']) ?? 0,
      one: _parseInt(json['one']) ?? 0,
      two: _parseInt(json['two']) ?? 0,
      three: _parseInt(json['three']) ?? 0,
      four: _parseInt(json['four']) ?? 0,
      five: _parseInt(json['five']) ?? 0,
      positiveRatings: _parseString(json['positive_ratings']) ?? '0',
    );
  }
}

class SellerStats {
  final String range;
  final String currency;
  final SellerStatsSummary summary;
  final List<StatsTrendPoint> trend;
  final List<StatsCategory> categories;
  final List<StatsMonthly> monthly;
  final List<StatsTopProduct> topProducts;

  const SellerStats({
    required this.range,
    required this.currency,
    required this.summary,
    required this.trend,
    required this.categories,
    required this.monthly,
    required this.topProducts,
  });

  factory SellerStats.fromJson(Map<String, dynamic> json) {
    return SellerStats(
      range: _parseString(json['range']) ?? 'month',
      currency: _parseString(json['currency']) ?? '',
      summary: SellerStatsSummary.fromJson(_asMap(json['summary'])),
      trend: _parseList(json['trend'])
          .map((item) => StatsTrendPoint.fromJson(_asMap(item)))
          .toList(),
      categories: _parseList(json['categories'])
          .map((item) => StatsCategory.fromJson(_asMap(item)))
          .toList(),
      monthly: _parseList(json['monthly'])
          .map((item) => StatsMonthly.fromJson(_asMap(item)))
          .toList(),
      topProducts: _parseList(json['top_products'])
          .map((item) => StatsTopProduct.fromJson(_asMap(item)))
          .toList(),
    );
  }
}

class SellerStatsSummary {
  final StatsValue revenue;
  final StatsValue orders;
  final StatsValue conversionRate;
  final StatsValue avgOrderValue;
  final StatsValue customers;
  final StatsValue returnRate;

  const SellerStatsSummary({
    required this.revenue,
    required this.orders,
    required this.conversionRate,
    required this.avgOrderValue,
    required this.customers,
    required this.returnRate,
  });

  factory SellerStatsSummary.fromJson(Map<String, dynamic> json) {
    return SellerStatsSummary(
      revenue: StatsValue.fromJson(_asMap(json['revenue'])),
      orders: StatsValue.fromJson(_asMap(json['orders'])),
      conversionRate: StatsValue.fromJson(_asMap(json['conversion_rate'])),
      avgOrderValue: StatsValue.fromJson(_asMap(json['avg_order_value'])),
      customers: StatsValue.fromJson(_asMap(json['customers'])),
      returnRate: StatsValue.fromJson(_asMap(json['return_rate'])),
    );
  }
}

class StatsValue {
  final double value;
  final double changePct;

  const StatsValue({
    required this.value,
    required this.changePct,
  });

  factory StatsValue.fromJson(Map<String, dynamic> json) {
    return StatsValue(
      value: _parseDouble(json['value']) ?? 0,
      changePct: _parseDouble(json['change_pct']) ?? 0,
    );
  }
}

class StatsTrendPoint {
  final String label;
  final double revenue;
  final double orders;
  final double customers;

  const StatsTrendPoint({
    required this.label,
    required this.revenue,
    required this.orders,
    required this.customers,
  });

  factory StatsTrendPoint.fromJson(Map<String, dynamic> json) {
    return StatsTrendPoint(
      label: _parseString(json['label']) ?? '',
      revenue: _parseDouble(json['revenue']) ?? 0,
      orders: _parseDouble(json['orders']) ?? 0,
      customers: _parseDouble(json['customers']) ?? 0,
    );
  }
}

class StatsCategory {
  final String name;
  final double percentage;

  const StatsCategory({
    required this.name,
    required this.percentage,
  });

  factory StatsCategory.fromJson(Map<String, dynamic> json) {
    return StatsCategory(
      name: _parseString(json['name']) ?? '',
      percentage: _parseDouble(json['percentage']) ?? 0,
    );
  }
}

class StatsMonthly {
  final String label;
  final double revenue;
  final double orders;

  const StatsMonthly({
    required this.label,
    required this.revenue,
    required this.orders,
  });

  factory StatsMonthly.fromJson(Map<String, dynamic> json) {
    return StatsMonthly(
      label: _parseString(json['label']) ?? '',
      revenue: _parseDouble(json['revenue']) ?? 0,
      orders: _parseDouble(json['orders']) ?? 0,
    );
  }
}

class StatsTopProduct {
  final int id;
  final String name;
  final String category;
  final int sold;
  final double revenue;
  final double trendPct;

  const StatsTopProduct({
    required this.id,
    required this.name,
    required this.category,
    required this.sold,
    required this.revenue,
    required this.trendPct,
  });

  factory StatsTopProduct.fromJson(Map<String, dynamic> json) {
    return StatsTopProduct(
      id: _parseInt(json['id']) ?? 0,
      name: _parseString(json['name']) ?? '',
      category: _parseString(json['category']) ?? '',
      sold: _parseInt(json['sold']) ?? 0,
      revenue: _parseDouble(json['revenue']) ?? 0,
      trendPct: _parseDouble(json['trend_pct']) ?? 0,
    );
  }
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return <String, dynamic>{};
}

List<dynamic> _parseList(dynamic value) {
  if (value is List) return value;
  return const [];
}

Map<String, int> _parseIntMap(dynamic value) {
  if (value is Map) {
    final result = <String, int>{};
    value.forEach((key, val) {
      final parsed = _parseInt(val) ?? 0;
      result[key.toString()] = parsed;
    });
    return result;
  }
  return const {};
}

int? _parseInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value.trim());
  return null;
}

double? _parseDouble(dynamic value) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value.trim());
  return null;
}

String? _parseString(dynamic value) {
  if (value == null) return null;
  final stringValue = value.toString();
  return stringValue.trim().isEmpty ? null : stringValue;
}
