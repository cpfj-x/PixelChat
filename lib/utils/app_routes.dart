import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/phone_verification_screen.dart';
import '../screens/profile_setup_screen.dart';
import '../screens/main_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String phoneVerification = '/phone-verification';
  static const String profileSetup = '/profile-setup';
  static const String main = '/main';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      splash: (context) => const SplashScreen(),
      login: (context) => const LoginScreen(),
      register: (context) => const RegisterScreen(),
      phoneVerification: (context) => const PhoneVerificationScreen(),
      profileSetup: (context) => const ProfileSetupScreen(),
      main: (context) => const MainScreen(),
    };
  }
}
