import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:mini_project_9ach/widgets/custom_appbar.widget.dart';
import 'package:mini_project_9ach/widgets/custom_drawer.widget.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String? userEmail;

  @override
  void initState() {
    super.initState();
    loadUserEmail();
  }

  Future<void> loadUserEmail() async {
    final box = Hive.box('users');

    // Ici, on prend le premier utilisateur comme "connecté"
    // ou tu peux utiliser une clé spécifique pour l'utilisateur actif
    if (box.isNotEmpty) {
      setState(() {
        userEmail = box.keys.first; // email est la clé de l'utilisateur
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: userEmail != null
          ? CustomDrawer(userEmail: userEmail!)
          : null, // attend que l'email soit chargé
      appBar: const CustomAppBar(),
      body: const Center(
        child: Text('Checkout Page'),
      ),
    );
  }
}
