import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../enums/UserRole.dart';
import '../services/SharedPreferencesServices.dart';

class SplashScreen extends StatefulWidget {
  static const String routeName = "/";
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  late final spService;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((value) async {
      spService = context.read<SharedPreferencesService>();
      bool isLoggedIn = spService.getIsLoggedIn();
      if (isLoggedIn) {
        String currentUserRole = SharedPreferencesService(spService.sharedPreferences).getRole();
        if (currentUserRole == UserRole.admin.name) {
          Navigator.pushNamed(context, '/dbadmin');
        } else if (currentUserRole == UserRole.user.name) {
          Navigator.pushNamed(context, '/home');
        }
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(milliseconds: 500));

    return Center(child: CircularProgressIndicator());
  }
}
