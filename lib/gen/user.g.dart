// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../models/user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserModelImpl _$$UserModelImplFromJson(Map<String, dynamic> json) =>
    _$UserModelImpl(
      id: json['id'] as String?,
      name: json['name'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      userName: json['user_name'] as String?,
      role: json['role'] as String?,
      password: json['password'] as String?,
      feedback: json['feedback'] as String?,
      createdAt: _dateTimeFromJson(json['createdAt']),
    );

Map<String, dynamic> _$$UserModelImplToJson(_$UserModelImpl instance) =>
    <String, dynamic>{
      if (instance.id case final value?) 'id': value,
      if (instance.name case final value?) 'name': value,
      if (instance.email case final value?) 'email': value,
      if (instance.phone case final value?) 'phone': value,
      if (instance.userName case final value?) 'user_name': value,
      if (instance.role case final value?) 'role': value,
      if (instance.password case final value?) 'password': value,
      if (instance.feedback case final value?) 'feedback': value,
      if (instance.createdAt?.toIso8601String() case final value?)
        'createdAt': value,
    };
