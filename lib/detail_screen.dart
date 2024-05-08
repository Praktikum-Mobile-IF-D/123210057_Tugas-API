import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Book {
  final String abbrevPt;
  final String abbrevEn;
  final String author;
  final int chapters;
  final String group;
  final String name;
  final String testament;

  Book({
    required this.abbrevPt,
    required this.abbrevEn,
    required this.author,
    required this.chapters,
    required this.group,
    required this.name,
    required this.testament,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      abbrevPt: json['abbrev']['pt'],
      abbrevEn: json['abbrev']['en'],
      author: json['author'],
      chapters: json['chapters'],
      group: json['group'],
      name: json['name'],
      testament: json['testament'],
    );
  }
}

class DataPage extends StatefulWidget {
  @override
  _DataPageState createState() => _DataPageState();
}

class _DataPageState extends State<DataPage> {
  late Future<List<Book>> futureBooks;

  @override
  void initState() {
    super.initState();
    futureBooks = fetchBooks();
  }

  Future<List<Book>> fetchBooks() async {
    final response = await http.get(Uri.parse('https://www.abibliadigital.com.br/api/books'));

    if (response.statusCode == 200) {
      List<Book> books = [];
      List<dynamic> jsonData = jsonDecode(response.body);
      jsonData.forEach((book) {
        books.add(Book.fromJson(book));
      });
      return books;
    } else {
      throw Exception('Failed to load books');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('List of Books'),
      ),
      body: SafeArea(
        child: FutureBuilder<List<Book>>(
          future: futureBooks,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailPage(book: snapshot.data![index]),
                        ),
                      );
                    },
                    child: Card(
                      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      child: ListTile(
                        title: Text(snapshot.data![index].name),
                        subtitle: Text(snapshot.data![index].abbrevEn),
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}

class DetailPage extends StatelessWidget {
  final Book book;

  const DetailPage({required this.book});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Page'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Name: ${book.name}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Author: ${book.author}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              'Chapters: ${book.chapters}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              'Group: ${book.group}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              'Testament: ${book.testament}',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: DataPage(),
  ));
}
