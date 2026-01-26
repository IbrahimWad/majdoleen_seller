import '../config/api_config.dart';

class ImageSlider {
  final int id;
  final String title;
  final String description;
  final String imageUrl;
  final bool isActive;
  final DateTime createdAt;
  final String? titleEn;
  final String? titleAr;
  final String? titleKu;
  final String? descriptionEn;
  final String? descriptionAr;
  final String? descriptionKu;
  final String? buttonText;
  final String? buttonTextEn;
  final String? buttonTextAr;
  final String? buttonTextKu;
  final String? linkText;
  final String? linkTextEn;
  final String? linkTextAr;
  final String? linkTextKu;
  final String? linkUrl;

  const ImageSlider({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.isActive,
    required this.createdAt,
    this.titleEn,
    this.titleAr,
    this.titleKu,
    this.descriptionEn,
    this.descriptionAr,
    this.descriptionKu,
    this.buttonText,
    this.buttonTextEn,
    this.buttonTextAr,
    this.buttonTextKu,
    this.linkText,
    this.linkTextEn,
    this.linkTextAr,
    this.linkTextKu,
    this.linkUrl,
  });

  factory ImageSlider.fromJson(Map<String, dynamic> json) {
    final rawUrl = json['image_url']?.toString() ?? '';
    final resolvedUrl = ApiConfig.resolveMediaUrl(rawUrl);
    return ImageSlider(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      imageUrl: resolvedUrl,
      isActive: json['is_active'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      titleEn: json['title_en'] as String?,
      titleAr: json['title_ar'] as String?,
      titleKu: json['title_ku'] as String?,
      descriptionEn: json['description_en'] as String?,
      descriptionAr: json['description_ar'] as String?,
      descriptionKu: json['description_ku'] as String?,
      buttonText: json['button_text'] as String?,
      buttonTextEn: json['button_text_en'] as String?,
      buttonTextAr: json['button_text_ar'] as String?,
      buttonTextKu: json['button_text_ku'] as String?,
      linkText: json['link_text'] as String?,
      linkTextEn: json['link_text_en'] as String?,
      linkTextAr: json['link_text_ar'] as String?,
      linkTextKu: json['link_text_ku'] as String?,
      linkUrl: json['link_url'] as String?,
    );
  }

  String localizedTitle(String languageCode) {
    switch (languageCode) {
      case 'ar':
        return titleAr?.trim().isNotEmpty == true ? titleAr!.trim() : title;
      case 'ku':
        return titleKu?.trim().isNotEmpty == true ? titleKu!.trim() : title;
      default:
        return titleEn?.trim().isNotEmpty == true ? titleEn!.trim() : title;
    }
  }

  String localizedDescription(String languageCode) {
    switch (languageCode) {
      case 'ar':
        return descriptionAr?.trim().isNotEmpty == true
            ? descriptionAr!.trim()
            : description;
      case 'ku':
        return descriptionKu?.trim().isNotEmpty == true
            ? descriptionKu!.trim()
            : description;
      default:
        return descriptionEn?.trim().isNotEmpty == true
            ? descriptionEn!.trim()
            : description;
    }
  }
}
