import 'package:flutter/material.dart';
import 'package:flutter_security/features/auth/view_model/auth_vm.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<AuthenticationViewModel>(context);
    if (vm.user != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/home');
      });
      return Container();
    }
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(decoration: InputDecoration(labelText: 'Username'), onChanged: vm.setUserName),
            TextField(decoration: InputDecoration(labelText: 'Password'), obscureText: true, onChanged: vm.setPassword),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: vm.isLoginFormValid ? vm.loginWithEmailAndPassword : null,
              child: Text('Login with Username'),
            ),
            ElevatedButton(onPressed: vm.loginWithGoogle, child: Text('Login with Google')),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/customer-registration'),
              child: Text('Register'),
            ),
            if (vm.errorMessage.isNotEmpty) Text(vm.errorMessage, style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}