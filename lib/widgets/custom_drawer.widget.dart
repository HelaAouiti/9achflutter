import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:mini_project_9ach/pages/favorites.page.dart';
import 'package:mini_project_9ach/utils/constants.dart';

class CustomDrawer extends StatelessWidget {
  final String userEmail; // L’email de l’utilisateur connecté

  CustomDrawer({required this.userEmail, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: primaryColor,
      child: FutureBuilder<Map<String, dynamic>>(
        future: getUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.white));
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.white));
          } else {
            var userData = snapshot.data ?? {};

            return ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                DrawerHeader(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          "${userData['prenom']} ${userData['nom']}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      Flexible(
                        child: Text(
                          userData['email'] ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Flexible(
                        child: Text(
                          userData['phone'] ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  title: const Text('Accueil'),
                  textColor: Colors.white,
                  iconColor: Colors.white,
                  leading: const Icon(Icons.home),
                  onTap: () {
                    Navigator.pushNamed(context, '/home');
                  },
                ),
                ListTile(
                  title: const Text('Panier'),
                  textColor: Colors.white,
                  iconColor: Colors.white,
                  leading: const Icon(Icons.shopping_cart),
                  onTap: () {
                    Navigator.pushNamed(context, '/checkout');
                  },
                ),
                ListTile(
                  title: const Text('Favoris'),
                  textColor: Colors.white,
                  iconColor: Colors.white,
                  leading: const Icon(Icons.favorite),
                  onTap: () {
                    Navigator.pop(context); // ferme le drawer
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const FavoritesPage()),
                    );
                  },
                ),
                ListTile(
                  title: const Text('Se Déconnecter'),
                  textColor: Colors.white,
                  iconColor: Colors.white,
                  leading: const Icon(Icons.logout),
                  onTap: () {
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Future<Map<String, dynamic>> getUserData() async {
    final box = Hive.box('users');

    // Récupère les données de l’utilisateur connecté via son email
    final user = box.get(userEmail);

    return {
      "prenom": user?['prenom'] ?? '',
      "nom": user?['nom'] ?? '',
      "email": user?['email'] ?? '',
      "phone": user?['phone'] ?? '',
    };
  }
}
