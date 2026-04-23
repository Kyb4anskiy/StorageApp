import 'package:flutter/material.dart';
import 'package:flutter_app/ui/screens/product_screen.dart';
import 'package:flutter_app/ui/screens/scanQR_screen.dart';
import 'package:flutter_app/ui/widgets/productCart.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../data/HelperDB.dart';
import '../../domain/models/ProductData.dart';
import '../../domain/models/UserData.dart';
import '../../main.dart';
import 'add_product_screen.dart';
import 'auth_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();

}

class _HomeScreenState extends State<HomeScreen> with RouteAware {

  List<ProductData> _products = [];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Каталог товаров'),
        actions: [
          IconButton(
            icon: Icon(Icons.qr_code_scanner),
            tooltip: 'Сканировать QR',
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ScanQrScreen()),
              );
              if (result is ProductData) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProductScreen(product: result)),
                );
              }
            },
          ),
          if (UserData.getUser()?.roleId == 1)
            IconButton(
              icon: Icon(Icons.add),
              tooltip: 'Добавить товар',
              onPressed: () async {
                final result = await Navigator.push(
                context,
                  MaterialPageRoute(builder: (context) => AddProductScreen()),
                );
                if (result == true) {
                  await _loadProducts();
                }
              },
            ),
          IconButton(
            onPressed: logOut,
            icon: Icon(
              Icons.logout,
              size: 22,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Товаров в каталоге: ${_products.length}',
                style: theme.textTheme.bodyLarge?.copyWith(fontSize: 18),
              ),
              const SizedBox(height: 4),
              GridView.builder(
                itemCount: _products.length,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 5,
                  childAspectRatio: 0.49,
                ),
                itemBuilder: (context, index) {
                  final product = _products[index];
                  return ProductCart(
                    product: product,
                    onTap: () => openProductCard(product),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void openProductCard(ProductData product) {
    Navigator.push(context, MaterialPageRoute(
      builder: (context) => ProductScreen(product: product),
      ),
    );
  }

  void logOut(){
    UserData.clear();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const AuthScreen()),
          (route) => false,
    );
  }

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void didPopNext() {
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final rows = await HelperDB.instance.getAllProducts();
      setState(() {
        _products = rows.map((p) => ProductData.fromMap(p)).toList();
      });
    } catch (e){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e'), backgroundColor: Colors.red),
      );
    }
  }

}
