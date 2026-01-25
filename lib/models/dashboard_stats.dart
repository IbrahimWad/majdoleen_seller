class DashboardStats {
  final String todaySales;
  final String pendingOrders;
  final String availableBalance;
  final String storeRating;

  DashboardStats({
    required this.todaySales,
    required this.pendingOrders,
    required this.availableBalance,
    required this.storeRating,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      todaySales: json['todaySales']?.toString() ?? '\$0.00',
      pendingOrders: json['pendingOrders']?.toString() ?? '0',
      availableBalance: json['availableBalance']?.toString() ?? '\$0.00',
      storeRating: json['storeRating']?.toString() ?? '0.0',
    );
  }
}
