class ProductDetailsResponse {
  final bool success;
  final ProductDetails data;

  ProductDetailsResponse({
    required this.success,
    required this.data,
  });

  factory ProductDetailsResponse.fromJson(Map<String, dynamic> json) {
    return ProductDetailsResponse(
      success: json['success'] ?? false,
      data: ProductDetails.fromJson(json['data'] ?? {}),
    );
  }
}

class ProductDetails {
  final int id;
  final String name;
  final String? brand;
  final String? summary;
  final String? description;
  final int productType;
  final int supplier;
  final String permalink;
  final int unit;
  final int conditions;
  final int hasVariant;
  final int discountType;
  final double discountAmount;
  final String? pdfSpecifications;
  final String? thumbnailImage;
  final String? videoLink;
  final int isFeatured;
  final int? maxItemOnPurchase;
  final int? minItemOnPurchase;
  final int? lowStockQuantityAlert;
  final int isAuthentic;
  final int hasWarranty;
  final int hasReplacementWarranty;
  final int? warrantyDays;
  final int isRefundable;
  final int? shippingLocationType;
  final int isActiveCod;
  final int isActiveFreeShipping;
  final int? codLocationType;
  final int isActiveAttachment;
  final String? attachmentName;
  final double shippingCost;
  final int isApplyMultipleQtyShippingCost;
  final int isEnableTax;
  final int? taxProfile;
  final int status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int isApproved;
  final List<dynamic> productCats;
  final dynamic brandInfo;
  final List<dynamic> tagItems;
  final List<dynamic> codCountryList;
  final List<dynamic> codStateList;
  final List<dynamic> codCityList;
  final List<dynamic> colorChoices;
  final List<dynamic> choices;
  final List<dynamic> choiceOptions;
  final SinglePrice singlePrice;
  final List<dynamic> variations;
  final ProductSeo productSeo;
  final dynamic shippingInfo;
  final List<ProductImage> images;

  ProductDetails({
    required this.id,
    required this.name,
    this.brand,
    this.summary,
    this.description,
    required this.productType,
    required this.supplier,
    required this.permalink,
    required this.unit,
    required this.conditions,
    required this.hasVariant,
    required this.discountType,
    required this.discountAmount,
    this.pdfSpecifications,
    this.thumbnailImage,
    this.videoLink,
    required this.isFeatured,
    this.maxItemOnPurchase,
    this.minItemOnPurchase,
    this.lowStockQuantityAlert,
    required this.isAuthentic,
    required this.hasWarranty,
    required this.hasReplacementWarranty,
    this.warrantyDays,
    required this.isRefundable,
    this.shippingLocationType,
    required this.isActiveCod,
    required this.isActiveFreeShipping,
    this.codLocationType,
    required this.isActiveAttachment,
    this.attachmentName,
    required this.shippingCost,
    required this.isApplyMultipleQtyShippingCost,
    required this.isEnableTax,
    this.taxProfile,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.isApproved,
    required this.productCats,
    this.brandInfo,
    required this.tagItems,
    required this.codCountryList,
    required this.codStateList,
    required this.codCityList,
    required this.colorChoices,
    required this.choices,
    required this.choiceOptions,
    required this.singlePrice,
    required this.variations,
    required this.productSeo,
    this.shippingInfo,
    required this.images,
  });

  factory ProductDetails.fromJson(Map<String, dynamic> json) {
    return ProductDetails(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      brand: json['brand'],
      summary: json['summary'],
      description: json['description'],
      productType: json['product_type'] ?? 0,
      supplier: json['supplier'] ?? 0,
      permalink: json['permalink'] ?? '',
      unit: json['unit'] ?? 0,
      conditions: json['conditions'] ?? 0,
      hasVariant: json['has_variant'] ?? 0,
      discountType: json['discount_type'] ?? 0,
      discountAmount: (json['discount_amount'] ?? 0).toDouble(),
      pdfSpecifications: json['pdf_specifications'],
      thumbnailImage: json['thumbnail_image'],
      videoLink: json['video_link'],
      isFeatured: json['is_featured'] ?? 0,
      maxItemOnPurchase: json['max_item_on_purchase'],
      minItemOnPurchase: json['min_item_on_purchase'],
      lowStockQuantityAlert: json['low_stock_quantity_alert'],
      isAuthentic: json['is_authentic'] ?? 0,
      hasWarranty: json['has_warranty'] ?? 0,
      hasReplacementWarranty: json['has_replacement_warranty'] ?? 0,
      warrantyDays: json['warrenty_days'],
      isRefundable: json['is_refundable'] ?? 0,
      shippingLocationType: json['shipping_location_type'],
      isActiveCod: json['is_active_cod'] ?? 0,
      isActiveFreeShipping: json['is_active_free_shipping'] ?? 0,
      codLocationType: json['cod_location_type'],
      isActiveAttachment: json['is_active_attatchment'] ?? 0,
      attachmentName: json['attatchment_name'],
      shippingCost: (json['shipping_cost'] ?? 0).toDouble(),
      isApplyMultipleQtyShippingCost: json['is_apply_multiple_qty_shipping_cost'] ?? 0,
      isEnableTax: json['is_enable_tax'] ?? 0,
      taxProfile: json['tax_profile'],
      status: json['status'] ?? 0,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      isApproved: json['is_approved'] ?? 0,
      productCats: json['product_cats'] ?? [],
      brandInfo: json['brand_info'],
      tagItems: json['tag_items'] ?? [],
      codCountryList: json['cod_country_list'] ?? [],
      codStateList: json['cod_state_list'] ?? [],
      codCityList: json['cod_city_list'] ?? [],
      colorChoices: json['color_choices'] ?? [],
      choices: json['choices'] ?? [],
      choiceOptions: json['choice_options'] ?? [],
      singlePrice: SinglePrice.fromJson(json['single_price'] ?? {}),
      variations: json['variations'] ?? [],
      productSeo: ProductSeo.fromJson(json['product_seo'] ?? {}),
      shippingInfo: json['shipping_info'],
      images: (json['images'] as List<dynamic>?)
              ?.map((image) => ProductImage.fromJson(image as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class SinglePrice {
  final int id;
  final int productId;
  final String? sku;
  final double? purchasePrice;
  final double? unitPrice;
  final int quantity;
  final DateTime createdAt;
  final DateTime updatedAt;

  SinglePrice({
    required this.id,
    required this.productId,
    this.sku,
    this.purchasePrice,
    this.unitPrice,
    required this.quantity,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SinglePrice.fromJson(Map<String, dynamic> json) {
    return SinglePrice(
      id: json['id'] ?? 0,
      productId: json['product_id'] ?? 0,
      sku: json['sku'],
      purchasePrice: json['purchase_price'] != null ? (json['purchase_price'] as num).toDouble() : null,
      unitPrice: json['unit_price'] != null ? (json['unit_price'] as num).toDouble() : null,
      quantity: json['quantity'] ?? 0,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    );
  }
}

class ProductSeo {
  final int id;
  final int productId;
  final String? metaTitle;
  final String? metaDescription;
  final String? metaImage;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductSeo({
    required this.id,
    required this.productId,
    this.metaTitle,
    this.metaDescription,
    this.metaImage,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductSeo.fromJson(Map<String, dynamic> json) {
    return ProductSeo(
      id: json['id'] ?? 0,
      productId: json['product_id'] ?? 0,
      metaTitle: json['meta_title'],
      metaDescription: json['meta_description'],
      metaImage: json['meta_image'],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    );
  }
}

class ProductImage {
  final int id;
  final int productId;
  final String imagePath;
  final int orderBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductImage({
    required this.id,
    required this.productId,
    required this.imagePath,
    required this.orderBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(
      id: json['id'] ?? 0,
      productId: json['product_id'] ?? 0,
      imagePath: json['image_path'] ?? json['path'] ?? '',
      orderBy: json['order_by'] ?? 0,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    );
  }
}
