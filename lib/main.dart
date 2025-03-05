import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_security/core/auth_helpers.dart';
import 'package:flutter_security/features/auth/view/customer_registration.dart';
import 'package:flutter_security/features/auth/view/home_page.dart';
import 'package:flutter_security/features/auth/view/login_screen.dart';
import 'package:flutter_security/features/auth/view_model/auth_vm.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // Create the AuthenticationService instance
  final authService = AuthenticationService();
  
  runApp(
    MultiProvider(
      providers: [
        // Provide AuthenticationService first
        Provider<AuthenticationService>.value(value: authService),
        
        // Then create AuthenticationViewModel using the provided service
        ChangeNotifierProvider<AuthenticationViewModel>(
          create: (context) => AuthenticationViewModel(
            context.read<AuthenticationService>()
          ),
        ),
      ],
      child: MyApp(),
    )
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Secure Flutter App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Consumer<AuthenticationViewModel>(
        builder: (context, vm, _) => vm.user != null ? HomePage() : LoginPage(),
      ),
      routes: {
        '/login': (context) => LoginPage(),
        '/home': (context) => HomePage(),
        '/customer-registration': (context) => CustomerRegistrationPage(),
      },
    );
  }
}