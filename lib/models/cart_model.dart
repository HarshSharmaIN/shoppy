import 'package:cloud_firestore/cloud_firestore.dart';

class CartModel {
  final String productId;
  int quantity;
  CartModel({required this.productId, required this.quantity});

  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      productId: json["product_id"] ?? "",
      quantity: json["quantity"] ?? 0,
    );
  }

  static List<CartModel> fromJsonList(List<QueryDocumentSnapshot> list) {
    return list
        .map((e) => CartModel.fromJson(e.data() as Map<String, dynamic>))
        .toList();
  }
}
