import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_security/core/auth_helpers.dart';
import 'package:flutter_security/core/network_helper.dart';
import 'package:flutter_security/features/auth/view/home_page.dart';
import 'package:flutter_security/features/auth/view/login_screen.dart';
import 'package:flutter_security/features/home/admin_home_page.dart';
import 'package:flutter_security/features/product/view_model/add_product.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    MultiProvider(
      providers: [
        // Provide AuthenticationService and NetworkService first
        Provider<AuthenticationService>(create: (_) => AuthenticationService()),
        Provider<NetworkService>(create: (_) => NetworkService()),

        // Now, EcommerceViewModel can safely read these services
        ChangeNotifierProvider<EcommerceViewModel>(create: (context) => EcommerceViewModel(context.read<AuthenticationService>(), context.read<NetworkService>())),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Secure Flutter App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Consumer<EcommerceViewModel>(
        builder:
            (context, vm, _) =>
                vm.currentUser != null
                    ? vm.currentUser!.role == 'admin'
                        ? AdminHomePage()
                        : CustomerHomePage()
                    : LoginPage(),
      ),
      routes: {
        '/login': (context) => LoginPage(),
        // '/signup': (context) => SignupPage(),
        '/admin': (context) => AdminHomePage(),
        '/customer': (context) => CustomerHomePage(),
      },
    );
  }
}
