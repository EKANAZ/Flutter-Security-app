import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_security/models/user.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part '../gen/order_model.freezed.dart';
part '../gen/order_model.g.dart';



@freezed
class ProductModel with _$ProductModel {
  const factory ProductModel({
    @JsonKey(name: "_id") required String id,
    @JsonKey(name: "name")  String? name,
    @JsonKey(name: "description") String? description,
    @JsonKey(name: "price") required double price,
    @JsonKey(name: "imageUrl") String? imageUrl,
  }) = _ProductModel;

  factory ProductModel.fromJson(Map<String, dynamic> json) => _$ProductModelFromJson(json);
}
@freezed
class OrderModel with _$OrderModel {
  const factory OrderModel({
    @JsonKey(name: "_id") required String id,
    @JsonKey(name: "userId")  UserModel? userId, // Use UserModel
    @JsonKey(name: "products")  List<ProductItem>? products, // List of ProductItem
    @JsonKey(name: "totalAmount")  double? totalAmount,
    @JsonKey(name: "status")  String? status,
  }) = _OrderModel;

  factory OrderModel.fromJson(Map<String, dynamic> json) => _$OrderModelFromJson(json);
}



@freezed
class ProductItem with _$ProductItem {
  const factory ProductItem({
    @JsonKey(name: "productId") required ProductModel productId,
    @JsonKey(name: "quantity") required  int quantity,
  }) = _ProductItem;

  factory ProductItem.fromJson(Map<String, dynamic> json) => _$ProductItemFromJson(json);
}