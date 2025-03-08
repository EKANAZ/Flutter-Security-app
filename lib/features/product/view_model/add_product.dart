import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_security/core/auth_helpers.dart';
import 'package:flutter_security/core/network_helper.dart';
import 'package:flutter_security/models/order_model.dart';
import 'package:flutter_security/models/user.dart';

class EcommerceViewModel extends ChangeNotifier {
  final AuthenticationService _authService;
  final NetworkService _networkService;

  UserModel? _currentUser;
  UserModel _loginForm = const UserModel();
  UserModel _customerForm = const UserModel();
  String _errorMessage = '';
  String? _accessToken;
  String? _refreshToken;
  List<UserModel> _customers = [];
  List<ProductModel> _products = [];
  List<OrderModel> _orders = [];
  List<Map<String, dynamic>> _cart = [];
  bool _isLoading = false;
  bool _loginSuccess = false;

  // Product fields
  ProductModel _productForm = const ProductModel(id: '', name: '', price: 0.0);
  File? _productImage;

  EcommerceViewModel(this._authService, this._networkService) {
    _loadUser();
  }

  // Getters
  UserModel? get currentUser => _currentUser;
  String get errorMessage => _errorMessage;
  List<UserModel> get customers => _customers;
  List<ProductModel> get products => _products;
  List<OrderModel> get orders => _orders;
  List<Map<String, dynamic>> get cart => _cart;
  bool get isLoading => _isLoading;
  bool get loginSuccess => _loginSuccess;
  UserModel get loginForm => _loginForm;
  UserModel get customerForm => _customerForm;
  ProductModel get productForm => _productForm;
  Map<String, String>? _googleLoginCredentials;

  Map<String, String>? get googleLoginCredentials => _googleLoginCredentials;

  bool get isLoginFormValid => _loginForm.userName?.isNotEmpty == true && _loginForm.password?.isNotEmpty == true;

  bool get isCustomerFormValid => _customerForm.email?.isNotEmpty == true && _customerForm.password?.isNotEmpty == true && _customerForm.phone?.isNotEmpty == true && _customerForm.userName?.isNotEmpty == true && _customerForm.name?.isNotEmpty == true;

  bool get isProductFormValid => _productForm.name!.isNotEmpty && _productForm.price > 0;

  // Login Form Setters
  void updateLoginForm({String? userName, String? password}) {
    _loginForm = _loginForm.copyWith(userName: userName ?? _loginForm.userName, password: password ?? _loginForm.password);
    _errorMessage = '';
    notifyListeners();
  }

  // Customer Form Setters
  void updateCustomerForm({String? name, String? email, String? phone, String? userName, String? password}) {
    _customerForm = _customerForm.copyWith(name: name ?? _customerForm.name, email: email ?? _customerForm.email, phone: phone ?? _customerForm.phone, userName: userName ?? _customerForm.userName, password: password ?? _customerForm.password);
    _errorMessage = '';
    notifyListeners();
  }

  // Product Form Setters
  void updateProductForm({String? name, String? description, double? price}) {
    _productForm = _productForm.copyWith(name: name ?? _productForm.name, description: description ?? _productForm.description, price: price ?? _productForm.price);
    _errorMessage = '';
    notifyListeners();
  }

  void setProductImage(File? image) {
    _productImage = image;
    notifyListeners();
  }

  void resetLoginSuccess() {
    _loginSuccess = false;
    notifyListeners();
  }

  // Cart Methods
  void addToCart(String productId, int quantity) {
    final existingIndex = _cart.indexWhere((item) => item['productId'] == productId);
    if (existingIndex != -1) {
      _cart[existingIndex]['quantity'] += quantity;
    } else {
      _cart.add({'productId': productId, 'quantity': quantity});
    }
    notifyListeners();
  }

  void increaseCartQuantity(String productId) {
    final existingIndex = _cart.indexWhere((item) => item['productId'] == productId);
    if (existingIndex != -1) {
      _cart[existingIndex]['quantity'] += 1;
      notifyListeners();
    }
  }

  void decreaseCartQuantity(String productId) {
    final existingIndex = _cart.indexWhere((item) => item['productId'] == productId);
    if (existingIndex != -1) {
      if (_cart[existingIndex]['quantity'] > 1) {
        _cart[existingIndex]['quantity'] -= 1;
      } else {
        _cart.removeAt(existingIndex);
      }
      notifyListeners();
    }
  }

  void removeFromCart(String productId) {
    _cart.removeWhere((item) => item['productId'] == productId);
    notifyListeners();
  }

  Future<void> _loadUser() async {
    _isLoading = true;
    notifyListeners();
    _accessToken = await _authService.getAccessToken();
    if (_accessToken != null) {
      _currentUser = UserModel(id: 'temp_${_loginForm.userName?.hashCode}', name: 'Temp', email: '', phone: '', userName: _loginForm.userName, role: _loginForm.userName == 'admin' ? 'admin' : 'customer');
      if (_currentUser!.role == 'admin') {
        await fetchCustomers();
        await fetchOrders();
      } else {
        await fetchProducts();
      }
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loginWithEmailAndPassword({String? userName, String? password}) async {
    _isLoading = true;
    _loginSuccess = false;
    notifyListeners();
    try {
      final tokens = await _authService.loginWithEmailAndPassword(userName: userName ?? _loginForm.userName!, password: password ?? _loginForm.password!);
      _accessToken = tokens['accessToken'];
      _refreshToken = tokens['refreshToken'];
      _currentUser = UserModel(id: 'node_${userName?.hashCode ?? _loginForm.userName!.hashCode}', name: userName ?? _loginForm.userName, email: '', phone: '', userName: userName ?? _loginForm.userName, role: userName == 'admin' ? 'admin' : 'customer');
      if (_currentUser!.role == 'admin') {
        await fetchCustomers();
        await fetchOrders();
      } else {
        await fetchProducts();
      }
      _loginForm = const UserModel();
      _loginSuccess = true;
    } catch (e) {
      _errorMessage = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loginWithGoogle() async {
    _isLoading = true;
    _loginSuccess = false;
    notifyListeners();
    try {
      final result = await _authService.loginWithGoogle();
      final tokens = result['tokens'] as Map<String, String>;
      _accessToken = tokens['accessToken'];
      _refreshToken = tokens['refreshToken'];
      _currentUser = UserModel(id: 'oauth_${DateTime.now().millisecondsSinceEpoch}', name: result['name'], email: result['email'], phone: 'N/A', userName: 'google_${DateTime.now().millisecondsSinceEpoch}', role: 'customer');
      _googleLoginCredentials = {'user_name': result['email'] ?? '', 'password': '1234'};
      await fetchProducts();
      _loginSuccess = true;
    } catch (e) {
      print('Google Sign-In failed: $e');
      _errorMessage = 'Google Sign-In failed: $e';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> signUp(BuildContext context) async {
    _isLoading = true;
    notifyListeners();
    try {
      final customer = _customerForm.copyWith(id: 'temp_${DateTime.now().millisecondsSinceEpoch}', role: 'customer');

      print('Customer: $customer');
      await _networkService.register(customer);
      // naviagte to login page
      Navigator.pushNamed(context, '/login');

      // _customers = await _networkService.fetchCustomers(_accessToken!);
      _customerForm = const UserModel();
    } catch (e) {
      _errorMessage = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addCustomer() async {
    _isLoading = true;
    notifyListeners();
    try {
      final customer = _customerForm.copyWith(id: 'temp_${DateTime.now().millisecondsSinceEpoch}');
      await _networkService.addCustomer(_accessToken!, customer);
      _customers = await _networkService.fetchCustomers(_accessToken!);
      _customerForm = const UserModel();
    } catch (e) {
      print('Error adding customer: $e');
      _errorMessage = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchCustomers() async {
    try {
      _customers = await _networkService.fetchCustomers(_accessToken!);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to fetch customers: $e';
    }
  }

  Future<void> addProduct() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _networkService.addProduct(_accessToken!, _productForm, _productImage);
      _productForm = const ProductModel(id: '', name: '', price: 0.0);
      _productImage = null;
    } catch (e) {
      _errorMessage = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchProducts() async {
    try {
      _products = await _networkService.fetchProducts();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to fetch products: $e';
    }
  }

  Future<void> createOrder() async {
    if (_cart.isEmpty) {
      _errorMessage = 'Cart is empty';
      notifyListeners();
      return;
    }
    _isLoading = true;
    notifyListeners();
    try {
      await _networkService.createOrder(_accessToken!, _cart);
      _cart.clear();
    } catch (e) {
      _errorMessage = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchOrders() async {
    try {
      _orders = await _networkService.fetchOrders(_accessToken!);
      notifyListeners();
    } catch (e) {
      print('Failed to fetch orders: $e');
      _errorMessage = 'Failed to fetch orders: $e';
    }
  }

  bool _isPasswordVisible = false;
  bool get isPasswordVisible => _isPasswordVisible;

  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  Future<void> logout() async {
    await _authService.signOut();
    _currentUser = null;
    _loginForm = const UserModel();
    _customerForm = const UserModel();
    _errorMessage = '';
    _accessToken = null;
    _refreshToken = null;
    _customers = [];
    _products = [];
    _orders = [];
    _cart = [];
    _loginSuccess = false;
    _productForm = const ProductModel(id: '', name: '', price: 0.0);
    _productImage = null;
    notifyListeners();
  }
}
