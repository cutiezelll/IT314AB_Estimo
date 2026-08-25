import 'package:flutter/material.dart';

class Player {
  String image;
  String name;
  int mmr;
  String details;

  Player({
    required this.image,
    required this.name,
    required this.mmr,
    required this.details,
  });
}

List<Player> player = [
  Player(
    image: 'assets/brimstone.webp',
    name: 'Zenshin231',
    mmr: 261,
    details: '34/0/1',
  ),

  Player(
    image: 'assets/chamber.webp',
    name: 'Zet_Zet',
    mmr: 190,
    details: '4/13/4',
  ),

  Player(
    image: 'assets/clove.webp',
    name: 'Nolez754',
    mmr: 89,
    details: '1/10/2',
  ),

  Player(
    image: 'assets/cypher.webp',
    name: '_Matyed',
    mmr: 298,
    details: '3/5/9',
  ),

  Player(
    image: 'assets/phoenix.webp',
    name: 'Matchaed_23',
    mmr: 259,
    details: '8/0/10',
  ),

  Player(
    image: 'assets/rave.webp',
    name: 'Zenshin231',
    mmr: 219,
    details: '9/3/6',
  ),

  Player(
    image: 'assets/reyna.webp',
    name: 'Zenshin231',
    mmr: 191,
    details: '24/15/8',
  ),

  Player(
    image: 'assets/sova.webp',
    name: 'Zenshin231',
    mmr: 203,
    details: '5/4/2',
  ),
];

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.black,

        appBar: AppBar(
          title: const Text('< Match Details'),
          backgroundColor: Colors.red,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              for (Player player in player)
                Card(
                  margin: const EdgeInsets.all(15),
                  color: Colors.grey[900],

                  child: Padding(
                    padding: const EdgeInsets.all(15),

                    child: Row(
                      children: [
                        
                        ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.asset(
                            player.image,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),

                        const SizedBox(width: 15),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                player.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 5),

                              Text(
                                'MMR: ${player.mmr}',
                                style: const TextStyle(
                                  color: Colors.orange,
                                  fontSize: 16,
                                ),
                              ),

                              const SizedBox(height: 5),

                              Text(
                                'K/D/A: ${player.details}',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}