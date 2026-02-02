import 'furniture_model.dart';

final List<FurnitureModel> demoProducts = [
  FurnitureModel(
    id: 'wooden-chair',
    name: 'Wooden Chair',
    image: 'assets/images/chair.jpg',
    price: '₹3,499',
    priceValue: 3499,
    category: 'Chairs',

    // 🔹 Optional fields (new model compatible)
    description:
        'Classic wooden chair made from high-quality solid wood, '
        'designed for comfort and durability.',
    gallery: ['assets/images/chair.jpg'],
  ),
];
