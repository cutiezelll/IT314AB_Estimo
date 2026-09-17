import 'package:flutter/material.dart';

import 'player.dart';
import 'chat_screen.dart';

void main() => runApp(const ValorantInboxApp());

class ValorantInboxApp extends StatelessWidget {
  const ValorantInboxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Valorant Inbox',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
      ),
      home: const InboxScreen(),
    );
  }
}

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  final List<Player> _players = [
    Player(
      username: 'MissYouLikeKrazy',
      status: PlayerStatus.online,
      activity: 'VALORANT',
      lastMessage: 'gg that last round was insane',
      isUnread: true,
    ),
    Player(
      username: 'bread',
      status: PlayerStatus.playing,
      activity: 'VALORANT',
      lastMessage: 'queueing again?',
      isUnread: true,
    ),
    Player(
      username: 'The14th',
      status: PlayerStatus.playing,
      activity: 'VALORANT',
    ),
    Player(
      username: 'Carlvendish',
      status: PlayerStatus.away,
      activity: 'Riot Mobile',
      lastMessage: 'brb',
    ),
    Player(username: '', status: PlayerStatus.away, activity: 'Riot Mobile'),
  ];

  int _selectedTab = 0;

  void _markAsRead(int index) {
    setState(() => _players[index].isUnread = false);
  }

  void _deletePlayer(int index) {
    final removed = _players[index];
    setState(() => _players.removeAt(index));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Removed ${removed.displayName}')));
  }

  void _openChat(Player player, int index) {
    if (player.isUnread) _markAsRead(index);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ChatScreen(player: player)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final valorantPlayers = _players.where((p) => p.isPlayingValorant).toList();
    final onlinePlayers = _players.where((p) => !p.isPlayingValorant).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Text(
                'Social',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            _buildTabs(),
            _buildSearchBar(),
            Expanded(
              child: ListView.builder(
                itemCount: _rowCount(valorantPlayers, onlinePlayers),
                itemBuilder: (context, index) =>
                    _buildRow(context, index, valorantPlayers, onlinePlayers),
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _rowCount(List<Player> valorant, List<Player> online) {
    var count = 0;
    if (valorant.isNotEmpty) count += 1 + valorant.length; // header + rows
    if (online.isNotEmpty) count += 1 + online.length;
    return count;
  }

  Widget _buildRow(
    BuildContext context,
    int index,
    List<Player> valorant,
    List<Player> online,
  ) {
    var i = index;

    if (valorant.isNotEmpty) {
      if (i == 0) {
        return _sectionHeader('VALORANT', valorant.length, isGame: true);
      }
      i -= 1;
      if (i < valorant.length) {
        final player = valorant[i];
        final globalIndex = _players.indexOf(player);
        return _friendTile(player, globalIndex);
      }
      i -= valorant.length;
    }

    if (online.isNotEmpty) {
      if (i == 0) {
        return _sectionHeader('Online', online.length);
      }
      i -= 1;
      final player = online[i];
      final globalIndex = _players.indexOf(player);
      return _friendTile(player, globalIndex);
    }

    return const SizedBox.shrink();
  }

  Widget _sectionHeader(String title, int count, {bool isGame = false}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
      child: Row(
        children: [
          if (isGame)
            const Padding(
              padding: EdgeInsets.only(right: 6),
              child: Icon(
                Icons.sports_esports,
                color: Color.fromARGB(255, 3, 3, 3),
                size: 16,
              ),
            ),
          Text(
            title,
            style: TextStyle(
              color: isGame ? const Color(0xFFFF4655) : Colors.grey.shade400,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '$count',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _friendTile(Player player, int globalIndex) {
    return Dismissible(
      key: ValueKey('${player.displayName}_$globalIndex'),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.redAccent,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => _deletePlayer(globalIndex),
      child: ListTile(
        onTap: () => _openChat(player, globalIndex),
        leading: PlayerAvatar(player: player),
        title: Text(
          player.displayName,
          style: TextStyle(
            color: Colors.white,
            fontWeight: player.isUnread ? FontWeight.bold : FontWeight.w600,
          ),
        ),
        subtitle: Row(
          children: [
            Icon(
              player.isPlayingValorant
                  ? Icons.videogame_asset
                  : Icons.phone_android,
              size: 14,
              color: Colors.grey.shade500,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                player.displaySubtitle,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),

        trailing: player.isUnread
            ? Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              )
            : IconButton(
                icon: Icon(Icons.more_horiz, color: Colors.grey.shade600),
                onPressed: () => _showActions(player, globalIndex),
              ),
      ),
    );
  }

  void _showActions(Player player, int index) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1F22),
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.mark_email_read, color: Colors.white),
              title: const Text(
                'Mark as read',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                _markAsRead(index);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.redAccent),
              title: const Text(
                'Delete conversation',
                style: TextStyle(color: Colors.redAccent),
              ),
              onTap: () {
                Navigator.pop(context);
                _deletePlayer(index);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs() {
    const tabs = ['Friends', 'Messages', 'Requests'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final selected = _selectedTab == i;
          return Padding(
            padding: const EdgeInsets.only(right: 20),
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = i),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tabs[i],
                    style: TextStyle(
                      color: selected ? Colors.white : Colors.grey.shade500,
                      fontWeight: selected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 2,
                    width: 28,
                    color: selected
                        ? const Color.fromARGB(255, 8, 4, 4)
                        : Colors.transparent,
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1F22),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(Icons.search, color: Colors.grey.shade500, size: 20),
            const SizedBox(width: 8),
            Text('Search', style: TextStyle(color: Colors.grey.shade500)),
          ],
        ),
      ),
    );
  }
}
