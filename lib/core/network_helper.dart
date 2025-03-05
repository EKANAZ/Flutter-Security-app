import 'dart:convert';
import 'package:dio/dio.dart';

class NetworkHelper {
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://localhost:3000',
    connectTimeout: Duration(seconds: 5),
    receiveTimeout: Duration(seconds: 3),
  ));

  static Future<Map<String, dynamic>> registerCustomer({
    required String token,
    required String name,
    required String email,
    required String phoneNumber,
  }) async {
    try {
      final response = await _dio.post(
        '/customer/register',
        data: {
          'name': name,
          'email': email,
          'phoneNumber': phoneNumber,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data;
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 403) {
        throw 'Token expired or invalid';
      }
      throw 'Network error: $e';
    }
  }
}