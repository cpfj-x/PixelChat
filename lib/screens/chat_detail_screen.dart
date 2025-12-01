// lib/screens/chat_detail_screen.dart

import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';

import '../services/chat_service.dart';
import '../services/storage_service.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';
import 'chat_info_screen.dart';

class ChatDetailScreen extends StatefulWidget {
  final Chat chat;

  const ChatDetailScreen({super.key, required this.chat});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final StorageService _storageService = StorageService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();

  final ItemScrollController _scrollController = ItemScrollController();
  final ItemPositionsListener _positionsListener = ItemPositionsListener.create();

  late Stream<List<Message>> _messagesStream;

  bool _isSending = false;
  Message? _replyMessage;

  final List<File> _pendingImages = [];

  // ====== AUDIO RECORDING ======
  final AudioRecorder _recorder = AudioRecorder();
  bool _isRecording = false;
  String? _audioPath;
  Timer? _recordTimer;
  int _recordSeconds = 0;

  static const Color primary = Color(0xFF7A5AF8);

  @override
  void initState() {
    super.initState();
    _messagesStream = _chatService.getChatMessages(widget.chat.id);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _recordTimer?.cancel();
    _recorder.dispose();
    super.dispose();
  }

  // ====================================================
  //                       TEXT
  // ====================================================
  Future<void> _sendTextMessage() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return;
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() => _isSending = true);

    try {
      await _chatService.sendMessage(
        chatId: widget.chat.id,
        senderId: user.uid,
        senderName: user.email ?? "Usuario",
        content: text,
        replyToMessageId: _replyMessage?.id,
      );

      _messageController.clear();
      _replyMessage = null;
      _scrollToBottom();
    } finally {
      setState(() => _isSending = false);
    }
  }

  // ====================================================
  //                       SCROLL
  // ====================================================
  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 150), () {
      if (_scrollController.isAttached) {
        _scrollController.scrollTo(
          index: 0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ====================================================
  //                       IMAGES
  // ====================================================
  Future<void> _pickImage(ImageSource source) async {
    try {
      if (source == ImageSource.gallery) {
        final list = await _picker.pickMultiImage(maxWidth: 1920, imageQuality: 85);
        if (list.isNotEmpty) {
          setState(() {
            _pendingImages.addAll(list.map((x) => File(x.path)));
          });
        }
      } else {
        final picked = await _picker.pickImage(
          source: ImageSource.camera,
          maxWidth: 1920,
          imageQuality: 85,
        );
        if (picked != null) {
          setState(() => _pendingImages.add(File(picked.path)));
        }
      }
    } catch (e) {
      _showError("Error al seleccionar imagen: $e");
    }
  }

  Future<void> _sendPendingImages() async {
    if (_pendingImages.isEmpty || _isSending) return;

    final user = _firebaseAuth.currentUser;
    if (user == null) return;

    setState(() => _isSending = true);

    try {
      final urls = await _storageService.uploadMultipleImages(
        chatId: widget.chat.id,
        images: List<File>.from(_pendingImages),
      );

      await _chatService.sendMessage(
        chatId: widget.chat.id,
        senderId: user.uid,
        senderName: user.email ?? "Usuario",
        content: urls.length == 1 ? "[Imagen]" : "📷 ${urls.length} imágenes",
        imageUrls: urls,
        replyToMessageId: _replyMessage?.id,
      );

      _pendingImages.clear();
      _replyMessage = null;
      _scrollToBottom();
    } finally {
      setState(() => _isSending = false);
    }
  }

  void _removePendingImage(int i) {
    setState(() => _pendingImages.removeAt(i));
  }

  // ====================================================
  //                       VIDEO
  // ====================================================
  Future<void> _pickVideo(ImageSource source) async {
    try {
      final picked = await _picker.pickVideo(source: source);
      if (picked == null) return;

      final file = File(picked.path);

      final thumbPath = await VideoThumbnail.thumbnailFile(
        video: picked.path,
        imageFormat: ImageFormat.PNG,
        maxHeight: 300,
        quality: 50,
      );

      final preview = thumbPath != null
          ? Image.file(File(thumbPath))
          : const Text("Video");

      final confirm = await _showPreviewDialog(preview);
      if (confirm != true) return;

      await _uploadVideo(file);
    } catch (e) {
      _showError("Error al seleccionar video: $e");
    }
  }

  Future<void> _uploadVideo(File video) async {
    if (_isSending) return;

    final user = _firebaseAuth.currentUser;
    if (user == null) return;

    setState(() => _isSending = true);

    try {
      final data = await _storageService.uploadMessageVideo(
        chatId: widget.chat.id,
        videoFile: video,
      );

      await _chatService.sendMessage(
        chatId: widget.chat.id,
        senderId: user.uid,
        senderName: user.email ?? "Usuario",
        content: "[Video]",
        videoUrl: data["videoUrl"],
        videoThumbnail: data["thumbnailUrl"],
        replyToMessageId: _replyMessage?.id,
      );

      _replyMessage = null;
      _scrollToBottom();
    } finally {
      setState(() => _isSending = false);
    }
  }

  // ====================================================
  //                       AUDIO RECORD
  // ====================================================

  Future<void> _toggleRecord() async {
    if (_isRecording) {
      await _stopRecordAndSend();
    } else {
      await _startRecord();
    }
  }

  Future<void> _startRecord() async {
  try {
    if (!await _recorder.hasPermission()) {
      _showError("No tienes permisos para grabar audio.");
      return;
    }

    final temp = await getTemporaryDirectory();
    _audioPath =
        "${temp.path}/note_${DateTime.now().millisecondsSinceEpoch}.m4a";

    await _recorder.start(
      RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        sampleRate: 44100,
      ),
      path: _audioPath!,
    );

    setState(() {
      _isRecording = true;
      _recordSeconds = 0;
    });

    _recordTimer?.cancel();
    _recordTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _recordSeconds++);
    });
  } catch (e) {
    _showError("Error al iniciar grabación: $e");
  }
}


  Future<void> _stopRecordAndSend() async {
    try {
      final path = await _recorder.stop();
      _recordTimer?.cancel();

      setState(() => _isRecording = false);

      if (path == null || _isSending) return;

      final user = _firebaseAuth.currentUser;
      if (user == null) return;

      setState(() => _isSending = true);

      final audioUrl = await _storageService.uploadAudio(
        chatId: widget.chat.id,
        audioFile: File(path),
      );

      await _chatService.sendMessage(
        chatId: widget.chat.id,
        senderId: user.uid,
        senderName: user.email ?? "Usuario",
        content: "[Audio]",
        audioUrl: audioUrl,
        replyToMessageId: _replyMessage?.id,
      );

      _replyMessage = null;
      _scrollToBottom();
    } catch (e) {
      _showError("Error al enviar audio: $e");
    } finally {
      setState(() => _isSending = false);
    }
  }

  Widget _recordingBar() {
    String two(int n) => n.toString().padLeft(2, '0');
    final m = two(_recordSeconds ~/ 60);
    final s = two(_recordSeconds % 60);

    return Container(
      color: Colors.red.withValues(alpha: 0.10),
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          const Icon(Icons.mic, color: Colors.red),
          const SizedBox(width: 12),
          Text("$m:$s",
              style: const TextStyle(color: Colors.red, fontSize: 16)),
          const SizedBox(width: 12),
          const Text("Grabando nota de voz...",
              style: TextStyle(color: Colors.red)),
          const Spacer(),
          TextButton(
            onPressed: () async {
              try {
                await _recorder.stop();
              } catch (_) {}
              _recordTimer?.cancel();
              setState(() => _isRecording = false);
            },
            child: const Text("Cancelar"),
          ),
        ],
      ),
    );
  }

  // ====================================================
  //                       PREVIEW DIALOG
  // ====================================================
  Future<bool?> _showPreviewDialog(Widget child) {
    return showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Vista previa"),
        content: child,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Enviar"),
          ),
        ],
      ),
    );
  }

  // ====================================================
  //                       UI
  // ====================================================
  @override
  Widget build(BuildContext context) {
    final userId = _firebaseAuth.currentUser?.uid;

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: _buildHeader(),
      body: Column(
        children: [
          // ======================================================
          //  BOTÓN DE UNIRSE / SALIR (SOLO PARA COMUNIDADES)
          // ======================================================
          if (widget.chat.type == ChatType.community)
            FutureBuilder(
              future: _chatService.getChatById(widget.chat.id),
              builder: (_, snap) {
                if (!snap.hasData) return const SizedBox(height: 0);

                final chat = snap.data!;
                final userId = _firebaseAuth.currentUser!.uid;
                final isMember = chat.memberIds.contains(userId);

                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isMember ? Colors.redAccent : primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () async {
                      if (isMember) {
                        await _chatService.leaveCommunity(
                          chatId: widget.chat.id,
                          userId: userId,
                        );
                      } else {
                        await _chatService.joinCommunity(
                          chatId: widget.chat.id,
                          userId: userId,
                        );
                      }

                      setState(() {});
                    },
                    child: Text(
                      isMember ? "Salir de la comunidad" : "Unirse a la comunidad",
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                );
              },
            ),

          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: _messagesStream,
              builder: (_, snap) {
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final msgs = snap.data!;
                msgs.sort((a, b) => b.timestamp.compareTo(a.timestamp));

                return ScrollablePositionedList.builder(
                  reverse: true,
                  itemScrollController: _scrollController,
                  itemPositionsListener: _positionsListener,
                  itemCount: msgs.length,
                  itemBuilder: (_, i) {
                    final msg = msgs[i];
                    return GestureDetector(
                      onLongPress: () =>
                          setState(() => _replyMessage = msg),
                      child: MessageBubble(
                        message: msg,
                        isMe: msg.senderId == userId,
                      ),
                    );
                  },
                );
              },
            ),
          ),

          if (_replyMessage != null) _replyPreview(),
          if (_isRecording) _recordingBar(),
          if (_pendingImages.isNotEmpty) _pendingImagesPreview(),

          _buildInputBar(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildHeader() {
    return AppBar(
      backgroundColor: primary,
      elevation: 0,
      titleSpacing: 0,
      title: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Colors.white24,
            child: Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Text(widget.chat.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatInfoScreen(chat: widget.chat),
              ),
            );
          },
        ),
      ],
    );
  }

  // ====================================================
  //                     INPUT BAR
  // ====================================================
  Widget _buildInputBar() {
    return SafeArea(
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        child: Row(
          children: [
            IconButton(
                icon: const Icon(Icons.emoji_emotions_outlined,
                    color: Colors.grey),
                onPressed: () {}),

            IconButton(
              icon: Icon(
                _isRecording ? Icons.stop_circle : Icons.mic,
                color: _isRecording ? Colors.red : Colors.grey,
              ),
              onPressed: _isSending ? null : _toggleRecord,
            ),

            IconButton(
              icon: const Icon(Icons.attach_file, color: Colors.grey),
              onPressed: _openAttachmentMenu,
            ),

            Expanded(
              child: TextField(
                controller: _messageController,
                maxLines: 5,
                minLines: 1,
                decoration: InputDecoration(
                  hintText: "Mensaje",
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none),
                ),
              ),
            ),

            const SizedBox(width: 8),

            _isSending
                ? const SizedBox(
                    width: 40,
                    height: 40,
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : GestureDetector(
                    onTap: _sendTextMessage,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.send, color: Colors.white),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  // ====================================================
  //                    PREVIEW IMAGES
  // ====================================================
  Widget _pendingImagesPreview() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.photo_library, color: primary),
              const SizedBox(width: 8),
              Text("Seleccionadas: ${_pendingImages.length}"),
              const Spacer(),
              TextButton(
                  onPressed: _isSending
                      ? null
                      : () => setState(() => _pendingImages.clear()),
                  child: const Text("Limpiar")),
              ElevatedButton(
                onPressed: _isSending ? null : _sendPendingImages,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  minimumSize: Size.zero,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                child: const Text("Enviar"),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 80,
            child: ListView.builder(
              itemCount: _pendingImages.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (_, i) {
                return Stack(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          _pendingImages[i],
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => _removePendingImage(i),
                        child: Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black54,
                          ),
                          padding: const EdgeInsets.all(3),
                          child: const Icon(Icons.close,
                              color: Colors.white, size: 14),
                        ),
                      ),
                    )
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ====================================================
  //                   REPLY PREVIEW
  // ====================================================
  Widget _replyPreview() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Container(width: 4, height: 40, color: primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _replyMessage!.content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => setState(() => _replyMessage = null),
          ),
        ],
      ),
    );
  }

  // ====================================================
  //                   ATTACHMENT MENU
  // ====================================================
  void _openAttachmentMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) {
        return SizedBox(
          height: 260,
          child: GridView.count(
            crossAxisCount: 3,
            children: [
              _attachmentButton(
                icon: Icons.photo,
                label: "Galería",
                color: Colors.purple,
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              _attachmentButton(
                icon: Icons.camera_alt,
                label: "Cámara",
                color: Colors.teal,
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              _attachmentButton(
                icon: Icons.videocam,
                label: "Video",
                color: Colors.red,
                onTap: () {
                  Navigator.pop(context);
                  _pickVideo(ImageSource.gallery);
                },
              ),
              _attachmentButton(
                icon: Icons.videocam_outlined,
                label: "Grabar video",
                color: Colors.orange,
                onTap: () {
                  Navigator.pop(context);
                  _pickVideo(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _attachmentButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: color.withValues(alpha: 0.15),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(height: 6),
          Text(label),
        ],
      ),
    );
  }

  // ====================================================
  //                     ERROR SNACKBAR
  // ====================================================
  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}

// ==========================================================
//                     MESSAGE BUBBLE
// ==========================================================

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    final hasImages = message.imageUrls?.isNotEmpty == true;
    final hasVideo = message.videoUrl?.isNotEmpty == true;
    final hasAudio = message.audioUrl?.isNotEmpty == true;

    final bg = isMe ? const Color(0xFF7A5AF8) : const Color(0xFFF0F0F0);

    final br = BorderRadius.only(
      topLeft: const Radius.circular(16),
      topRight: const Radius.circular(16),
      bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(4),
      bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(16),
    );

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: bg, borderRadius: br),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasImages) _imageGrid(),
            if (hasVideo) _videoThumbnail(context),
            if (hasAudio)
              AudioMessagePlayer(
                url: message.audioUrl!,
                isMe: isMe,
              ),
            if (!hasImages && !hasVideo && !hasAudio)
              Text(
                message.content,
                style: TextStyle(
                  color: isMe ? Colors.white : Colors.black87,
                ),
              ),
            const SizedBox(height: 4),
            Text(
              _formatTime(message.timestamp),
              style: TextStyle(
                fontSize: 11,
                color: isMe ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime t) {
    return "${t.hour}:${t.minute.toString().padLeft(2, '0')}";
  }

  Widget _imageGrid() {
    final urls = message.imageUrls ?? [];

    if (urls.length == 1) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(urls[0], width: 240, fit: BoxFit.cover),
      );
    }

    return SizedBox(
      width: 240,
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        children: urls
            .map(
              (u) => ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  u,
                  width: 110,
                  height: 110,
                  fit: BoxFit.cover,
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _videoThumbnail(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VideoPlayerScreen(url: message.videoUrl!),
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              message.videoThumbnail ??
                  "https://via.placeholder.com/300x200.png?text=Video",
              width: 240,
              height: 160,
              fit: BoxFit.cover,
            ),
          ),
          const Icon(Icons.play_circle_fill, size: 50, color: Colors.white),
        ],
      ),
    );
  }
}

// ==========================================================
//                AUDIO PLAYER WIDGET
// ==========================================================

class AudioMessagePlayer extends StatefulWidget {
  final String url;
  final bool isMe;

  const AudioMessagePlayer({
    super.key,
    required this.url,
    required this.isMe,
  });

  @override
  State<AudioMessagePlayer> createState() => _AudioMessagePlayerState();
}

class _AudioMessagePlayerState extends State<AudioMessagePlayer> {
  final AudioPlayer _player = AudioPlayer();
  bool _playing = false;

  Duration _total = Duration.zero;
  Duration _pos = Duration.zero;

  @override
  void initState() {
    super.initState();

    _player.onDurationChanged.listen((d) {
      setState(() => _total = d);
    });

    _player.onPositionChanged.listen((p) {
      setState(() => _pos = p);
    });

    _player.onPlayerComplete.listen((_) {
      setState(() {
        _playing = false;
        _pos = Duration.zero;
      });
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _toggle() async {
    if (_playing) {
      await _player.pause();
      setState(() => _playing = false);
    } else {
      await _player.play(UrlSource(widget.url));
      setState(() => _playing = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = (_total.inMilliseconds == 0)
        ? 0.0
        : _pos.inMilliseconds / _total.inMilliseconds;

    return SizedBox(
      width: 240,
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              _playing ? Icons.pause_circle_filled : Icons.play_circle_fill,
              color: widget.isMe ? Colors.white : Colors.black87,
            ),
            onPressed: _toggle,
          ),
          Expanded(
            child: Slider(
              value: p.clamp(0.0, 1.0),
              onChanged: (v) {
                final ms = (_total.inMilliseconds * v).toInt();
                _player.seek(Duration(milliseconds: ms));
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================================
//                FULL VIDEO PLAYER
// ==========================================================

class VideoPlayerScreen extends StatefulWidget {
  final String url;
  const VideoPlayerScreen({super.key, required this.url});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  ChewieController? _chewie;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..initialize().then((_) {
        setState(() {
          _chewie = ChewieController(
            videoPlayerController: _controller,
            autoPlay: true,
            looping: false,
          );
        });
      });
  }

  @override
  void dispose() {
    _chewie?.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: _chewie != null
            ? Chewie(controller: _chewie!)
            : const CircularProgressIndicator(),
      ),
    );
  }
}
