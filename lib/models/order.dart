class Order {
  final String orderId;
  final String status;
  final String customer;
  final int items;
  final String total;
  final String time;

  Order({
    required this.orderId,
    required this.status,
    required this.customer,
    required this.items,
    required this.total,
    required this.time,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      orderId: json['orderId'] ?? '',
      status: json['status'] ?? '',
      customer: json['customer'] ?? '',
      items: json['items'] ?? 0,
      total: json['total'] ?? '\$0.00',
      time: json['time'] ?? '',
    );
  }
}