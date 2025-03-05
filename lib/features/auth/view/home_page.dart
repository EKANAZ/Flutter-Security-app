import 'package:flutter/material.dart';
import 'package:flutter_security/features/auth/view_model/auth_vm.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<AuthenticationViewModel>(context);
    if (vm.user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login');
      });
      return Container();
    }
    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome, ${vm.user!.userName ?? vm.user!.email}!'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/customer-registration'),
              child: Text('Register Customer'),
            ),
            ElevatedButton(
              onPressed: vm.logout,
              child: Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}