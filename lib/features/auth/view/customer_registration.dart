import 'package:flutter/material.dart';
import 'package:flutter_security/core/network_helper.dart';
import 'package:flutter_security/core/validation_helper.dart';
import 'package:flutter_security/features/auth/view_model/auth_vm.dart';
import 'package:provider/provider.dart';

class CustomerRegistrationPage extends StatelessWidget {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _userNameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<AuthenticationViewModel>(context);
    return Scaffold(
      appBar: AppBar(title: Text('Customer Registration')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: 'Phone Number (10 digits)'),
              keyboardType: TextInputType.phone,
            ),
            TextField(
              controller: _userNameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
          
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final name = _nameController.text;
                final email = _emailController.text;
                final phone = _phoneController.text;
                final userName = _userNameController.text;
                final password = _passwordController.text;
                if (ValidationHelper.isValidEmail(email) &&
                    ValidationHelper.isValidPhoneNumber(phone) &&
                    ValidationHelper.isValidUserName(userName) &&
                    ValidationHelper.isValidPassword(password)) {
                  vm.setEmail(email);
                  vm.setPhone(phone);
                  vm.setUserName(userName);
                  vm.setPassword(password);
                  try {
                    await vm.registerUser();
                    final response = await NetworkHelper.registerCustomer(
                      token: await vm.getAccessToken() ?? '',
                      name: name,
                      email: email,
                      phoneNumber: phone,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response['message'])));
                    Navigator.pushReplacementNamed(context, '/home');
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invalid input')));
                }
              },
              child: Text('Register Customer'),
            ),
            if (vm.errorMessage.isNotEmpty) Text(vm.errorMessage, style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}