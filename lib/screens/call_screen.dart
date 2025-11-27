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

  @override
  void initState() {
    super.initState();
    _initRenderers();
  }

  Future<void> _initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();

    // TODO: aquí inicializas WebRTC, capturas cámara/mic,
    // creas peerConnection, etc.
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          if (widget.isVideo)
            Positioned.fill(
              child: RTCVideoView(_remoteRenderer),
            )
          else
            const Center(
              child: Icon(
                Icons.person,
                size: 120,
                color: Colors.white24,
              ),
            ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  heroTag: 'mute',
                  backgroundColor: Colors.white24,
                  onPressed: () {},
                  child: const Icon(Icons.mic_off),
                ),
                const SizedBox(width: 24),
                FloatingActionButton(
                  heroTag: 'end',
                  backgroundColor: Colors.red,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Icon(Icons.call_end),
                ),
                if (widget.isVideo) ...[
                  const SizedBox(width: 24),
                  FloatingActionButton(
                    heroTag: 'switch',
                    backgroundColor: Colors.white24,
                    onPressed: () {},
                    child: const Icon(Icons.cameraswitch),
                  ),
                ],
              ],
            ),
          ),
          if (widget.isVideo)
            Positioned(
              top: 40,
              right: 16,
              width: 120,
              height: 180,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: RTCVideoView(
                  _localRenderer,
                  mirror: true,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
