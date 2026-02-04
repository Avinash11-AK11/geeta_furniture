import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String id;
  final String orderNumber;
  final String status;
  final DateTime createdAt;

  final Map<String, dynamic> user;
  final Map<String, dynamic> product;
  final Map<String, dynamic> request;

  final Map<String, dynamic>? pricing;
  final Map<String, dynamic>? deliveryAddress;
  final List<Map<String, dynamic>> timeline;
  final String? adminNote;

  OrderModel({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.createdAt,
    required this.user,
    required this.product,
    required this.request,
    this.pricing,
    this.deliveryAddress,
    required this.timeline,
    this.adminNote,
  });

  factory OrderModel.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return OrderModel(
      id: doc.id,
      orderNumber: d['orderNumber'],
      status: d['status'],
      createdAt: (d['createdAt'] as Timestamp).toDate(),
      user: Map<String, dynamic>.from(d['user']),
      product: Map<String, dynamic>.from(d['product']),
      request: Map<String, dynamic>.from(d['request']),
      pricing: d['pricing'],
      deliveryAddress: d['deliveryAddress'],
      timeline: List<Map<String, dynamic>>.from(d['timeline'] ?? []),
      adminNote: d['adminNote'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'orderNumber': orderNumber,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'user': user,
      'product': product,
      'request': request,
      'pricing': pricing,
      'deliveryAddress': deliveryAddress,
      'timeline': timeline,
      'adminNote': adminNote,
    };
  }
}
