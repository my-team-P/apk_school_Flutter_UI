import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:admin/screens/main/main_screen.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  List books = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchLibrary();
  }

  Future<void> fetchLibrary() async {
    final url =
        Uri.parse('http://192.168.1.102:8000/api/library'); // رابط Laravel API
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          books = json.decode(response.body);
          isLoading = false;
        });
      } else {
        print('Failed to load library data');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> openFile(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      print('لا يمكن فتح الرابط: $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back, color: Color.fromARGB(255, 0, 0, 0)),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MainScreen()),
            );
          },
        ),
        title: const Text('المكتبة'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : books.isEmpty
              ? const Center(child: Text('لا توجد كتب في المكتبة'))
              : ListView.builder(
                  itemCount: books.length,
                  itemBuilder: (context, index) {
                    final book = books[index];
                    return Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      child: ListTile(
                        title: Text(
                          book['book_title'] ?? 'لا يوجد عنوان',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        subtitle: Text(
                          'المؤلف: ${book['author'] ?? 'غير معروف'}\n'
                          'الناشر: ${book['publisher'] ?? 'غير معروف'}\n'
                          'الفئة: ${book['category'] ?? 'غير معروف'}\n'
                          'الصف: ${book['grade_id'] ?? 'غير محدد'}\n'
                          'المادة: ${book['subject_id'] ?? 'غير محددة'}\n'
                          'اسم الملف: ${book['file_name'] ?? 'غير محدد'}',
                        ),
                        trailing: book['file_path'] != null
                            ? IconButton(
                                icon: const Icon(Icons.file_present,
                                    color: Colors.blue),
                                onPressed: () {
                                  openFile(book['file_path']);
                                },
                              )
                            : null,
                      ),
                    );
                  },
                ),
    );
  }
}
