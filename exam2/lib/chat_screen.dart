import 'package:flutter/material.dart';

import 'player.dart';

class ChatScreen extends StatefulWidget {
  final Player player;

  const ChatScreen({super.key, required this.player});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _draftMessages = [];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleInput() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _draftMessages.add(text);
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final player = widget.player;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        titleSpacing: 0,
        title: Row(
          children: [
            PlayerAvatar(player: player, radius: 16),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  player.displayName,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                Text(
                  player.displaySubtitle,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.more_vert, color: Colors.white),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _draftMessages.isEmpty
                ? Center(
                    child: Text(
                      'No messages yet',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _draftMessages.length,
                    itemBuilder: (context, index) => Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF4655),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _draftMessages[index],
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1F22),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  controller: _controller,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Send a message',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.send, color: Color(0xFFFF4655)),
              onPressed: _handleInput, // no backend send logic yet
            ),
          ],
        ),
      ),
    );
  }
}
