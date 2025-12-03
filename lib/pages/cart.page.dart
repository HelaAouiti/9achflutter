// lib/pages/cart.page.dart (version finale avec Provider)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/cart.service.dart';
import 'package:mini_project_9ach/utils/constants.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  void _updateQuantity(BuildContext context, int index, int newQuantity) {
    final cartService = Provider.of<CartService>(context, listen: false);
    final product = cartService.items[index].product;
    cartService.updateQuantity(product, newQuantity);
  }

  void _removeItem(BuildContext context, int index) {
    final cartService = Provider.of<CartService>(context, listen: false);
    final product = cartService.items[index].product;
    cartService.removeFromCart(product);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Article retiré du panier"),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _clearCart(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Vider le panier"),
        content: const Text("Êtes-vous sûr de vouloir vider tout le panier ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          TextButton(
            onPressed: () {
              Provider.of<CartService>(context, listen: false).clearCart();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Panier vidé")),
              );
            },
            child: const Text("Vider", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _checkout(BuildContext context, double totalPrice) {
    final cartService = Provider.of<CartService>(context, listen: false);

    if (cartService.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Votre panier est vide")),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirmation"),
        content: Text(
          "Montant total : ${totalPrice.toStringAsFixed(2)} €\n\nVoulez-vous procéder au paiement ?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              cartService.clearCart();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Commande passée avec succès !"),
                  backgroundColor: primaryColor,
                  duration: Duration(seconds: 3),
                ),
              );
              Navigator.pop(context); // Retour à la page précédente
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 255, 255, 255)),
            child: const Text("Confirmer"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartService>(
      builder: (context, cartService, child) {
        final cartItems = cartService.items;
        final totalPrice = cartService.totalPrice;

        return Scaffold(
          appBar: AppBar(
            title: Text("Mon Panier (${cartService.itemCount})"),
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            elevation: 0,
            actions: [
              if (cartItems.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _clearCart(context),
                  tooltip: "Vider le panier",
                ),
            ],
          ),
          body: cartItems.isEmpty
              ? _buildEmptyCart(context)
              : Column(
                  children: [
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: cartItems.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          return _buildCartItem(
                            context,
                            cartItems[index],
                            index,
                          );
                        },
                      ),
                    ),
                    _buildBottomBar(context, cartItems.length, totalPrice),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 120,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 24),
          Text(
            "Votre panier est vide",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Ajoutez des articles pour commencer",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.shopping_bag),
            label: const Text("Continuer mes achats"),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(BuildContext context, item, int index) {
    return Dismissible(
      key: Key(item.product.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white, size: 32),
      ),
      onDismissed: (_) => _removeItem(context, index),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image du produit
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                item.product.image,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image_not_supported),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Informations du produit
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${item.product.price.toStringAsFixed(2)} €",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
            ),

            // Contrôles de quantité
            Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () =>
                          _updateQuantity(context, index, item.quantity - 1),
                      icon: const Icon(Icons.remove_circle_outline),
                      color: Colors.red,
                      iconSize: 28,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "${item.quantity}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () =>
                          _updateQuantity(context, index, item.quantity + 1),
                      icon: const Icon(Icons.add_circle_outline),
                      color: primaryColor,
                      iconSize: 28,
                    ),
                  ],
                ),
                Text(
                  "Total: ${(item.product.price * item.quantity).toStringAsFixed(2)} €",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(
      BuildContext context, int itemCount, double totalPrice) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Résumé du panier
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Articles ($itemCount)",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
                Text(
                  "${totalPrice.toStringAsFixed(2)} €",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Total",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "${totalPrice.toStringAsFixed(2)} €",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Bouton Commander
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _checkout(context, totalPrice),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                ),
                child: const Text(
                  "Procéder au paiement",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
