import 'package:flutter/material.dart';
import '../views/splash_view.dart';
import '../views/login_view.dart';
import '../views/home_view.dart';
import '../views/data_form_view.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String home = '/home';
  static const String dataForm = '/data-form';

  static Map<String, WidgetBuilder> routes = {
    splash: (context) => const SplashView(),
    login: (context) => const LoginView(),
    home: (context) => const HomeView(),
    dataForm: (context) => const DataFormView(),
  };
}
