import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../domain/models/ProductData.dart';

class ProductCart extends StatelessWidget {
  final VoidCallback onTap;
  final ProductData product;

  const ProductCart({
    super.key,
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isActive = product.isActive;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.dividerColor,
        ),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 170,
                width: double.infinity,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: _buildProductImage(),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                product.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 6),
              Text(
                product.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium,
              ),
              const Spacer(),
              Chip(
                label: Text(isActive ? 'Есть в наличии' : 'Нет в наличии'),
                avatar: Icon(
                  isActive ? Icons.done_rounded : Icons.cancel_rounded,
                  color: isActive ? Colors.green : Colors.red,
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductImage() {
    final imagePath = product.linkImage.trim();

    if (imagePath.isEmpty) {
      return const Center(child: Icon(Icons.broken_image_outlined, size: 36));
    }

    if (imagePath.startsWith('assets/')) {
      return Image.asset(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) =>
        const Center(child: Icon(Icons.broken_image_outlined, size: 36)),
      );
    }

    final file = File(imagePath);
    if (file.existsSync()) {
      return Image.file(
        file,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) =>
        const Center(child: Icon(Icons.broken_image_outlined, size: 36)),
      );
    }
    return const Center(child: Icon(Icons.broken_image_outlined, size: 36));
  }
}
