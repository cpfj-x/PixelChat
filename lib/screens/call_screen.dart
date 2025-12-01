import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class CallScreen extends StatefulWidget {
  final String chatId;
  final bool isVideo;

  const CallScreen({
    super.key,
    required this.chatId,
    required this.isVideo,
  });

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  final _localRenderer = RTCVideoRenderer();
  final _remoteRenderer = RTCVideoRenderer();

  bool _micMuted = false;
  final bool _cameraOn = true;

  @override
  void initState() {
    super.initState();
    _initRenderers();
  }

  Future<void> _initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();

    /// TODO:
    /// Aquí inicializas WebRTC:
    /// - Crear peerConnection
    /// - Obtener cámara y micrófono
    /// - Agregar MediaStream
    /// - Conectar con el otro usuario
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF7A5AF8); // Morado principal PixelChat

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ------------ REMOTE VIDEO (Pantalla completa) ------------
          if (widget.isVideo)
            Positioned.fill(
              child: Container(
                color: Colors.black,
                child: RTCVideoView(
                  _remoteRenderer,
                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                ),
              ),
            )
          else
            _buildVoiceCallBackground(),

          // ------------ LOCAL VIDEO (Esquina arriba derecha) ------------
          if (widget.isVideo)
            Positioned(
              top: 50,
              right: 20,
              width: 110,
              height: 160,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: RTCVideoView(
                  _localRenderer,
                  mirror: true,
                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                ),
              ),
            ),

          // ------------ BOTONES DE CONTROL (Estilo WhatsApp) ------------
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: SafeArea(
              top: false,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // MUTE BUTTON
                  _roundButton(
                    icon: _micMuted ? Icons.mic : Icons.mic_off,
                    color: Colors.white24,
                    iconColor: Colors.white,
                    onPressed: () {
                      setState(() => _micMuted = !_micMuted);
                      // TODO: WebRTC mute logic
                    },
                  ),

                  const SizedBox(width: 24),

                  // END CALL BUTTON
                  _roundButton(
                    icon: Icons.call_end,
                    color: Colors.red,
                    iconColor: Colors.white,
                    size: 70,
                    onPressed: () {
                      Navigator.pop(context);
                      // TODO: Terminar conexión WebRTC
                    },
                  ),

                  if (widget.isVideo) ...[
                    const SizedBox(width: 24),
                    // SWITCH CAMERA
                    _roundButton(
                      icon: Icons.cameraswitch,
                      color: Colors.white24,
                      iconColor: Colors.white,
                      onPressed: () {
                        // TODO: WebRTC camera change
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------ BOTÓN REDONDO ESTILO WHATSAPP ------------
  Widget _roundButton({
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
    required Color iconColor,
    double size = 60,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: iconColor),
        iconSize: 28,
        onPressed: onPressed,
      ),
    );
  }

  // ------------ FONDO PARA LLAMADA DE VOZ ------------
  Widget _buildVoiceCallBackground() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person, size: 140, color: Colors.white24),
          SizedBox(height: 20),
          Text(
            "Llamando…",
            style: TextStyle(color: Colors.white70, fontSize: 20),
          ),
        ],
      ),
    );
  }
}
