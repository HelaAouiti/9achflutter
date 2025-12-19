// widgets/custom_drawer.widget.dart

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mini_project_9ach/pages/favorites.page.dart';
import 'package:mini_project_9ach/utils/constants.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: primaryColor,
      child: FutureBuilder<String?>(
        future: _getCurrentUserEmail(),
        builder: (context, emailSnapshot) {
          if (emailSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.white));
          }

          if (!emailSnapshot.hasData || emailSnapshot.data == null) {
            return const Center(
              child: Text(
                'Aucun utilisateur connecté',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final String userEmail = emailSnapshot.data!;

          // Écoute les changements sur les données de cet utilisateur précis
          return ValueListenableBuilder(
            valueListenable: Hive.box('users').listenable(keys: [userEmail]),
            builder: (context, _, __) {
              final user = Hive.box('users').get(userEmail);

              final userData = {
                "prenom": user?['prenom'] ?? '',
                "nom": user?['nom'] ?? '',
                "email": user?['email'] ?? userEmail,
                "phone": user?['phone'] ?? '',
              };

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
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Flexible(
                          child: Text(
                            userData['email'] ?? '',
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Flexible(
                          child: Text(
                            userData['phone'] ?? '',
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
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
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/home');
                    },
                  ),
                  ListTile(
                    title: const Text('Panier'),
                    textColor: Colors.white,
                    iconColor: Colors.white,
                    leading: const Icon(Icons.shopping_cart),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/checkout');
                    },
                  ),
                  ListTile(
                    title: const Text('Favoris'),
                    textColor: Colors.white,
                    iconColor: Colors.white,
                    leading: const Icon(Icons.favorite),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const FavoritesPage()),
                      );
                    },
                  ),
                  ListTile(
                    title: const Text('Se Déconnecter'),
                    textColor: Colors.white,
                    iconColor: Colors.white,
                    leading: const Icon(Icons.logout),
                    onTap: () async {
                      // Supprime la session
                      if (await Hive.boxExists('auth')) {
                        final authBox = await Hive.openBox('auth');
                        await authBox.delete('current_user_email');
                      }
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  // Récupère l'email de l'utilisateur connecté depuis la boîte 'auth'
  Future<String?> _getCurrentUserEmail() async {
    if (!await Hive.boxExists('auth')) return null;
    final authBox = await Hive.openBox('auth');
    return authBox.get('current_user_email');
  }
}
