import 'package:flutter/material.dart';

// SCREENS PRINCIPALES
import '../screens/splash_screen.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/phone_verification_screen.dart';
import '../screens/profile_setup_screen.dart';
import '../screens/main_screen.dart';

// CHATS
import '../screens/new_chat_type_screen.dart';
import '../screens/new_chat_screen.dart';
import '../screens/new_group_screen.dart';
import '../screens/chat_detail_screen.dart';
import '../screens/select_members_screen.dart';

// SETTINGS
import '../screens/settings_screen.dart';
import '../screens/appearance_settings_screen.dart';
import '../screens/chat_settings_screen.dart';
import '../screens/notifications_settings_screen.dart';
import '../screens/privacy_settings_screen.dart';
import '../screens/data_usage_settings_screen.dart';

class AppRoutes {
  // ====== NOMBRES DE RUTA ======
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String phoneVerification = '/phone-verification';
  static const String profileSetup = '/profile-setup';
  static const String main = '/main';

  // Crear nuevos chats
  static const String newChatType = '/new-chat-type';
  static const String newChat = '/new-chat';
  static const String newGroup = '/new-group';

  // Chat detail dinamico
  static const String chatDetail = '/chat-detail';

  // Selector de miembros
  static const String selectMembers = '/select-members';

  // Settings
  static const String settings = '/settings';
  static const String appearance = '/settings/appearance';
  static const String chatsSettings = '/settings/chats';
  static const String notifications = '/settings/notifications';
  static const String privacy = '/settings/privacy';
  static const String dataUsage = '/settings/data-usage';

  // ====== REGISTRO DE RUTAS ======
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      splash: (context) => const SplashScreen(),
      login: (context) => const LoginScreen(),
      register: (context) => const RegisterScreen(),
      phoneVerification: (context) => const PhoneVerificationScreen(),
      profileSetup: (context) => const ProfileSetupScreen(),
      main: (context) => const MainScreen(),

      // Creación de chats
      newChatType: (context) => const NewChatTypeScreen(),
      newChat: (context) => const NewChatScreen(),
      newGroup: (context) => const NewGroupScreen(chatType: 'group'),

      // Ajustes principales
      settings: (context) => const SettingsScreen(),
      appearance: (context) => const AppearanceSettingsScreen(),
      chatsSettings: (context) => const ChatSettingsScreen(),
      notifications: (context) => const NotificationsSettingsScreen(),
      privacy: (context) => const PrivacySettingsScreen(),
      dataUsage: (context) => const DataUsageSettingsScreen(),
    };
  }

  // ====== RUTA DINÁMICA PARA CHAT DETAIL ======
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    if (settings.name == chatDetail) {
      final args = settings.arguments as Map<String, dynamic>;
      final chat = args['chat'];

      return MaterialPageRoute(
        builder: (_) => ChatDetailScreen(chat: chat),
      );
    }

    if (settings.name == selectMembers) {
      final args = settings.arguments as Map<String, dynamic>;
      final members = args['initialMembers'];

      return MaterialPageRoute(
        builder: (_) => SelectMembersScreen(initialMembers: members),
      );
    }

    return MaterialPageRoute(
      builder: (_) => const Scaffold(
        body: Center(
          child: Text("Ruta no encontrada"),
        ),
      ),
    );
  }
}
