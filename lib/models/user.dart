
import 'package:freezed_annotation/freezed_annotation.dart';

part '../gen/user.freezed.dart';
part '../gen/user.g.dart';

@freezed
class UserModel with _$UserModel {
  const factory UserModel({
 String ?id,
    @JsonKey(name: "name") String ? name,
    @JsonKey(name: "email") String ?email,
    @JsonKey(name: "phone") String ?phone,
    @JsonKey(name: "user_name") String? userName,
    @JsonKey(name: "role") String ?role, // 'admin' or 'customer'
    @JsonKey(name: "password") String? password, // Optional for admin adding customer
    @JsonKey(name: "feedback") String? feedback, // Optional for customer feedback
    @JsonKey(fromJson: _dateTimeFromJson) DateTime? createdAt,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
}

DateTime? _dateTimeFromJson(dynamic value) => value is String ? DateTime.parse(value) : null;