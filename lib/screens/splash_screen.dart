import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lottie/lottie.dart';
import '../utils/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _startAnimationAndNavigate();
  }

  Future<void> _startAnimationAndNavigate() async {
    // Iniciar animación fade-in
    _controller.forward();

    // Duración estilo WhatsApp
    await Future.delayed(const Duration(milliseconds: 1800));

    if (!mounted) return;

    final user = FirebaseAuth.instance.currentUser;

    // Corrección: obtener pantallas desde AppRoutes
    final routes = AppRoutes.getRoutes();

    final nextScreen = user != null
        ? routes[AppRoutes.home]!(context)
        : routes[AppRoutes.login]!(context);

    // Navegación con Fade suave
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: nextScreen,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // === LOGO PixelChat tipo WhatsApp ===
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFF7A5AF8), // Tu morado oficial
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Center(
                  child: Text(
                    'P',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 60,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // === Lottie cargando ===
              SizedBox(
                width: 120,
                child: Lottie.asset(
                  'assets/lottie/loading.json',
                  repeat: true,
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                'Conectando…',
                style: TextStyle(
                  fontSize: 15,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
