import 'package:flutter/material.dart';
import 'package:flutter_security/core/network_helper.dart';
import 'package:flutter_security/features/customer/view/add_customer_page.dart';
import 'package:flutter_security/features/product/view/add_product_page.dart';
import 'package:flutter_security/features/product/view_model/add_product.dart';
import 'package:provider/provider.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<EcommerceViewModel>(context);
    final theme = Theme.of(context);

    // Redirect if not admin
    if (vm.currentUser?.role != 'admin') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login');
      });
      return Container();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () async {
              await vm.fetchOrders();
              await vm.fetchCustomers();
              await vm.fetchProducts(); // Added to refresh products
            },
            tooltip: 'Refresh Data',
          ),
          IconButton(icon: Icon(Icons.logout), onPressed: vm.logout, tooltip: 'Logout'),
        ],
      ),

      body: _buildDashboardContent(context, vm, theme),
    );
  }

  // App Bar with profile section
  SliverAppBar _buildAppBar(BuildContext context, EcommerceViewModel vm, ThemeData theme) {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      floating: true,
      backgroundColor: theme.primaryColor,
      flexibleSpace: FlexibleSpaceBar(
        title: Text('Admin Dashboard', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        background: Container(
          decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [theme.primaryColor, theme.primaryColor.withOpacity(0.7)])),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0, bottom: 50.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    CircleAvatar(backgroundColor: Colors.white.withOpacity(0.9), radius: 24, child: Text((vm.currentUser?.name?[0] ?? vm.currentUser?.userName?[0] ?? 'A').toUpperCase(), style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: theme.primaryColor))),
                    const SizedBox(width: 12),
                    Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Welcome,', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14)), Text(vm.currentUser?.name ?? vm.currentUser?.userName ?? 'Admin', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))]),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      actions: [
        if (vm.isLoading) Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))),
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () async {
            await vm.fetchOrders();
            await vm.fetchCustomers();
            await vm.fetchProducts();
          },
          tooltip: 'Refresh Data',
        ),
        IconButton(icon: const Icon(Icons.logout), onPressed: vm.logout, tooltip: 'Logout'),
        const SizedBox(width: 8),
      ],
    );
  }

  // Main dashboard content
  Widget _buildDashboardContent(BuildContext context, EcommerceViewModel vm, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [ElevatedButton.icon(icon: Icon(Icons.person_add), label: Text('Add Customer'), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddCustomerPage())), style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12))), ElevatedButton.icon(icon: Icon(Icons.add_shopping_cart), label: Text('Add Product'), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddProductPage())), style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12)))]),

          // Dashboard Cards
          SizedBox(height: 20),
          _buildStatCards(context, vm),
          const SizedBox(height: 24),

          // Sections
          _buildOrdersSection(context, vm, theme),
          const SizedBox(height: 24),

          _buildProductsSection(context, vm, theme),
          const SizedBox(height: 24),

          _buildCustomersSection(context, vm, theme),
        ],
      ),
    );
  }

  // Stat Cards Row
  Widget _buildStatCards(BuildContext context, EcommerceViewModel vm) {
    return GridView.count(crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), children: [_buildStatCard(context, 'Orders', vm.orders.length.toString(), Icons.shopping_bag_outlined, Colors.blue), _buildStatCard(context, 'Products', vm.products.length.toString(), Icons.inventory_2_outlined, Colors.amber), _buildStatCard(context, 'Customers', vm.customers.length.toString(), Icons.people_outline, Colors.green)]);
  }

  // Individual Stat Card
  Widget _buildStatCard(BuildContext context, String title, String count, IconData icon, Color color) {
    return Card(elevation: 4, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.3), width: 1)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, size: 32, color: color), const SizedBox(height: 8), Text(count, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)), const SizedBox(height: 4), Text(title, style: TextStyle(fontSize: 14, color: Colors.grey[700]), textAlign: TextAlign.center)])));
  }

  // Orders Section
  Widget _buildOrdersSection(BuildContext context, EcommerceViewModel vm, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, 'Orders', Icons.receipt_long, Colors.blue),
        if (vm.orders.isEmpty)
          _buildEmptyState('No orders yet')
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: vm.orders.length,
            itemBuilder: (context, index) {
              final order = vm.orders[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ExpansionTile(
                  leading: CircleAvatar(backgroundColor: _getStatusColor(order.status ?? "").withOpacity(0.2), child: Icon(Icons.shopping_bag, color: _getStatusColor(order.status ?? ""))),
                  title: Text('Order #${order.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  // subtitle: Row(children: [Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: _getStatusColor(order.status ??"").withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Text(order.status ? "", style: TextStyle(color: _getStatusColor(order.status), fontSize: 12))), const SizedBox(width: 8), Text('\$${order.totalAmount.toStringAsFixed(2)}')]),
                  trailing: const Icon(Icons.expand_more),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [const Icon(Icons.person_outline, size: 16, color: Colors.grey), const SizedBox(width: 4), Text('Customer: ${order.userId?.name  ?? order.userId?.userName}', style: const TextStyle(fontSize: 14))]),
                          const SizedBox(height: 4),
                          Row(children: [const Icon(Icons.email_outlined, size: 16, color: Colors.grey), const SizedBox(width: 4), Text('Email: ${order.userId?.email}', style: const TextStyle(fontSize: 14))]),
                          const Divider(height: 16),
                          const Text('Products:', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          ...?order.products?.map((p) => Padding(padding: const EdgeInsets.only(bottom: 4.0), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Expanded(child: Text('• ${p.productId?.name}', overflow: TextOverflow.ellipsis)), Text('x${p.quantity}', style: const TextStyle(color: Colors.grey)), const SizedBox(width: 8), Text('\$${(p.productId.price  * p.quantity).toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold))]))),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  // Products Section
  Widget _buildProductsSection(BuildContext context, EcommerceViewModel vm, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, 'Products', Icons.inventory_2, Colors.amber),
        if (vm.products.isEmpty)
          _buildEmptyState('No products yet')
        else
          GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.8, crossAxisSpacing: 10, mainAxisSpacing: 10),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: vm.products.length,
            itemBuilder: (context, index) {
              final product = vm.products[index];
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Image
                    Container(height: 120, decoration: BoxDecoration(borderRadius: const BorderRadius.vertical(top: Radius.circular(12)), color: Colors.grey[200]), child: Center(child: product.imageUrl != null ? Image.network('https://test.ekanas.com${product.imageUrl}', height: 120, width: double.infinity, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => const Icon(Icons.image, size: 50, color: Colors.grey)) : const Icon(Icons.image, size: 50, color: Colors.grey))),
                    // Product Details
                    Padding(padding: const EdgeInsets.all(12.0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(product.name ?? "", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis), const SizedBox(height: 4), Text('\$${product.price}', style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold)), const SizedBox(height: 4), if (product.description != null) Text(product.description!, style: TextStyle(fontSize: 12, color: Colors.grey[600]), maxLines: 2, overflow: TextOverflow.ellipsis)])),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  // Customers Section
  Widget _buildCustomersSection(BuildContext context, EcommerceViewModel vm, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, 'Customers', Icons.people, Colors.green),
        if (vm.customers.isEmpty)
          _buildEmptyState('No customers yet')
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: vm.customers.length,
            itemBuilder: (context, index) {
              final customer = vm.customers[index];
              final initials = (customer.name?[0] ?? customer.userName?[0] ?? 'U').toUpperCase();

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(backgroundColor: Colors.green.withOpacity(0.2), child: Text(initials, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold))),
                  title: Text(customer.name ?? customer.userName ?? 'Unnamed Customer', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Row(children: [const Icon(Icons.email_outlined, size: 14, color: Colors.grey), const SizedBox(width: 4), Text(customer.email ?? 'N/A', style: const TextStyle(fontSize: 13))]),
                      if (customer.phone != null) ...[
                        const SizedBox(height: 2),
                        Row(children: [const Icon(Icons.phone_outlined, size: 14, color: Colors.grey), const SizedBox(width: 4), Text(customer.phone!, style: const TextStyle(fontSize: 13))]),
                      ],
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.arrow_forward_ios, size: 16),
                    onPressed: () {
                      // View customer details action
                      // Could be implemented later
                    },
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  // Section Header
  Widget _buildSectionHeader(BuildContext context, String title, IconData icon, Color color) {
    return Padding(padding: const EdgeInsets.only(bottom: 16.0), child: Row(children: [Icon(icon, color: color, size: 24), const SizedBox(width: 8), Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[800]))]));
  }

  // Empty State Widget
  Widget _buildEmptyState(String message) {
    return Container(padding: const EdgeInsets.all(32.0), alignment: Alignment.center, child: Column(children: [Icon(Icons.inbox_outlined, size: 48, color: Colors.grey[400]), const SizedBox(height: 16), Text(message, style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic, fontSize: 16), textAlign: TextAlign.center)]));
  }

  // Get color for order status
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.red;
      case 'pending':
        return Colors.red;
      case 'processing':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Dialog for add options
  void _showAddOptionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Add New'),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const CircleAvatar(backgroundColor: Colors.green, child: Icon(Icons.person_add, color: Colors.white)),
                  title: const Text('Add Customer'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => AddCustomerPage()));
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const CircleAvatar(backgroundColor: Colors.amber, child: Icon(Icons.add_shopping_cart, color: Colors.white)),
                  title: const Text('Add Product'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => AddProductPage()));
                  },
                ),
              ],
            ),
            actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel'))],
          ),
    );
  }
}
