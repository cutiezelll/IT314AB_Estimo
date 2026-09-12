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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Widget studentCard(Student student) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                student.image,
                width: 120,
                height: 120,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 120,
                    height: 120,
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.person,
                      size: 60,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 10),

            Text(
              student.name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 5),

            Text(
              '${student.course} - ${student.yearLevel}',
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 5),

            Text('Age: ${student.age}'),
            Text('Hobby: ${student.hobby}'),
            Text('Student ID: ${student.studentId}'),
            Text('Email: ${student.email}'),
            Text('Favorite Subject: ${student.favoriteSubject}'),
          ],
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

        appBar: AppBar(title: const Text('Student Directory')),

        body: ListView.builder(
          padding: const EdgeInsets.all(8),

          itemCount: students.length,

          itemBuilder: (context, index) {
            return studentCard(students[index]);
          },
        ),
      ),
    );
  }
}
