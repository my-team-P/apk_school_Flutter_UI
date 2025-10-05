import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:admin/screens/main/main_screen.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List exams = [];
  List grades = [];
  List library = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchLatestItems();
  }

  Future<void> fetchLatestItems() async {
    try {
      final response = await http
          .get(Uri.parse('http://192.168.1.104:8000/api/notifications'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (!mounted) return; // <--- التحقق قبل setState
        setState(() {
          exams = data['exams'];
          grades = data['grades'];
          library = data['library'];
          loading = false;
        });
      } else {
        if (!mounted) return;
        setState(() => loading = false);
        print("Error fetching data");
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);
      print("Exception: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'آخر الإضافات',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue[700],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MainScreen()),
            );
          },
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildSection("آخر الاختبارات", exams, isExam: true),
                  const SizedBox(height: 20),
                  buildSection("آخر الدرجات", grades, isGrade: true),
                  const SizedBox(height: 20),
                  buildSection("المكتبة", library, isLibrary: true),
                ],
              ),
            ),
    );
  }

  Widget buildSection(String title, List items,
      {bool isExam = false, bool isGrade = false, bool isLibrary = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        items.isEmpty
            ? const Text("لا توجد بيانات")
            : Column(
                children: items.map((item) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text(
                        isExam
                            ? item['note'] ?? 'بدون ملاحظة'
                            : isGrade
                                ? 'الدرجة: ${item['score']}/${item['total_score']}'
                                : item['book_title'] ?? 'بدون عنوان',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        isExam
                            ? 'نوع الاختبار: ${item['type']}, الحالة: ${item['status']}, الأهمية: ${item['importance']}'
                            : isGrade
                                ? 'تقييم: ${item['evaluation']}, نوع الاختبار: ${item['exam_type']}'
                                : 'المؤلف: ${item['author'] ?? '-'}\nالناشر: ${item['publisher'] ?? '-'}',
                      ),
                      trailing: isGrade && item['exam_paper'] != null
                          ? IconButton(
                              icon: const Icon(Icons.image),
                              onPressed: () {
                                // عرض صورة ورقة الاختبار
                                showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: const Text("ورقة الاختبار"),
                                    content: Image.network(
                                        'http://192.168.1.104:8000/storage/${item['exam_paper']}'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text("إغلاق"),
                                      )
                                    ],
                                  ),
                                );
                              },
                            )
                          : null,
                    ),
                  );
                }).toList(),
              ),
      ],
    );
  }
}
