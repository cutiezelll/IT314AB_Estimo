import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

String appTitle = 'Social';
String gameName = 'VALORANT';
int gameFriends = 3;
String friend1 = 'MissYouLikeKrazy';
String friend2 = 'bread';
String friend3 = 'The14th';
String friend4 = 'Carvendish';
String friend5 = 'D1yah';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: appTitle,
      theme: ThemeData.dark(),
      home: const SocialPage(),
    );
  }
}

class SocialPage extends StatelessWidget {
  const SocialPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF151112),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                appTitle,
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  tabText('Friends', true),
                  const SizedBox(width: 40),
                  tabText('Messages', false),
                  const SizedBox(width: 40),
                  tabText('Requests', false),
                ],
              ),

              const SizedBox(height: 15),

              Container(width: 65, height: 3, color: Colors.redAccent),

              const SizedBox(height: 20),

              Card(
                color: const Color(0xFF242021),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(15),
                  child: Row(
                    children: [
                      Icon(Icons.search, size: 30, color: Colors.white70),
                      SizedBox(width: 15),
                      Text(
                        'Search',
                        style: TextStyle(fontSize: 18, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 25),

              Row(
                children: [
                  Text(
                    gameName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$gameFriends',
                    style: const TextStyle(color: Colors.white54, fontSize: 16),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              friendCard(friend1, 'Online - VALORANT'),
              friendCard(friend2, 'Playing - VALORANT'),
              friendCard(friend3, 'Playing - VALORANT'),

              const SizedBox(height: 15),

              const Row(
                children: [
                  Text(
                    'Online',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 8),
                  Text('4', style: TextStyle(color: Colors.white54)),
                ],
              ),

              const SizedBox(height: 10),

              friendCard(friend4, 'Away - Riot Mobile'),
              friendCard(friend5, 'Away - Riot Mobile'),
            ],
          ),
        ),
      ),
    );
  }

  Widget tabText(String text, bool selected) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 16,
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        color: selected ? Colors.white : Colors.white60,
      ),
    );
  }

  Widget friendCard(String name, String status) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 25,
            backgroundColor: Color(0xFF242021),
            child: Icon(Icons.person, color: Colors.redAccent, size: 30),
          ),

          const SizedBox(width: 15),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 3),

              Row(
                children: [
                  const Icon(Icons.computer, size: 17, color: Colors.white60),
                  const SizedBox(width: 5),
                  Text(
                    status,
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
