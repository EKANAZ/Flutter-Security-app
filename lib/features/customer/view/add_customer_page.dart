// features/ecommerce/view/add_customer_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_security/features/product/view_model/add_product.dart';
import 'package:provider/provider.dart';

class AddCustomerPage extends StatelessWidget {
  bool? isNewCustomer = false;

  AddCustomerPage({this.isNewCustomer});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<EcommerceViewModel>(context);

    // if (vm.currentUser?.role != 'admin') {
    //   WidgetsBinding.instance.addPostFrameCallback((_) => Navigator.pushNamed(context, '/login'));
    //   return Container();
    // }

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
                    Text('Create New Account', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)),
                    SizedBox(height: 8),
                    Text('Sign in to manage customer accounts', style: TextStyle(fontSize: 14, color: Colors.black54)),
                    SizedBox(height: 32),

                    // Form fields
                    buildFormLabel('Name'),
                    buildTextField(hintText: 'Enter your name', onChanged: (value) => vm.updateCustomerForm(name: value)),
                    SizedBox(height: 20),

                    buildFormLabel('Email'),
                    buildTextField(
                      hintText: 'Enter your email',
                      onChanged: (value) => vm.updateCustomerForm(email: value),
                      suffixIcon: TextButton(
                        onPressed: () {
                          // Send OTP functionality would go here
                        },
                        child: Text('Send OTP', style: TextStyle(color: Colors.blue, fontSize: 12)),
                      ),
                    ),
                    SizedBox(height: 20),

                    buildFormLabel('Phone Number'),
                    buildTextField(hintText: 'Enter phone number', onChanged: (value) => vm.updateCustomerForm(phone: value)),
                    SizedBox(height: 20),

                    buildFormLabel('Username'),
                    buildTextField(hintText: 'Enter username', onChanged: (value) => vm.updateCustomerForm(userName: value)),
                    SizedBox(height: 20),

                    buildFormLabel('Password'),
                    buildTextField(hintText: 'Enter password', obscureText: true, onChanged: (value) => vm.updateCustomerForm(password: value), suffixIcon: Icon(Icons.visibility_off, color: Colors.grey)),
                    SizedBox(height: 20),

                    SizedBox(height: 32),

                    // Register button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (vm.isCustomerFormValid) {
                            if (isNewCustomer == true) {
                              await vm.signUp(context);
                              Navigator.pushNamed(context, '/login');
                            } else {
                              await vm.addCustomer();
                            }
                            if (vm.errorMessage.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Customer added successfully')));
                              Navigator.pop(context);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(vm.errorMessage)));
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please fill all required fields')));
                          }
                        },
                        child: vm.isLoading ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : Text('Register'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))),
                      ),
                    ),

                    // Already have an account
                    SizedBox(height: 20),
                    // Center(child: RichText(text: TextSpan(text: 'Already have an account? ', style: TextStyle(color: Colors.black54), children: [TextSpan(text: 'Login', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold))]))),

                    // Error message
                    // if (vm.errorMessage.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 16.0), child: Text(vm.errorMessage, style: TextStyle(color: Colors.red), textAlign: TextAlign.center)),
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

Widget buildFormLabel(String label) {
  return Padding(padding: const EdgeInsets.only(bottom: 8.0), child: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)));
}

Widget buildTextField({required String hintText, bool obscureText = false, required Function(String) onChanged, Widget? suffixIcon}) {
  return Container(decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)), child: TextField(obscureText: obscureText, onChanged: onChanged, decoration: InputDecoration(hintText: hintText, hintStyle: TextStyle(color: Colors.grey, fontSize: 14), contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12), border: InputBorder.none, suffixIcon: suffixIcon)));
}
