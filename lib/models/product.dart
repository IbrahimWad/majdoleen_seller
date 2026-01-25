class Product {
  final String id;
  final String name;
  final double price;
  final int stock;
  final int? lowStockThreshold;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
    this.lowStockThreshold,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      stock: json['stock'] ?? 0,
      lowStockThreshold: json['lowStockThreshold'],
    );
  }

  bool get isLowStock {
    final threshold = lowStockThreshold ?? 10;
    return stock <= threshold;
  }
}
