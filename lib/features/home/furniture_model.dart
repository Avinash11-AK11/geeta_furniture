class FurnitureModel {
  final String id; // 🔑 Firestore document ID
  final String name;
  final String image; // 🔹 Primary image (used in cards)
  final String price; // 🔹 Formatted price (₹xxxx)
  final int priceValue; // 🔹 Numeric price (sorting/search)
  final String category;

  // 🔹 From Admin Panel (Firestore)
  final String? description;

  // 🔹 Image gallery (Cloudinary URLs)
  final List<String> gallery;

  const FurnitureModel({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
    required this.priceValue,
    required this.category,
    this.description,
    this.gallery = const [],
  });

  /// 🔄 Convert object → JSON (unchanged)
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'image': image,
    'price': price,
    'priceValue': priceValue,
    'category': category,
    'description': description,
    'gallery': gallery,
  };

  /// 🔄 Convert JSON → object (unchanged)
  factory FurnitureModel.fromJson(Map<String, dynamic> json) {
    return FurnitureModel(
      id: json['id'] as String,
      name: json['name'] as String,
      image: json['image'] as String,
      price: json['price'] as String,
      priceValue: json['priceValue'] as int,
      category: json['category'] as String,
      description: json['description'],
      gallery: json['gallery'] != null
          ? List<String>.from(json['gallery'])
          : const [],
    );
  }

  /// ✅ Firestore → Model (FIXED IMAGE MAPPING)
  factory FurnitureModel.fromFirestore(String id, Map<String, dynamic> data) {
    final List images = (data['images'] as List?) ?? [];

    final String primaryImage = images.isNotEmpty && images.first['url'] != null
        ? images.first['url']
        : '';

    final List<String> gallery = images.map((e) => e['url'] as String).toList();

    return FurnitureModel(
      id: id,
      name: data['name'] ?? '',
      image: primaryImage,
      price: '₹${data['price'] ?? 0}',
      priceValue: (data['price'] as num?)?.toInt() ?? 0,
      category: data['category'] ?? '',
      description: data['description'],
      gallery: gallery,
    );
  }

  /// 🆔 Equality based on ID (unchanged)
  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is FurnitureModel && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
