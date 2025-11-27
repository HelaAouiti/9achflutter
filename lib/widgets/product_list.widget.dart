// lib/widgets/product_list.widget.dart

import 'package:flutter/material.dart';
import '../models/product.model.dart';
import 'product_card.widget.dart';

class ProductList extends StatelessWidget {
  final List<Product> products;

  const ProductList({
    super.key,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    // Si la liste est vide (après filtre), on affiche un message
    if (products.isEmpty) {
      return const Center(
        child: Text(
          "Aucun produit trouvé",
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.68,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return ProductCard(product: products[index]);
      },
    );
  }
}
