import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mini_project_9ach/utils/constants.dart';

class CustomDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: primaryColor,
      child: FutureBuilder(
        future: getUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.white));
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}',
                style: TextStyle(color: Colors.white));
          } else {
            var userData = snapshot.data as Map<String, dynamic>;

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
                          "${userData['firstName']} ${userData['lastName']}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      Flexible(
                        child: Text(
                          userData['email'],
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Flexible(
                        child: Text(
                          userData['phoneNumber'],
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  title: const Text('Acceuil'),
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
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text('Se Deconnecter'),
                  textColor: Colors.white,
                  iconColor: Colors.white,
                  leading: const Icon(Icons.logout),
                  onTap: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.clear(); // ← Vide le local storage

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
    final prefs = await SharedPreferences.getInstance();

    return {
      "firstName": prefs.getString('user_nom') ?? '',
      "lastName": prefs.getString('user_prenom') ?? '',
      "email": prefs.getString('user_email') ?? '',
      "phoneNumber": prefs.getString('user_phone') ?? '',
    };
  }
}
