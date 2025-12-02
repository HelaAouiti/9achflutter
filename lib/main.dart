import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mini_project_9ach/pages/favorites.page.dart';
import 'package:provider/provider.dart';
import 'package:mini_project_9ach/pages/auth/login.page.dart';
import 'package:mini_project_9ach/pages/auth/signup.page.dart';
import 'package:mini_project_9ach/pages/home.page.dart';
import 'package:mini_project_9ach/pages/cart.page.dart';
import 'package:mini_project_9ach/services/cart.service.dart';
import 'package:mini_project_9ach/utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation Hive
  await Hive.initFlutter();
  await Hive.openBox('users');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CartService(),
      child: MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
          fontFamily: 'TenorSans',
          useMaterial3: true,
        ),
        routes: {
          '/home': (context) => const HomePage(),
          '/login': (context) => LoginPage(),
          '/signup': (context) => SignupPage(),
          '/checkout': (context) => const CartPage(),
          
        },
        // Page de démarrage
        home: LoginPage(),
      ),
    );
  }
}
