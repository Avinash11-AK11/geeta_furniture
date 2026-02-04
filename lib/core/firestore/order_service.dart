import 'package:cloud_firestore/cloud_firestore.dart';
import 'order_model.dart';

class OrderService {
  static final _db = FirebaseFirestore.instance;
  static final _ref = _db.collection('orders');

  static Future<void> createOrder(OrderModel order) async {
    await _ref.add(order.toMap());
  }

  static Stream<List<OrderModel>> userOrders(String userId) {
    return _ref
        .where('user.userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => OrderModel.fromDoc(d)).toList());
  }

  static Stream<List<OrderModel>> allOrders() {
    return _ref
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => OrderModel.fromDoc(d)).toList());
  }

  static Future<void> updateOrder(
    String orderId,
    Map<String, dynamic> data,
  ) async {
    await _ref.doc(orderId).update(data);
  }
}
