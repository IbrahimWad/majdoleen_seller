class SellerOrderListResponse {
  final List<SellerOrderSummary> orders;
  final SellerOrderListMeta? meta;

  const SellerOrderListResponse({
    required this.orders,
    required this.meta,
  });

  factory SellerOrderListResponse.fromJson(Map<String, dynamic> json) {
    final data = _parseList(json['data']);
    final meta = _asMap(json['meta']);
    return SellerOrderListResponse(
      orders: data.map((item) => SellerOrderSummary.fromJson(_asMap(item))).toList(),
      meta: meta.isEmpty ? null : SellerOrderListMeta.fromJson(meta),
    );
  }
}

class SellerOrderListMeta {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  const SellerOrderListMeta({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory SellerOrderListMeta.fromJson(Map<String, dynamic> json) {
    return SellerOrderListMeta(
      currentPage: _parseInt(json['current_page']) ?? 1,
      lastPage: _parseInt(json['last_page']) ?? 1,
      perPage: _parseInt(json['per_page']) ?? 10,
      total: _parseInt(json['total']) ?? 0,
    );
  }
}

class SellerOrderSummary {
  final int id;
  final String orderCode;
  final SellerOrderCustomer? customer;
  final int totalItems;
  final double sellerAmount;
  final int? deliveryStatus;
  final String deliveryStatusLabel;
  final int? paymentStatus;
  final String paymentStatusLabel;
  final String? orderDate;
  final String? createdAt;

  const SellerOrderSummary({
    required this.id,
    required this.orderCode,
    required this.customer,
    required this.totalItems,
    required this.sellerAmount,
    required this.deliveryStatus,
    required this.deliveryStatusLabel,
    required this.paymentStatus,
    required this.paymentStatusLabel,
    required this.orderDate,
    required this.createdAt,
  });

  factory SellerOrderSummary.fromJson(Map<String, dynamic> json) {
    return SellerOrderSummary(
      id: _parseInt(json['id']) ?? 0,
      orderCode: _parseString(
            json['order_code'] ??
                json['orderCode'] ??
                json['code'] ??
                json['order_number'],
          ) ??
          '',
      customer: _mapIfPresent(json['customer'], SellerOrderCustomer.fromJson),
      totalItems:
          _parseInt(json['total_items'] ?? json['totalItems']) ?? 0,
      sellerAmount: _parseDouble(
            json['seller_amount'] ??
                json['sellerAmount'] ??
                json['total'] ??
                json['total_payable'],
          ) ??
          0,
      deliveryStatus: _parseInt(json['delivery_status']),
      deliveryStatusLabel: _parseString(
            json['delivery_status_label'] ??
                json['deliveryStatusLabel'],
          ) ??
          '',
      paymentStatus: _parseInt(json['payment_status']),
      paymentStatusLabel: _parseString(
            json['payment_status_label'] ??
                json['paymentStatusLabel'],
          ) ??
          '',
      orderDate: _parseString(json['order_date']),
      createdAt: _parseString(json['created_at']),
    );
  }
}

class SellerOrderCustomer {
  final int id;
  final String name;
  final String type;

  const SellerOrderCustomer({
    required this.id,
    required this.name,
    required this.type,
  });

  factory SellerOrderCustomer.fromJson(Map<String, dynamic> json) {
    return SellerOrderCustomer(
      id: _parseInt(json['id']) ?? 0,
      name: _parseString(json['name']) ?? '',
      type: _parseString(json['type']) ?? '',
    );
  }
}

class SellerOrderCounters {
  final Map<String, int> counts;

  const SellerOrderCounters({required this.counts});

  factory SellerOrderCounters.fromJson(Map<String, dynamic> json) {
    var source = _asMap(json['data']);
    if (source.isEmpty) {
      source = json;
    }
    return SellerOrderCounters(counts: _parseIntMap(source));
  }

  int countFor(String key) {
    return counts[key] ?? 0;
  }
}

class SellerOrderDetails {
  final int id;
  final String orderCode;
  final SellerOrderCustomer? customer;
  final SellerOrderTotals totals;
  final List<SellerOrderProduct> products;
  final bool sellerCanAccept;
  final bool sellerCanCancel;
  final int? deliveryStatus;
  final String deliveryStatusLabel;
  final int? paymentStatus;
  final String paymentStatusLabel;
  final String? orderDate;
  final Map<String, dynamic> billingDetails;
  final Map<String, dynamic> shippingDetails;

  const SellerOrderDetails({
    required this.id,
    required this.orderCode,
    required this.customer,
    required this.totals,
    required this.products,
    required this.sellerCanAccept,
    required this.sellerCanCancel,
    required this.deliveryStatus,
    required this.deliveryStatusLabel,
    required this.paymentStatus,
    required this.paymentStatusLabel,
    required this.orderDate,
    required this.billingDetails,
    required this.shippingDetails,
  });

  factory SellerOrderDetails.fromJson(Map<String, dynamic> json) {
    var payload = _asMap(json['data']);
    if (payload.isEmpty) {
      payload = _asMap(json['details']);
    }
    if (payload.isEmpty) {
      payload = json;
    }
    final productsList = _parseList(payload['products']);
    return SellerOrderDetails(
      id: _parseInt(payload['id']) ?? 0,
      orderCode: _parseString(
            payload['order_code'] ??
                payload['orderCode'] ??
                payload['code'] ??
                payload['order_number'],
          ) ??
          '',
      customer: _mapIfPresent(
        payload['customer'],
        SellerOrderCustomer.fromJson,
      ),
      totals: SellerOrderTotals.fromJson(_asMap(payload['totals'])),
      products: productsList
          .map((item) => SellerOrderProduct.fromJson(_asMap(item)))
          .toList(),
      sellerCanAccept: _parseBool(payload['seller_can_accept']),
      sellerCanCancel: _parseBool(payload['seller_can_cancel']),
      deliveryStatus: _parseInt(payload['delivery_status']),
      deliveryStatusLabel:
          _parseString(payload['delivery_status_label']) ?? '',
      paymentStatus: _parseInt(payload['payment_status']),
      paymentStatusLabel:
          _parseString(payload['payment_status_label']) ?? '',
      orderDate:
          _parseString(payload['order_date'] ?? payload['created_at']),
      billingDetails: _asMap(payload['billing_details']),
      shippingDetails: _asMap(payload['shipping_details']),
    );
  }
}

class SellerOrderTotals {
  final double subtotal;
  final double deliveryCost;
  final double tax;
  final double discount;
  final double totalPayable;

  const SellerOrderTotals({
    required this.subtotal,
    required this.deliveryCost,
    required this.tax,
    required this.discount,
    required this.totalPayable,
  });

  factory SellerOrderTotals.fromJson(Map<String, dynamic> json) {
    return SellerOrderTotals(
      subtotal: _parseDouble(json['subtotal']) ?? 0,
      deliveryCost:
          _parseDouble(json['delivery_cost'] ?? json['delivery']) ?? 0,
      tax: _parseDouble(json['tax']) ?? 0,
      discount: _parseDouble(json['discount']) ?? 0,
      totalPayable:
          _parseDouble(json['total_payable'] ?? json['total']) ?? 0,
    );
  }
}

class SellerOrderProduct {
  final int id;
  final String name;
  final int quantity;
  final double unitPrice;
  final double lineTotal;
  final int? deliveryStatus;
  final String deliveryStatusLabel;
  final int? paymentStatus;
  final String paymentStatusLabel;
  final int? returnStatus;
  final String returnStatusLabel;
  final String imageUrl;
  final String estimateDeliveryTime;
  final List<Map<String, dynamic>> trackingList;
  final Map<String, dynamic> shipping;

  const SellerOrderProduct({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unitPrice,
    required this.lineTotal,
    required this.deliveryStatus,
    required this.deliveryStatusLabel,
    required this.paymentStatus,
    required this.paymentStatusLabel,
    required this.returnStatus,
    required this.returnStatusLabel,
    required this.imageUrl,
    required this.estimateDeliveryTime,
    required this.trackingList,
    required this.shipping,
  });

  factory SellerOrderProduct.fromJson(Map<String, dynamic> json) {
    final quantity = _parseInt(json['quantity'] ?? json['qty']) ?? 0;
    final unitPrice = _parseDouble(
          json['unit_price'] ??
              json['price'] ??
              json['unitPrice'],
        ) ??
        0;
    final lineTotal = _parseDouble(
          json['line_total'] ??
              json['total'] ??
              json['total_price'],
        ) ??
        (quantity * unitPrice);
    return SellerOrderProduct(
      id: _parseInt(json['id']) ?? 0,
      name: _parseString(json['name'] ?? json['product_name']) ?? '',
      quantity: quantity,
      unitPrice: unitPrice,
      lineTotal: lineTotal,
      deliveryStatus: _parseInt(json['delivery_status']),
      deliveryStatusLabel:
          _parseString(json['delivery_status_label']) ?? '',
      paymentStatus: _parseInt(json['payment_status']),
      paymentStatusLabel:
          _parseString(json['payment_status_label']) ?? '',
      returnStatus: _parseInt(json['return_status']),
      returnStatusLabel:
          _parseString(json['return_status_label']) ?? '',
      imageUrl: _parseString(json['image_url'] ?? json['image']) ?? '',
      estimateDeliveryTime:
          _parseString(json['estimate_delivery_time']) ?? '',
      trackingList: _parseList(json['tracking_list'])
          .map((item) => _asMap(item))
          .toList(),
      shipping: _asMap(json['shipping']),
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
      result[key.toString()] = _parseInt(val) ?? 0;
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

bool _parseBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final normalized = value.trim().toLowerCase();
    return normalized == 'true' || normalized == '1' || normalized == 'yes';
  }
  return false;
}

T? _mapIfPresent<T>(
  dynamic value,
  T Function(Map<String, dynamic>) mapper,
) {
  if (value is Map) {
    return mapper(_asMap(value));
  }
  return null;
}
