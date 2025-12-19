
import 'package:flutter/material.dart';
import 'package:mini_project_9ach/models/product.model.dart';
import 'package:mini_project_9ach/utils/constants.dart';

class RecommendedSection extends StatelessWidget {
  final List<Product> recommendedProducts;
  final bool isLoading;

  const RecommendedSection({
    super.key,
    required this.recommendedProducts,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (recommendedProducts.isEmpty) {
      return const SizedBox.shrink(); // Ne rien afficher si pas de recommandations
    }

    return Column(
      children: [
        // Titre centré
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Center(
            child: Column(
              children: [
                Text(
                  'RECOMMANDÉ POUR VOUS',
                  style: TextStyle(
                    fontSize: 20,
                    letterSpacing: 8,
                    color: primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Image.asset("assets/images/bar.png", height: 12),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Liste horizontale des produits recommandés
        SizedBox(
          height: 300,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: recommendedProducts.length,
            itemBuilder: (context, index) {
              final product = recommendedProducts[index];

              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: SizedBox(
                  width: 180,
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(16)),
                          child: Image.network(
                            product.image,
                            height: 140,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              height: 140,
                              color: Colors.grey[300],
                              child: const Icon(Icons.image_not_supported,
                                  size: 50),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${product.price.toStringAsFixed(2)} €",
                                style: TextStyle(
                                    color: primaryColor,
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.star,
                                      size: 16, color: Colors.amber),
                                  Text(" ${product.rating}",
                                      style: const TextStyle(fontSize: 12)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}