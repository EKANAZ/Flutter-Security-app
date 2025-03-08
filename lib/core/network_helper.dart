import 'dart:convert';
import 'package:dio/dio.dart';
// core/network_helper.dart
import 'package:dio/dio.dart';
import 'package:flutter_security/models/order_model.dart';
import 'package:flutter_security/models/user.dart';

import 'dart:io';

class NetworkService {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'https://test.ekanas.com', connectTimeout: Duration(seconds: 5), receiveTimeout: Duration(seconds: 3)));

  NetworkService() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          options.validateStatus = (status) => status != null && status < 500;
          handler.next(options);
        },
        onError: (DioError e, handler) async {
          if (e.type == DioErrorType.connectionTimeout || e.type == DioErrorType.receiveTimeout) {
            await Future.delayed(Duration(seconds: 2));
            return handler.resolve(await _dio.request(e.requestOptions.path, options: Options(method: e.requestOptions.method)));
          }
          handler.next(e);
        },
      ),
    );
  }

  Future<Map<String, dynamic>> addCustomer(String token, UserModel customer) async {
    try {
      final response = await _dio.post('/auth/register', data: customer.toJson()..remove('id'), options: Options(headers: {'Authorization': 'Bearer $token'}));
      return response.data;
    } catch (e) {
      throw 'Network error: $e';
    }
  }

  // New public self-registration method
  Future<Map<String, dynamic>> register(UserModel customer) async {
    try {
      final response = await _dio.post(
        '/auth/register',
        data: customer.toJson()..remove('id'), // No token required
      );
      return response.data;
    } catch (e) {
      throw 'Network error: $e';
    }
  }

  Future<List<UserModel>> fetchCustomers(String token) async {
    try {
      final response = await _dio.post('/auth/list-customers', data: {}, options: Options(headers: {'Authorization': 'Bearer $token'}));
      return (response.data as List).map((json) => UserModel.fromJson(json)).toList();
    } catch (e) {
      throw 'Failed to fetch customers: $e';
    }
  }

  Future<Map<String, dynamic>> addProduct(String token, ProductModel product, File? image) async {
    try {
      FormData formData = FormData.fromMap({'name': product.name, 'description': product.description, 'price': product.price, if (image != null) 'image': await MultipartFile.fromFile(image.path)});
      final response = await _dio.post('/products/add', data: formData, options: Options(headers: {'Authorization': 'Bearer $token'}));
      return response.data;
    } catch (e) {
      throw 'Network error: $e';
    }
  }

  Future<List<ProductModel>> fetchProducts() async {
    try {
      final response = await _dio.get('/products/list');
      return (response.data as List).map((json) => ProductModel.fromJson(json)).toList();
    } catch (e) {
      throw 'Failed to fetch products: $e';
    }
  }

  Future<Map<String, dynamic>> createOrder(String token, List<Map<String, dynamic>> cart) async {
    try {
      print(" cart: $cart");
      final response = await _dio.post('/orders/create', data: {'products': cart}, options: Options(headers: {'Authorization': 'Bearer $token'}));
      return response.data;
    } catch (e) {
      throw 'Network error: $e';
    }
  }

  Future<List<OrderModel>> fetchOrders(String token) async {
    try {
      final response = await _dio.post('/orders/list', data: {}, options: Options(headers: {'Authorization': 'Bearer $token'}));

      // Debug the response
      print('Response data type: ${response.data.runtimeType}');
      print('Response data: ${response.data}');

      // Handle null response
      if (response.data == null) {
        print('Response data is null');
        return [];
      }

      // If it's a Map with a data field, extract it
      if (response.data is Map) {
        final responseMap = response.data as Map<String, dynamic>;
        if (responseMap.containsKey('data') && responseMap['data'] is List) {
          return (responseMap['data'] as List).map((json) => OrderModel.fromJson(json as Map<String, dynamic>)).toList();
        }
      }

      // If it's directly a List
      if (response.data is List) {
        return (response.data as List).map((json) => OrderModel.fromJson(json as Map<String, dynamic>)).toList();
      }

      // If we get here, the response format is unexpected
      print('Unexpected response format: ${response.data}');
      return [];
    } catch (e) {
      print('Error details: $e');
      throw 'Failed to fetch orders: $e';
    }
  }
}
