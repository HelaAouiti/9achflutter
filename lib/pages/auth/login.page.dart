import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mini_project_9ach/utils/constants.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final String baseUrl = "http://10.0.2.2:5000"; // Android emulator
  // final String baseUrl = "http://localhost:3000"; // iOS / Web

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    print("Tentative de connexion vers : $baseUrl/login");

    try {
      final response = await http
          .post(
            Uri.parse("$baseUrl/login"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "email": emailController.text.trim().toLowerCase(),
              "password": passwordController.text,
            }),
          )
          .timeout(const Duration(seconds: 10)); // 10 secondes max

      print("RÉUSSI ! Code HTTP : ${response.statusCode}");
      print("Réponse du serveur : ${response.body}");

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // 1. Sauvegarde les données
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', data['token']);
        await prefs.setString('user_prenom', data['user']['prenom']);
        await prefs.setString('user_nom', data['user']['nom']);
        await prefs.setString('user_email', data['user']['email']);
        await prefs.setString('user_phone', data['user']['phone'].toString());

        // 2. Vérifie que la page est encore vivante
        if (!mounted) return;

        // 3. Message de succès
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Connexion réussie !"),
            backgroundColor: Colors.green,
          ),
        );

        // 4. Navigation FORCÉE qui marche à 100%
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/home', (route) => false);

        // OU cette version encore plus forte :
        // Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(data['message'] ?? "Erreur: ${response.statusCode}")),
        );
      }
    } on TimeoutException catch (_) {
      print("TIMEOUT : Le serveur ne répond pas en 10 secondes");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Serveur trop lent ou hors ligne")),
      );
    } catch (e) {
      print("ERREUR CRITIQUE : $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Connexion impossible : $e")),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
                  // Logo + Titre
                  Container(
                    height: 230,
                    margin: const EdgeInsets.symmetric(vertical: 24),
                    child: Column(
                      children: [
                        Image.asset('assets/images/logo.png'),
                        const SizedBox(height: 20),
                        const Text(
                          "قشش باحسن الأسوام",
                          style: TextStyle(
                              fontSize: 30,
                              color: primaryColor,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),

                  // Email
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration:
                        const InputDecoration(labelText: 'Adresse Email'),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Email requis';
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                          .hasMatch(value)) {
                        return 'Email invalide';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Mot de passe
                  TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    decoration:
                        const InputDecoration(labelText: 'Mot de Passe'),
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'Mot de passe requis';
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),

                  // Bouton Connexion
                  ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Se Connecter',
                            style:
                                TextStyle(color: Colors.white, fontSize: 16)),
                  ),

                  const SizedBox(height: 16),

                  // Lien vers inscription
                  TextButton(
                    onPressed: () =>
                        Navigator.pushReplacementNamed(context, '/signup'),
                    child: const Text.rich(
                      TextSpan(
                        text: 'Pas de compte ? ',
                        style: TextStyle(color: primaryColor),
                        children: [
                          TextSpan(
                            text: 'Créer un compte',
                            style: TextStyle(
                                decoration: TextDecoration.underline,
                                color: primaryColor),
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
}
