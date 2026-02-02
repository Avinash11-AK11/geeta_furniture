import 'furniture_model.dart';

FurnitureModel furnitureFromFirestore(String docId, Map<String, dynamic> data) {
  final images = (data['images'] as List?) ?? [];

  final imageUrls = images
      .map((e) => e['url'] as String)
      .where((e) => e.isNotEmpty)
      .toList();

  final int priceValue = (data['price'] ?? 0).toInt();

  return FurnitureModel(
    id: docId,
    name: data['name'] ?? '',
    category: data['category'] ?? '',
    image: imageUrls.isNotEmpty ? imageUrls.first : '',
    gallery: imageUrls,
    priceValue: priceValue,
    price: '₹$priceValue',

    description: data['description'],
  );
}
