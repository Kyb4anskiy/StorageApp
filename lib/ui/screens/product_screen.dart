import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/domain/models/ProductData.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ProductScreen extends StatefulWidget {
  final ProductData product;

  const ProductScreen({
    super.key,
    required this.product,
  });

  @override
  State<ProductScreen> createState() => _ProductScreen();
}


class _ProductScreen extends State<ProductScreen> {

  String? _qrData;
  PlatformFile? _pickedFile;
  String? _imageError;
  late ProductData product = widget.product;

  @override
  Widget build(BuildContext context) {
    final isActive = product.isActive;

    return Scaffold(
      appBar: AppBar(
        title: Text('${product.id}'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                product.description,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    color: Colors.grey.shade200,
                    child: _buildProductImage(),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Chip(
                label: Text(isActive ? 'Есть в наличии' : 'Нет в наличии'),
                avatar: Icon(
                  isActive ? Icons.done_rounded : Icons.cancel_rounded,
                  color: isActive ? Colors.green : Colors.red,
                ),
              ),
            SizedBox(
              height: 46,
              child: ElevatedButton(
                onPressed: _generateQr,
                child: Text('Сгенерировать QR'),
              ),
            ),
            if (_qrData != null) ...[
              const SizedBox(height: 16),
              Center(
                child: QrImageView(
                  data: _qrData!,
                  version: QrVersions.auto,
                  size: 220,
                ),
              ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductImage() {
    final imagePath = product.linkImage.trim();

    if (imagePath.isEmpty) {
      return const Center(child: Icon(Icons.broken_image_outlined, size: 48));
    }

    if (imagePath.startsWith('assets/')) {
      return Image.asset(
        imagePath,
        fit: BoxFit.cover
      );
    }

    if (!kIsWeb) {
      final file = File(imagePath);
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: BoxFit.cover
        );
      }
    }

    return const Center(child: Icon(Icons.broken_image_outlined, size: 48));
  }

  void _generateQr() {

    final payload = {
      'id': product.id,
      'title': product.title,
      'description': product.description,
      'isActive': product.isActive,
    };

    setState(() {
      _qrData = jsonEncode(payload);
    });
  }

}
