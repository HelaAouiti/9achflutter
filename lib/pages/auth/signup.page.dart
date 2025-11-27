import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mini_project_9ach/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Change cette URL selon ton environnement
  final String baseUrl = "http://10.0.2.2:5000"; // Android emulator
  // final String baseUrl = "http://localhost:3000";     // iOS / Web / Mac
  // final String baseUrl = "http://192.168.1.xx:3000";  // Ton IP locale si sur même WiFi

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final body = {
      "Prénom": firstNameController.text.trim(),
      "Nom": lastNameController.text.trim(),
      "Adresse": addressController.text.trim(),
      "Numéro_de_téléphone": phoneNumberController.text.trim(),
      "email": emailController.text.trim().toLowerCase(),
      "password": passwordController.text,
      "confirmPassword": confirmPasswordController.text,
    };

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/register"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Succès
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', data['token']);
        await prefs.setString('user_prenom', data['user']['prenom']);
        await prefs.setString('user_nom', data['user']['nom']);
        await prefs.setString('user_email', data['user']['email']);
        await prefs.setString('user_phone', data['user']['phone'].toString());
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Compte créé avec succès !"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // Erreur renvoyée par ton API
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? "Erreur inconnue")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Impossible de contacter le serveur")),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: PopScope(
        canPop: false,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // === Ton logo et texte ===
                  Container(
                    height: 230,
                    margin: const EdgeInsets.symmetric(vertical: 24),
                    child: Column(children: [
                      Image.asset('assets/images/logo.png'),
                      const SizedBox(height: 20),
                      const Text(
                        "قشش باحسن الأسوام",
                        style: TextStyle(
                            fontSize: 30,
                            color: primaryColor,
                            fontWeight: FontWeight.bold),
                      ),
                    ]),
                  ),

                  // === Prénom + Nom ===
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: firstNameController,
                          keyboardType: TextInputType.name,
                          decoration:
                              const InputDecoration(labelText: 'Prénom'),
                          validator: (v) => v!.isEmpty ? 'Prénom requis' : null,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: TextFormField(
                          controller: lastNameController,
                          keyboardType: TextInputType.name,
                          decoration: const InputDecoration(labelText: 'Nom'),
                          validator: (v) => v!.isEmpty ? 'Nom requis' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // === Adresse ===
                  TextFormField(
                    controller: addressController,
                    decoration: const InputDecoration(labelText: 'Adresse'),
                    validator: (v) => v!.isEmpty ? 'Adresse requise' : null,
                  ),
                  const SizedBox(height: 16),

                  // === Téléphone ===
                  TextFormField(
                    controller: phoneNumberController,
                    keyboardType: TextInputType.phone,
                    decoration:
                        const InputDecoration(labelText: 'Numéro de téléphone'),
                    validator: (v) => v!.isEmpty ? 'Téléphone requis' : null,
                  ),
                  const SizedBox(height: 16),

                  // === Email ===
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email requis';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                          .hasMatch(value)) {
                        return 'Email invalide';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // === Mot de passe ===
                  TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    decoration:
                        const InputDecoration(labelText: 'Mot de passe'),
                    validator: (value) {
                      if (value == null || value.length < 8) {
                        return 'Minimum 8 caractères';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // === Confirmer mot de passe ===
                  TextFormField(
                    controller: confirmPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                        labelText: 'Confirmer le mot de passe'),
                    validator: (value) {
                      if (value != passwordController.text) {
                        return 'Les mots de passe ne correspondent pas';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),

                  // === Bouton Créer compte ===
                  ElevatedButton(
                    onPressed: _isLoading ? null : _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Créer un compte',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                  ),

                  // === Lien vers login ===
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    child: const Text.rich(
                      TextSpan(
                        text: 'Déjà un compte ? ',
                        style: TextStyle(color: primaryColor),
                        children: [
                          TextSpan(
                            text: 'Se connecter',
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    addressController.dispose();
    phoneNumberController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
