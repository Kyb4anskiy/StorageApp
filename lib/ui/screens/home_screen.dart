import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_app/ui/screens/product_screen.dart';
import 'package:flutter_app/ui/screens/scanQR_screen.dart';
import 'package:flutter_app/ui/widgets/productCart.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../domain/models/ProductData.dart';
import 'add_product_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();

}

class _HomeScreenState extends State<HomeScreen> {


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
          IconButton(
            icon: Icon(Icons.add),
            tooltip: 'Добавить товар',
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddProductScreen()),
              );
              if (result == true) {
                setState(() {});
              }
            },
          ),
          IconButton(
            onPressed: () async {
              await openAppSettings();
            },
            icon: Icon(
              Icons.lock_reset_outlined,
              size: 16,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                'Товаров в каталоге: ${products.length}',
                style: theme.textTheme.bodyLarge?.copyWith(fontSize: 18),
              ),
              const SizedBox(height: 4),
              GridView.builder(
                itemCount: products.length,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 5,
                  childAspectRatio: 0.45,
                ),
                itemBuilder: (context, index) {
                  final product = products[index];
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

}
