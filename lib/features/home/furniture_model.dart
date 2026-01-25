class FurnitureModel {
  final String id; // ✅ REQUIRED (used for deep links & sharing)
  final String name;
  final String image;
  final String price;
  final int priceValue;
  final String category;
  final List<String> gallery;

  const FurnitureModel({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
    required this.priceValue,
    required this.category,
    this.gallery = const [],
  });

  /// 🔄 Convert object → JSON (storage / share)
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'image': image,
    'price': price,
    'priceValue': priceValue,
    'category': category,
    'gallery': gallery,
  };

  /// 🔄 Convert JSON → object (restore / deep link)
  factory FurnitureModel.fromJson(Map<String, dynamic> json) {
    return FurnitureModel(
      id: json['id'] as String,
      name: json['name'] as String,
      image: json['image'] as String,
      price: json['price'] as String,
      priceValue: json['priceValue'] as int,
      category: json['category'] as String,
      gallery: json['gallery'] != null
          ? List<String>.from(json['gallery'])
          : const [],
    );
  }

  /// 🆔 Equality based on ID (VERY IMPORTANT for wishlist)
  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is FurnitureModel && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
