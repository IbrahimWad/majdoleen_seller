class ImageSlider {
  final int id;
  final String title;
  final String description;
  final String imageUrl;
  final bool isActive;
  final DateTime createdAt;

  const ImageSlider({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.isActive,
    required this.createdAt,
  });

  factory ImageSlider.fromJson(Map<String, dynamic> json) {
    return ImageSlider(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      imageUrl: json['image_url'] as String,
      isActive: json['is_active'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}