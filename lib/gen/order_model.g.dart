// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../models/order_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProductModelImpl _$$ProductModelImplFromJson(Map<String, dynamic> json) =>
    _$ProductModelImpl(
      id: json['_id'] as String,
      name: json['name'] as String?,
      description: json['description'] as String?,
      price: (json['price'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String?,
    );

Map<String, dynamic> _$$ProductModelImplToJson(_$ProductModelImpl instance) =>
    <String, dynamic>{
      '_id': instance.id,
      if (instance.name case final value?) 'name': value,
      if (instance.description case final value?) 'description': value,
      'price': instance.price,
      if (instance.imageUrl case final value?) 'imageUrl': value,
    };

_$OrderModelImpl _$$OrderModelImplFromJson(Map<String, dynamic> json) =>
    _$OrderModelImpl(
      id: json['_id'] as String?,
      userId:
          json['userId'] == null
              ? null
              : UserModel.fromJson(json['userId'] as Map<String, dynamic>),
      products:
          (json['products'] as List<dynamic>?)
              ?.map((e) => ProductItem.fromJson(e as Map<String, dynamic>))
              .toList(),
      totalAmount: (json['totalAmount'] as num?)?.toDouble(),
      status: json['status'] as String?,
      createdAt:
          json['createdAt'] == null
              ? null
              : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$OrderModelImplToJson(_$OrderModelImpl instance) =>
    <String, dynamic>{
      if (instance.id case final value?) '_id': value,
      if (instance.userId?.toJson() case final value?) 'userId': value,
      if (instance.products?.map((e) => e.toJson()).toList() case final value?)
        'products': value,
      if (instance.totalAmount case final value?) 'totalAmount': value,
      if (instance.status case final value?) 'status': value,
      if (instance.createdAt?.toIso8601String() case final value?)
        'createdAt': value,
    };

_$ProductItemImpl _$$ProductItemImplFromJson(Map<String, dynamic> json) =>
    _$ProductItemImpl(
      product: _productIdFromJson(json['productId']),
      quantity: (json['quantity'] as num).toInt(),
      id: json['_id'] as String?,
    );

Map<String, dynamic> _$$ProductItemImplToJson(_$ProductItemImpl instance) =>
    <String, dynamic>{
      if (instance.product?.toJson() case final value?) 'productId': value,
      'quantity': instance.quantity,
      if (instance.id case final value?) '_id': value,
    };
