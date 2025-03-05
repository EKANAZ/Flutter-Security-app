import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    @JsonKey(name: 'uid') String? uid,
    @JsonKey(name: 'email') String? email,
    @JsonKey(name: 'userName') String? userName,
    @JsonKey(name: 'role') String? role,
    @JsonKey(name: 'imageUrl') String? imageUrl,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>   
      _$UserModelFromJson(json);
}