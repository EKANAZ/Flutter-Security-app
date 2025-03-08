import 'package:flutter/material.dart';
import 'package:flutter_security/models/order_model.dart';
import 'package:provider/provider.dart';
import 'package:flutter_security/features/product/view_model/add_product.dart';

class CustomerHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<EcommerceViewModel>(context);

    if (vm.currentUser?.role != 'customer') {
      WidgetsBinding.instance.addPostFrameCallback((_) => Navigator.pushReplacementNamed(context, '/login'));
      return Container();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Shop'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          IconButton(icon: Stack(children: [Icon(Icons.shopping_cart), if (vm.cart.isNotEmpty) Positioned(right: 0, child: CircleAvatar(radius: 8, backgroundColor: Colors.red, child: Text('${vm.cart.length}', style: TextStyle(fontSize: 12, color: Colors.white))))]), onPressed: () => _showCartScreen(context, vm)),
          IconButton(icon: Icon(Icons.logout), onPressed: vm.logout),
        ],
      ),
      body: Column(
        children: [
          // Google login credentials banner
          if (vm.googleLoginCredentials != null) Container(padding: const EdgeInsets.all(16.0), color: Colors.blue[50], child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Welcome, ${vm.currentUser!.name ?? 'Customer'}!', style: Theme.of(context).textTheme.titleLarge), SizedBox(height: 8), Text('Your login credentials:', style: TextStyle(fontWeight: FontWeight.bold)), SizedBox(height: 4), Text('Username: ${vm.googleLoginCredentials!['user_name']}'), Text('Password: ${vm.googleLoginCredentials!['password']}'), SizedBox(height: 8), Text('Note: These credentials are for your reference only.', style: TextStyle(fontSize: 12, color: Colors.grey))])),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: vm.products.length,
              itemBuilder: (context, index) {
                final product = vm.products[index];
                return Card(
                  elevation: 2,
                  margin: EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(12),
                    leading: ClipRRect(borderRadius: BorderRadius.circular(8), child: product.imageUrl != null ? Image.network('https://test.ekanas.com${product.imageUrl}', width: 60, height: 60, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => Container(width: 60, height: 60, color: Colors.grey[200], child: Icon(Icons.image, color: Colors.grey))) : Container(width: 60, height: 60, color: Colors.grey[200], child: Icon(Icons.image, color: Colors.grey))),
                    title: Text(product.name ?? "", style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [SizedBox(height: 4), Text(product.description ?? 'No description', maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12)), SizedBox(height: 8), Text('\$${product.price.toStringAsFixed(2)}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black))]),
                    trailing: ElevatedButton(
                      onPressed: () {
                        vm.addToCart(product.id, 1);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${product.name} added to cart')));
                      },
                      child: Text('Add'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white, padding: EdgeInsets.symmetric(horizontal: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showCartScreen(BuildContext context, EcommerceViewModel vm) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => CartPage(viewModel: vm)));
  }
}

class CartPage extends StatefulWidget {
  final EcommerceViewModel viewModel;

  const CartPage({Key? key, required this.viewModel}) : super(key: key);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  Widget build(BuildContext context) {
    final vm = widget.viewModel;
    final double total = vm.cart.fold(0.0, (sum, item) {
      final product = vm.products.firstWhere((p) => p.id == item['productId']);
      return sum + (product.price * item['quantity']);
    });

    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(title: Text('My Cart'), backgroundColor: Colors.transparent, elevation: 0, foregroundColor: Colors.black, centerTitle: true, leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context))),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child:
                  vm.cart.isEmpty
                      ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey), SizedBox(height: 16), Text('Your cart is empty', style: TextStyle(fontSize: 18, color: Colors.grey[700]))]))
                      : ListView.builder(
                        padding: EdgeInsets.all(16),
                        itemCount: vm.cart.length,
                        itemBuilder: (context, index) {
                          final cartItem = vm.cart[index];
                          final product = vm.products.firstWhere((p) => p.id == cartItem['productId'], orElse: () => ProductModel(id: '', name: 'Unknown', price: 0.0));

                          return Card(
                            elevation: 0,
                            color: Colors.white,
                            margin: EdgeInsets.only(bottom: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  // Product image
                                  ClipRRect(borderRadius: BorderRadius.circular(8), child: product.imageUrl != null ? Image.network('https://test.ekanas.com${product.imageUrl}', width: 80, height: 80, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => Container(width: 80, height: 80, color: Colors.grey[200], child: Icon(Icons.image, color: Colors.grey))) : Container(width: 80, height: 80, color: Colors.grey[200], child: Icon(Icons.image, color: Colors.grey))),
                                  SizedBox(width: 16),
                                  // Product details
                                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(product.name ?? "", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), SizedBox(height: 4), Text('Size: ${product.size ?? 'Standard'}', style: TextStyle(color: Colors.grey[600], fontSize: 12)), Text('Color: ${product.color ?? 'Standard'}', style: TextStyle(color: Colors.grey[600], fontSize: 12)), SizedBox(height: 8), Text('\$${product.price.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))])),
                                  // Quantity controls
                                  Container(
                                    decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.remove, size: 16),
                                          constraints: BoxConstraints(minWidth: 32, minHeight: 32),
                                          padding: EdgeInsets.zero,
                                          onPressed: () {
                                            vm.decreaseCartQuantity(product.id);
                                            setState(() {});
                                          },
                                        ),
                                        Text('${cartItem['quantity']}', style: TextStyle(fontWeight: FontWeight.bold)),
                                        IconButton(
                                          icon: Icon(Icons.add, size: 16),
                                          constraints: BoxConstraints(minWidth: 32, minHeight: 32),
                                          padding: EdgeInsets.zero,
                                          onPressed: () {
                                            vm.increaseCartQuantity(product.id);
                                            setState(() {});
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
            ),
            // Total and Checkout button
            if (vm.cart.isNotEmpty)
              Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, -5))]),
                child: Column(
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Total', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)), Text('\$${total.toStringAsFixed(2)}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))]),
                    SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () async {
                          await vm.createOrder();
                          Navigator.pop(context);
                          if (vm.errorMessage.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Order placed successfully')));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(vm.errorMessage)));
                          }
                        },
                        child: vm.isLoading ? SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : Text('Buy now'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Extension for product model to support the new UI
extension ProductModelExtension on ProductModel {
  String? get size => null; // This would need to be added to your model
  String? get color => null; // This would need to be added to your model
}
