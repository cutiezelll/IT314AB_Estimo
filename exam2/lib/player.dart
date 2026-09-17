import 'package:flutter/material.dart';

enum PlayerStatus { online, playing, away, offline }

extension PlayerStatusX on PlayerStatus {
  String get label {
    switch (this) {
      case PlayerStatus.online:
        return 'Online';
      case PlayerStatus.playing:
        return 'Playing';
      case PlayerStatus.away:
        return 'Away';
      case PlayerStatus.offline:
        return 'Offline';
    }
  }
}

///[username]
class Player {
  final String username;
  final String? avatarAsset;
  final PlayerStatus status;
  final String? activity;
  final String? lastMessage;
  bool isUnread;

  Player({
    required this.username,
    this.avatarAsset,
    this.status = PlayerStatus.offline,
    this.activity,
    this.lastMessage,
    this.isUnread = false,
  });

  String get displayName => username.trim().isNotEmpty ? username : 'DIyah';

  String get displayMessage =>
      (lastMessage != null && lastMessage!.trim().isNotEmpty)
      ? lastMessage!
      : 'No message available';

  String get displaySubtitle {
    final statusLabel = status.label;
    if (activity != null && activity!.trim().isNotEmpty) {
      return '$statusLabel - $activity';
    }
    return statusLabel;
  }

  bool get isPlayingValorant =>
      activity != null && activity!.toUpperCase() == 'VALORANT';
}

///state of [status].
class StatusIndicator extends StatelessWidget {
  final PlayerStatus status;

  const StatusIndicator({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    if (status == PlayerStatus.offline) {
      return const SizedBox.shrink();
    }

    late final Color color;
    late final Widget? icon;

    switch (status) {
      case PlayerStatus.online:
        color = const Color(0xFF23A55A);
        icon = null;
        break;
      case PlayerStatus.playing:
        color = const Color(0xFF5865F2);
        icon = const Icon(Icons.play_arrow, size: 10, color: Colors.white);
        break;
      case PlayerStatus.away:
        color = const Color(0xFFF0B232);
        icon = const Icon(Icons.nightlight_round, size: 9, color: Colors.black);
        break;
      case PlayerStatus.offline:
        color = const Color.fromARGB(255, 128, 127, 127);
        icon = null;
    }

    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF121212), width: 3),
      ),
      alignment: Alignment.center,
      child: icon,
    );
  }
}

///[Player]
///[Player.avatarAsset]

class PlayerAvatar extends StatelessWidget {
  final Player player;
  final double radius;

  const PlayerAvatar({super.key, required this.player, this.radius = 24});

  @override
  Widget build(BuildContext context) {
    final hasAsset =
        player.avatarAsset != null && player.avatarAsset!.isNotEmpty;

    return SizedBox(
      width: radius * 2 + 4,
      height: radius * 2 + 4,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CircleAvatar(
            radius: radius,
            backgroundColor: const Color(0xFF3A3D44),
            backgroundImage: hasAsset ? AssetImage(player.avatarAsset!) : null,
            onBackgroundImageError: hasAsset ? (_, __) {} : null,
            child: !hasAsset
                ? Icon(Icons.person, color: Colors.grey.shade400, size: radius)
                : null,
          ),
          Positioned(
            bottom: -2,
            right: -2,
            child: StatusIndicator(status: player.status),
          ),
        ],
      ),
    );
  }
}
