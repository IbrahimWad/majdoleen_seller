class SellerProductOptionItem {
  final int? id;
  final String name;
  final Map<String, dynamic> raw;

  const SellerProductOptionItem({
    required this.name,
    this.id,
    this.raw = const <String, dynamic>{},
  });

  factory SellerProductOptionItem.fromJson(dynamic value) {
    if (value is SellerProductOptionItem) {
      return value;
    }
    if (value is String) {
      return SellerProductOptionItem(name: value.trim());
    }
    if (value is num) {
      return SellerProductOptionItem(name: value.toString(), id: value.toInt());
    }
    if (value is Map) {
      final map = Map<String, dynamic>.from(value);
      final id = _parseInt(map['id'] ?? map['value'] ?? map['key']);
      final name = _parseString(
            map['name'] ??
                map['title'] ??
                map['label'] ??
                map['slug'] ??
                map['value'] ??
                map['key'],
          ) ??
          id?.toString() ??
          '';
      return SellerProductOptionItem(name: name, id: id, raw: map);
    }
    return const SellerProductOptionItem(name: '');
  }
}

class SellerProductOptions {
  final List<SellerProductOptionItem> units;
  final List<SellerProductOptionItem> conditions;
  final List<SellerProductOptionItem> colors;
  final List<SellerProductOptionItem> attributes;
  final List<SellerProductOptionItem> categories;
  final List<SellerProductOptionItem> brands;
  final List<SellerProductOptionItem> tags;
  final List<SellerProductOptionItem> shippingProfiles;

  const SellerProductOptions({
    this.units = const [],
    this.conditions = const [],
    this.colors = const [],
    this.attributes = const [],
    this.categories = const [],
    this.brands = const [],
    this.tags = const [],
    this.shippingProfiles = const [],
  });

  factory SellerProductOptions.fromJson(Map<String, dynamic> json) {
    return SellerProductOptions(
      units: _parseOptionList(json['units']),
      conditions: _parseOptionList(json['conditions']),
      colors: _parseOptionList(json['colors']),
      attributes: _parseOptionList(json['attributes']),
      categories: _parseOptionList(json['categories']),
      brands: _parseOptionList(json['brands']),
      tags: _parseOptionList(json['tags']),
      shippingProfiles: _parseOptionList(
        json['shipping_profiles'] ?? json['shippingProfiles'],
      ),
    );
  }

  static List<SellerProductOptionItem> _parseOptionList(dynamic value) {
    if (value is List) {
      return value.map(SellerProductOptionItem.fromJson).toList();
    }
    return const [];
  }
}

class SellerProductDiscount {
  final double amount;
  final int discountType;

  const SellerProductDiscount({
    required this.amount,
    required this.discountType,
  });

  factory SellerProductDiscount.fromJson(Map<String, dynamic> json) {
    return SellerProductDiscount(
      amount: _parseDouble(json['amount']) ?? 0,
      discountType: _parseInt(json['discountType'] ?? json['discount_type']) ?? 0,
    );
  }
}

class SellerProductSummary {
  final int id;
  final String name;
  final String permalink;
  final int status;
  final int isApproved;
  final int isFeatured;
  final int hasVariant;
  final String? thumbnailImage;
  final double? basePrice;
  final double? price;
  final SellerProductDiscount? discount;
  final int? quantity;
  final String? unit;
  final String? createdAt;
  final String? updatedAt;

  const SellerProductSummary({
    required this.id,
    required this.name,
    required this.permalink,
    required this.status,
    required this.isApproved,
    required this.isFeatured,
    required this.hasVariant,
    this.thumbnailImage,
    this.basePrice,
    this.price,
    this.discount,
    this.quantity,
    this.unit,
    this.createdAt,
    this.updatedAt,
  });

  factory SellerProductSummary.fromJson(Map<String, dynamic> json) {
    final discountValue = json['discount'];
    return SellerProductSummary(
      id: _parseInt(json['id']) ?? 0,
      name: _parseString(json['name']) ?? '',
      permalink: _parseString(json['permalink']) ?? '',
      status: _parseInt(json['status']) ?? 0,
      isApproved: _parseInt(json['is_approved']) ?? 0,
      isFeatured: _parseInt(json['is_featured']) ?? 0,
      hasVariant: _parseInt(json['has_variant']) ?? 0,
      thumbnailImage: _parseString(json['thumbnail_image']),
      basePrice: _parseDouble(json['base_price']),
      price: _parseDouble(json['price']),
      discount: discountValue is Map<String, dynamic>
          ? SellerProductDiscount.fromJson(discountValue)
          : null,
      quantity: _parseInt(json['quantity']),
      unit: _parseString(json['unit']),
      createdAt: _parseString(json['created_at']),
      updatedAt: _parseString(json['updated_at']),
    );
  }

  bool get isActive => status == 1;
  bool get isVariable => hasVariant == 1;
}

class SellerProductListMeta {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  const SellerProductListMeta({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory SellerProductListMeta.fromJson(Map<String, dynamic> json) {
    return SellerProductListMeta(
      currentPage: _parseInt(json['current_page']) ?? 1,
      lastPage: _parseInt(json['last_page']) ?? 1,
      perPage: _parseInt(json['per_page']) ?? 0,
      total: _parseInt(json['total']) ?? 0,
    );
  }
}

class SellerProductListResponse {
  final List<SellerProductSummary> products;
  final SellerProductListMeta? meta;

  const SellerProductListResponse({
    required this.products,
    this.meta,
  });

  factory SellerProductListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final metaValue = json['meta'];
    final products = <SellerProductSummary>[];
    if (data is List) {
      products.addAll(
        data
            .whereType<Map>()
            .map((item) =>
                SellerProductSummary.fromJson(Map<String, dynamic>.from(item))),
      );
    }
    return SellerProductListResponse(
      products: products,
      meta: metaValue is Map<String, dynamic>
          ? SellerProductListMeta.fromJson(metaValue)
          : null,
    );
  }
}

class SellerProductVariation {
  final int? id;
  final String code;
  final double? purchasePrice;
  final double? unitPrice;
  final int? quantity;

  const SellerProductVariation({
    this.id,
    required this.code,
    this.purchasePrice,
    this.unitPrice,
    this.quantity,
  });

  factory SellerProductVariation.fromJson(Map<String, dynamic> json) {
    return SellerProductVariation(
      id: _parseInt(json['id']),
      code: _parseString(json['code']) ?? '',
      purchasePrice: _parseDouble(json['purchase_price']),
      unitPrice: _parseDouble(json['unit_price']),
      quantity: _parseInt(json['quantity']),
    );
  }
}

class SellerProductDetails {
  final Map<String, dynamic> raw;

  const SellerProductDetails(this.raw);

  factory SellerProductDetails.fromJson(Map<String, dynamic> json) {
    return SellerProductDetails(json);
  }

  int? get id => _parseInt(raw['id']);
  String get name => _parseString(raw['name']) ?? '';
  String get permalink => _parseString(raw['permalink']) ?? '';
  String get description =>
      _parseString(raw['description']) ??
      _parseString(raw['short_description']) ??
      '';
  int get productType =>
      _parseInt(raw['product_type'] ?? raw['product_type_id']) ?? 2;
  int get status => _parseInt(raw['status']) ?? 1;
  int get hasVariant => _parseInt(raw['has_variant']) ?? 0;
  int? get unitId => _parseInt(raw['unit_id'] ?? raw['unit']);
  int? get conditionId => _parseInt(raw['condition_id'] ?? raw['condition']);
  int? get discountAmountType => _parseInt(raw['discount_amount_type']);
  double? get discountAmount => _parseDouble(raw['discount_amount']);
  double? get purchasePrice => _parseDouble(raw['purchase_price']);
  double? get unitPrice =>
      _parseDouble(raw['unit_price'] ?? raw['price']);
  int? get quantity => _parseInt(raw['quantity']);
  int? get thumbnailImageId => _parseInt(raw['thumbnail_image']);
  String? get thumbnailImageUrl {
    final rawValue = raw['thumbnail_image_url'] ?? raw['thumbnail_image'];
    return rawValue is String ? rawValue : null;
  }

  List<SellerProductVariation> get variations {
    final value = raw['variations'];
    if (value is List) {
      return value
          .whereType<Map>()
          .map(
            (item) => SellerProductVariation.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();
    }
    return const [];
  }
}

class SellerProductMediaUpload {
  final int fileId;
  final String url;

  const SellerProductMediaUpload({
    required this.fileId,
    required this.url,
  });
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
