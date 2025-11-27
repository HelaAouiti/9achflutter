import 'package:flutter/material.dart';
import 'package:mini_project_9ach/utils/constants.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      iconTheme: const IconThemeData(color: Colors.white),
      backgroundColor: primaryColor,
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset('assets/images/logo-white.png'),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}