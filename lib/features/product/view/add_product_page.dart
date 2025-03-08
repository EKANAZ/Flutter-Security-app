// features/ecommerce/view/add_product_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_security/features/customer/view/add_customer_page.dart';
import 'package:flutter_security/features/product/view_model/add_product.dart';
import 'package:provider/provider.dart';
import 'dart:io';

class AddProductPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<EcommerceViewModel>(context);
    if (vm.currentUser?.role != 'admin') {
      WidgetsBinding.instance.addPostFrameCallback((_) => Navigator.pushNamed(context, '/login'));
      return Container();
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE0F7E7), // Light mint green
              Color(0xFFE5E1FA), // Light lavender
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 24),
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(24)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back button
                    GestureDetector(onTap: () => Navigator.pop(context), child: Icon(Icons.arrow_back, color: Colors.black)),
                    SizedBox(height: 20),

                    // Heading
                    Text('Add New Product', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)),
                    SizedBox(height: 8),
                    Text('Manage product inventory', style: TextStyle(fontSize: 14, color: Colors.black54)),
                    SizedBox(height: 32),

                    SizedBox(height: 20),

                    buildFormLabel('Product Name'),
                    buildTextField(hintText: 'Product Name', onChanged: (value) => vm.updateProductForm(name: value)),
                    SizedBox(height: 20),

                    buildFormLabel('Description'),
                    buildTextField(hintText: 'Description', onChanged: (value) => vm.updateProductForm(description: value)),
                    SizedBox(height: 20),

                    buildFormLabel('price'),
                    buildTextField(hintText: 'Price', onChanged: (value) => vm.updateProductForm(price: double.tryParse(value) ?? 0.0)),
                    SizedBox(height: 20),

                    SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (vm.isProductFormValid) {
                            await vm.addProduct();
                            if (vm.errorMessage.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Product added successfully')));
                              Navigator.pop(context);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(vm.errorMessage)));
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please fill all fields correctly')));
                          }
                        },
                        child: vm.isLoading ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : Text('Add Product'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
