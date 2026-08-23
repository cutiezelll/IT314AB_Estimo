import 'package:flutter/material.dart';

// Profile class
class Profile {
  String? image;
  String? name;
  String? courseSection;
  int? age;
  String? hobby;

  Profile({
    required this.image,
    required this.name,
    required this.courseSection,
    required this.age,
    required this.hobby,
  });
}

// Five different profiles
List<Profile> profiles = [
  Profile(
    image: 'assets/zelon.png',
    name: 'Zelon Estimo',
    courseSection: null,
    age: 21,
    hobby: 'Photographer',
  ),

  Profile(
    image: 'assets/ryan.png',
    name: null,
    courseSection: 'BSIT-4',
    age: 21,
    hobby: 'Drilling',
  ),

  Profile(
    image: 'assets/leon.png',
    name: 'Leonardo Cajes Jr.',
    courseSection: null,
    age: 21,
    hobby: 'Twerking',
  ),
  Profile(
    image: 'assets/jackie.png',
    name: 'Jacklyn Reyes',
    courseSection: 'BSTM-4',
    age: null,
    hobby: 'Fishing',
  ),
  Profile(
    image: 'assets/julie.png',
    name: 'Julie Ann Malinao',
    courseSection: 'BSIT-4',
    age: 21,
    hobby: null,
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
        appBar: AppBar(title: const Text('Five Profiles')),

        // Provides scrolling capability
        // when the content is larger than the screen
        body: SingleChildScrollView(
          child: Column(
            children: [
              for (Profile profile in profiles)
                Card(
                  margin: const EdgeInsets.all(15),
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Row(
                      children: [
                        // Profile image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.asset(
                            profile.image ?? 'Missing',
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),

                        const SizedBox(width: 15),

                        // Profile information
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                profile.name ?? 'Unknown',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 5),

                              Text(
                                profile.courseSection ?? 'Missing',
                                style: const TextStyle(fontSize: 16),
                              ),

                              const SizedBox(height: 5),

                              Text(
                                "Age: ${profile.age ?? 'Missing'}",
                                style: const TextStyle(fontSize: 16),
                              ),

                              const SizedBox(height: 5),

                              Text(
                                "Hobby: ${profile.hobby ?? 'Not Provided'}",
                                style: const TextStyle(fontSize: 16),
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
