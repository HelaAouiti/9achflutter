import 'package:flutter/material.dart';
import 'package:mini_project_9ach/pages/auth/login.page.dart';
import 'package:mini_project_9ach/pages/auth/signup.page.dart';
import 'package:mini_project_9ach/pages/checkout.page.dart';
import 'package:mini_project_9ach/pages/home.page.dart';
import 'package:mini_project_9ach/pages/product_details.page.dart';
import 'package:mini_project_9ach/utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      routes: {
        '/home': (context) => const HomePage(),
        '/login': (context) => LoginPage(),
        '/signup': (context) => SignupPage(),
        '/checkout': (context) => const CheckoutPage(),
      },
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
        fontFamily: 'TenorSans',
        useMaterial3: true,
      ),
     // home: LoginPage(),
     home: HomePage(), 
    );
  }
}
