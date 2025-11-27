import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  static const Color primary = Color(0xFF7A5AF8); // PixelChat Purple

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // ---------------- APPBAR ----------------
      appBar: AppBar(
        backgroundColor: primary,
        elevation: 0,
        title: const Text(
          "Ayuda",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ---------------- BODY ----------------
      body: ListView(
        children: [
          const SizedBox(height: 16),

          // --------- CARD DE INFORMACIÓN ESTILO WHATSAPP ---------
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                "Centro de ayuda de PixelChat\n\n"
                "Encuentra respuestas rápidas, tips de uso y ponte en "
                "contacto con nuestro equipo de soporte.",
                style: TextStyle(fontSize: 15),
              ),
            ),
          ),

          const SizedBox(height: 24),

          _sectionTitle("Soporte y ayuda"),

          // -------- FAQ --------
          _itemTile(
            icon: Icons.help_outline,
            title: "Preguntas frecuentes",
            subtitle: "Respuestas a dudas comunes",
            onTap: () {},
          ),

          _divider(),

          // -------- CONTACTAR --------
          _itemTile(
            icon: Icons.support_agent_outlined,
            title: "Contactar soporte",
            subtitle: "Habla con nuestro equipo",
            onTap: () {},
          ),

          _divider(),

          // -------- FEEDBACK --------
          _itemTile(
            icon: Icons.feedback_outlined,
            title: "Enviar comentarios",
            subtitle: "Ayúdanos a mejorar",
            onTap: () {},
          ),
        ],
      ),
    );
  }

  // ---------------- COMPONENTES WHATSAPP ----------------

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  Widget _itemTile({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: CircleAvatar(
        backgroundColor: primary.withOpacity(0.12),
        child: Icon(icon, color: primary),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      subtitle: subtitle != null
          ? Text(subtitle, style: const TextStyle(fontSize: 13))
          : null,
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _divider() {
    return Padding(
      padding: const EdgeInsets.only(left: 72),
      child: Divider(height: 0, color: Colors.grey.shade300),
    );
  }
}
