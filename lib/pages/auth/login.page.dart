import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
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

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final box = Hive.box('users');
      final email = emailController.text.trim().toLowerCase();

      if (!box.containsKey(email)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Email non trouvé")),
        );
        setState(() => _isLoading = false);
        return;
      }

      final user = box.get(email);

      if (user['password'] != passwordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Mot de passe incorrect")),
        );
        setState(() => _isLoading = false);
        return;
      }

      // Connexion réussie
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Connexion réussie !"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur de connexion : $e")),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
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
                  decoration: const InputDecoration(labelText: 'Adresse Email'),
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
                  decoration: const InputDecoration(labelText: 'Mot de Passe'),
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
                          style: TextStyle(color: Colors.white, fontSize: 16)),
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
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
