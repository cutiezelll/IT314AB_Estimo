import 'package:flutter/material.dart';

class Student {
  String image;
  String name;
  String course;
  String yearLevel;
  int age;
  String hobby;
  String studentId;
  String email;
  String favoriteSubject;
  bool isFavorite;
  int likeCount;

  Student({
    required this.image,
    required this.name,
    required this.course,
    required this.yearLevel,
    required this.age,
    required this.hobby,
    required this.studentId,
    required this.email,
    required this.favoriteSubject,
    this.isFavorite = false,
    this.likeCount = 0,
  });
}

List<Student> students = [
  Student(
    image: 'assets/zelon.jpg',
    name: 'Zelon Estimo',
    course: 'BSIT',
    yearLevel: '3rd Year',
    age: 21,
    hobby: 'Photography',
    studentId: '2980',
    email: 'estimozelon@gmail.com',
    favoriteSubject: 'UI/UX Designing',
  ),
  Student(
    image: 'assets/ryan.jpg',
    name: 'Ryan Porquiado',
    course: 'BSIT',
    yearLevel: '4th Year',
    age: 21,
    hobby: 'Drilling',
    studentId: '2986',
    email: 'ryanporquiado@gmail.com',
    favoriteSubject: 'Recess',
  ),
  Student(
    image: 'assets/leon.jpg',
    name: 'Leonardo Cajes Jr.',
    course: 'BSTM',
    yearLevel: '4th Year',
    age: 21,
    hobby: 'Twerking',
    studentId: '2988',
    email: 'leonardocajes@gmail.com',
    favoriteSubject: 'Research',
  ),
  Student(
    image: 'assets/jackie.jpg',
    name: 'Jacklyn Reyes',
    course: 'BSTM',
    yearLevel: '4th Year',
    age: 22,
    hobby: 'Fishing',
    studentId: '6374',
    email: 'jacklynreyes@gmail.com',
    favoriteSubject: 'Traveling & Tour',
  ),
  Student(
    image: 'assets/julie.jpg',
    name: 'Julie Ann Malinao',
    course: 'BSIT',
    yearLevel: '4th Year',
    age: 21,
    hobby: 'Eating',
    studentId: '3234',
    email: 'julieannmalinao@gmail.com',
    favoriteSubject: 'Fundamentals of Database System',
  ),
];

void main() {
  students.sort((a, b) => a.name.compareTo(b.name));
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Toggling favorite updates three things at once, all inside setState:
  // 1. isFavorite -> changes the heart icon
  // 2. likeCount -> the counter text goes up/down
  // 3. the SnackBar text also depends on the new isFavorite value
  void toggleFavorite(BuildContext context, Student student) {
    setState(() {
      student.isFavorite = !student.isFavorite;
      student.isFavorite ? student.likeCount++ : student.likeCount--;
    });

    print("${student.name} Favorite pressed");

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          student.isFavorite
              ? "You liked this person!"
              : "${student.name} removed from favorites",
        ),
        duration: const Duration(seconds: 1),
      ), // SnackBar
    );
  }

  // Remove a student from the list and refresh the screen
  void deleteStudent(BuildContext context, Student student) {
    setState(() {
      students.remove(student);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${student.name} removed"),
        duration: const Duration(seconds: 1),
      ), // SnackBar
    );
  }

  // Show edit placeholder dialog.
  // IMPORTANT: this needs a context that is BELOW MaterialApp in the
  // widget tree (e.g. from itemBuilder), not the State's own `context`
  // (which is above MaterialApp). Using the wrong one causes
  // "No MaterialLocalizations found".
  void showEditDialog(BuildContext context, Student student) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit ${student.name}"),
          content: const Text("Edit form coming soon."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  Widget profileCard(BuildContext context, Student student) {
    return GestureDetector(
      key: ValueKey(student.studentId),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("You clicked ${student.name}'s profile."),
            duration: const Duration(seconds: 1),
          ), // SnackBar
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Center(
                      child: Image.asset(
                        student.image,
                        width: 100,
                        height: 100,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 100,
                            height: 100,
                            color: Colors.grey[300],
                            child: const Icon(Icons.person, size: 50),
                          );
                        },
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => toggleFavorite(context, student),
                    icon: Icon(
                      student.isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: Colors.deepPurple,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Text(
                student.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text('${student.course} - ${student.yearLevel}'),
              const SizedBox(height: 6),
              Text('Age: ${student.age}'),
              Text('Hobby: ${student.hobby}'),
              Text('Student ID: ${student.studentId}'),
              Text('Email: ${student.email}'),
              Text('Favorite Subject: ${student.favoriteSubject}'),
              Text('Likes: ${student.likeCount}'),

              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => showEditDialog(context, student),
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => deleteStudent(context, student),
                    icon: const Icon(Icons.delete),
                    label: const Text('Delete'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFFE7E3E3),
        appBar: AppBar(title: const Text('My First Flutter Application')),
        body: students.isEmpty
            ? const Center(
                child: Text(
                  'No students found.',
                  style: TextStyle(fontSize: 18),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: students.length,
                itemBuilder: (context, index) {
                  return profileCard(context, students[index]);
                },
              ),
      ),
    );
  }
}
