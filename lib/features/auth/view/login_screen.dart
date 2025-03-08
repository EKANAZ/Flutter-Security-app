import 'package:flutter/material.dart';
import 'package:flutter_security/features/customer/view/add_customer_page.dart';
import 'package:flutter_security/features/product/view_model/add_product.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<EcommerceViewModel>(context);
    final screenSize = MediaQuery.of(context).size;

    if (vm.loginSuccess) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, vm.currentUser!.role == 'admin' ? '/admin' : '/customer');
        vm.resetLoginSuccess();
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SingleChildScrollView(
        child: Container(
          height: screenSize.height,
          child: Row(
            children: [
              // Left side with illustration - only show on larger screens
              if (screenSize.width > 800)
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD8B4FE), // Light purple color like in the image
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Illustration would go here
                        Image.asset(
                          'assets/images/login_illustration.png', // Add your illustration
                          height: 280,
                        ),
                        const SizedBox(height: 40),
                        Padding(padding: const EdgeInsets.symmetric(horizontal: 40), child: Column(children: [Text('Discover your Dream Job Here', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87), textAlign: TextAlign.center), const SizedBox(height: 16), Text('Explore all the most exciting jobs roles based on your interest. And study major.', style: TextStyle(fontSize: 14, color: Colors.black54), textAlign: TextAlign.center)])),
                        const SizedBox(height: 40),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                // Navigate to register page
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black87, padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), elevation: 0),
                              child: const Text('Register', style: TextStyle(fontWeight: FontWeight.w500)),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton(
                              onPressed: () {
                                // Already on login page
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.black.withOpacity(0.1), foregroundColor: Colors.black87, padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), elevation: 0),
                              child: const Text('Sign In', style: TextStyle(fontWeight: FontWeight.w500)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

              // Right side with login form
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(30),
                  child: Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Hello Again!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87)),
                          const SizedBox(height: 12),
                          Text('Welcome back you\'ve been missed!', style: TextStyle(fontSize: 16, color: Colors.black54)),
                          const SizedBox(height: 40),

                          // Username field
                          Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 2))]), child: TextField(onChanged: (value) => vm.updateLoginForm(userName: value), decoration: InputDecoration(hintText: 'Enter username', hintStyle: TextStyle(color: Colors.black38), contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16), border: InputBorder.none))),
                          const SizedBox(height: 16),

                          // Password field
                          Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 2))]), child: TextField(onChanged: (value) => vm.updateLoginForm(password: value), obscureText: !vm.isPasswordVisible, decoration: InputDecoration(hintText: 'Password', hintStyle: TextStyle(color: Colors.black38), contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16), border: InputBorder.none, suffixIcon: IconButton(icon: Icon(vm.isPasswordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.black45, size: 20), onPressed: vm.togglePasswordVisibility)))),

                          // Recovery password text
                          Align(alignment: Alignment.centerRight, child: Padding(padding: const EdgeInsets.only(top: 12, bottom: 24), child: Text('Recovery Password', style: TextStyle(fontSize: 13, color: Colors.black54)))),

                          // Sign in button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed:
                                  vm.isLoginFormValid && !vm.isLoading
                                      ? () async {
                                        await vm.loginWithEmailAndPassword();
                                        if (vm.errorMessage.isNotEmpty) {
                                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(vm.errorMessage)));
                                        }
                                      }
                                      : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFEF5350), // Red color like in the image
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                elevation: 0,
                              ),
                              child: vm.isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white))) : const Text('Sign In', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                            ),
                          ),

                          // Or continue with
                          Padding(padding: const EdgeInsets.symmetric(vertical: 24), child: Row(children: [Expanded(child: Divider(color: Colors.black12, thickness: 1)), Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text('Or continue with', style: TextStyle(fontSize: 13, color: Colors.black45))), Expanded(child: Divider(color: Colors.black12, thickness: 1))])),

                          // Social login buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _socialLoginButton(
                                'https://th.bing.com/th/id/OIP.Fll7WPtNT6jrz1oBP8GbCgHaHj?rs=1&pid=ImgDetMain',
                                onTap:
                                    !vm.isLoading
                                        ? () async {
                                          await vm.loginWithGoogle();
                                          if (vm.errorMessage.isNotEmpty) {
                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(vm.errorMessage)));
                                          }
                                        }
                                        : null,
                              ),
                              const SizedBox(width: 16),
                              // _socialLoginButton(
                              //   'assets/images/apple_icon.png',
                              //   onTap: () {
                              //     // Apple login logic
                              //   },
                              // ),
                              // const SizedBox(width: 16),
                              // _socialLoginButton(
                              //   'assets/images/facebook_icon.png',
                              //   onTap: () {
                              //     // Facebook login logic
                              //   },
                              // ),
                            ],
                          ),

                          // Not a member text
                          // if (vm.errorMessage.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 24),
                            child: Column(
                              children: [
                                // Registration Link
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('Not a member? ', style: TextStyle(fontSize: 14, color: Colors.black54)),
                                    InkWell(
                                      onTap: () {
                                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => AddCustomerPage(isNewCustomer: true)));
                                      },
                                      child: Text('Register now', style: TextStyle(fontSize: 14, color: Colors.blue, fontWeight: FontWeight.w500)),
                                    ),
                                  ],
                                ),

                                // Login as Admin Button
                                Padding(
                                  padding: const EdgeInsets.only(top: 20),
                                  child: SizedBox(
                                    width: 150,
                                    height: 50,
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        await vm.loginWithEmailAndPassword(userName: 'admin', password: 'admin1234');
                                        if (vm.errorMessage.isNotEmpty) {
                                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(vm.errorMessage)));
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.black.withOpacity(0.1), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                                      child: const Text('Login as Admin'),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Error message
                          // if (vm.errorMessage.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 24), child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Row(children: [Icon(Icons.error_outline, color: Colors.red, size: 20), const SizedBox(width: 8), Expanded(child: Text(vm.errorMessage, style: TextStyle(color: Colors.red, fontSize: 13)))]))),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _socialLoginButton(String iconPath, {Function()? onTap}) {
    return InkWell(onTap: onTap, borderRadius: BorderRadius.circular(12), child: Container(width: 60, height: 50, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.black12, width: 1)), child: Center(child: Image.network(iconPath, height: 24, width: 24))));
  }
}
