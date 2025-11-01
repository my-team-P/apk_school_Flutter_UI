import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:admin/screens/main/main_screen.dart';

class LibraryPage extends StatefulWidget {
  final String role;

  const LibraryPage({super.key, required this.role});

  @override
  State<LibraryPage> createState() => LibraryPageState();
}

class LibraryPageState extends State<LibraryPage> {
  List books = [];
  bool isLoading = true;
  String searchQuery = '';
  String? selectedCategory;

  @override
  void initState() {
    super.initState();
    fetchLibrary();
  }

// جلب بيانات الكتب من السيرفر
  Future<void> fetchLibrary() async {
    final url = Uri.parse('http://192.168.1.101:8000/api/library');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        setState(() {
          books = decoded is List ? decoded : (decoded['data'] ?? []);
          isLoading = false;
        });
      } else {
        _showErrorSnackBar(
            'فشل في تحميل بيانات المكتبة (${response.statusCode})');
        setState(() => isLoading = false);
      }
    } catch (e) {
      _showErrorSnackBar('حدث خطأ في الاتصال بالسيرفر');
      setState(() => isLoading = false);
    }
  }

//فتح ملف الكتاب
  Future<void> openFile(String filePath) async {
    String url = filePath.startsWith('http')
        ? filePath
        : 'http://192.168.1.101:8000/storage/$filePath';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      _showErrorSnackBar('لا يمكن فتح الرابط');
    }
  }

//حذف كتاب معين من قاعدة البيانات
  Future<void> deleteBook(int id) async {
    final url = Uri.parse('http://192.168.1.101:8000/api/library/$id');
    try {
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        _showSuccessSnackBar('تم حذف الكتاب بنجاح');
        fetchLibrary();
      } else {
        _showErrorSnackBar('فشل في حذف الكتاب (${response.statusCode})');
      }
    } catch (e) {
      _showErrorSnackBar('حدث خطأ أثناء الحذف');
    }
  }

//عرض نافذة تعديل البيانات
  Future<void> editBook(Map book) async {
    final formKey = GlobalKey<FormState>();
    String bookTitle = book['book_title'] ?? '';
    String author = book['author'] ?? '';
    String publisher = book['publisher'] ?? '';
    String category = book['category'] ?? '';
    String gradeId = book['grade_id']?.toString() ?? '';
    String subjectId = book['subject_id']?.toString() ?? '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('تعديل بيانات الكتاب'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  //تُستخدم لإدخال نصوص داخل نموذج
                  TextFormField(
                    //هي القيمة الافتراضية التي تظهر في الحقل
                    initialValue: bookTitle,
                    decoration:
                        //تتحكم بشكل وتصميم الحقل
                        const InputDecoration(labelText: 'عنوان الكتاب'),
                    onChanged: (value) => bookTitle = value,
                    //تُستخدم للتحقق من صحة النص المدخل.
                    validator: (value) =>
                        value!.isEmpty ? 'الرجاء إدخال عنوان الكتاب' : null,
                  ),
                  TextFormField(
                    initialValue: author,
                    decoration: const InputDecoration(labelText: 'المؤلف'),
                    onChanged: (value) => author = value,
                    validator: (value) =>
                        value!.isEmpty ? 'الرجاء إدخال اسم المؤلف' : null,
                  ),
                  TextFormField(
                    initialValue: publisher,
                    decoration: const InputDecoration(labelText: 'الناشر'),
                    onChanged: (value) => publisher = value,
                  ),
                  TextFormField(
                    initialValue: category,
                    decoration: const InputDecoration(labelText: 'الفئة'),
                    onChanged: (value) => category = value,
                  ),
                  TextFormField(
                    initialValue: gradeId,
                    decoration: const InputDecoration(labelText: 'الصف'),
                    onChanged: (value) => gradeId = value,
                  ),
                  TextFormField(
                    initialValue: subjectId,
                    decoration: const InputDecoration(labelText: 'المادة'),
                    onChanged: (value) => subjectId = value,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  await updateBook(book['id'], {
                    'book_title': bookTitle,
                    'author': author,
                    'publisher': publisher,
                    'category': category,
                    'grade_id': gradeId,
                    'subject_id': subjectId,
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('حفظ'),
            ),
          ],
        );
      },
    );
  }

//تعديل بيانات الكتاب في السيرفر
  Future<void> updateBook(int id, Map<String, dynamic> data) async {
    final url = Uri.parse('http://192.168.1.101:8000/api/library/$id');
    try {
      final response = await http.put(url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(data));
      if (response.statusCode == 200) {
        _showSuccessSnackBar('تم تعديل بيانات الكتاب بنجاح');
        fetchLibrary();
      } else {
        _showErrorSnackBar('فشل تعديل الكتاب (${response.statusCode})');
      }
    } catch (e) {
      _showErrorSnackBar('حدث خطأ عند تعديل الكتاب');
    }
  }

//يُرجع قائمة تحتوي على الكتب التي تطابق شروط البحث أو التصنيف.
  List get filteredBooks {
    List filtered = books;
    if (searchQuery.isNotEmpty) {
      filtered = filtered
          .where((book) =>
              (book['book_title']?.toString().toLowerCase() ?? '')
                  .contains(searchQuery.toLowerCase()) ||
              (book['author']?.toString().toLowerCase() ?? '')
                  .contains(searchQuery.toLowerCase()) ||
              (book['category']?.toString().toLowerCase() ?? '')
                  .contains(searchQuery.toLowerCase()))
          .toList();
    }
    if (selectedCategory != null) {
      filtered = filtered
          .where((book) => book['category'] == selectedCategory)
          .toList();
    }
    return filtered;
  }

//ترجع قائمة بالفئات فقط على شكل نصوص.
  List<String> get categories {
    Set<String> categories = {};
    for (var book in books) {
      if (book['category'] != null) categories.add(book['category']);
    }
    return categories.toList()..sort();
  }

//عرض رسالة نجاح للمستخدم في أسفل الشاشة عن نجاح العملية
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating),
    );
  }

//تُظهر رسالة، لكنها لا تعيد نتيجة.
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => MainScreen(role: widget.role)),
            );
          },
        ),
        title: const Text('المكتبة',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchFilterBar(context),
            _buildResultsInfo(context),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredBooks.isEmpty
                      ? _buildEmptyState(context)
                      : _buildBooksList(context),
            ),
          ],
        ),
      ),
    );
  }

//يبني شريط البحث والفلاتر أعلى الصفحة.
  Widget _buildSearchFilterBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          TextField(
            decoration: const InputDecoration(
                hintText: 'ابحث عن كتاب...', prefixIcon: Icon(Icons.search)),
            onChanged: (value) => setState(() => searchQuery = value),
          ),
          const SizedBox(height: 8),
          if (categories.isNotEmpty)
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildFilterChip('الكل', null),
                  ...categories
                      .map((category) => _buildFilterChip(category, category)),
                ],
              ),
            ),
        ],
      ),
    );
  }

//يبني زر فئة (فلتر) واحد.
  Widget _buildFilterChip(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text(label),
        selected: selectedCategory == value,
        onSelected: (selected) =>
            setState(() => selectedCategory = selected ? value : null),
        backgroundColor: Colors.grey[200],
        selectedColor: Colors.blue[100],
        checkmarkColor: Colors.blue,
      ),
    );
  }

//يبني شريطًا صغيرًا أسفل البحث لعرض عدد الكتب.
  Widget _buildResultsInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.grey[50],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('عدد الكتب: ${filteredBooks.length}',
              style: const TextStyle(color: Colors.grey)),
          if (selectedCategory != null || searchQuery.isNotEmpty)
            TextButton(
              onPressed: () => setState(() {
                searchQuery = '';
                selectedCategory = null;
              }),
              child: const Text('مسح الفلتر'),
            ),
        ],
      ),
    );
  }

//يُعرض عندما لا توجد كتب في النتائج.
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.menu_book, size: 60, color: Colors.grey),
          SizedBox(height: 16),
          Text('لا توجد كتب في المكتبة', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

//يبني قائمة الكتب
  Widget _buildBooksList(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: filteredBooks.length,
      itemBuilder: (context, index) => _buildBookCard(filteredBooks[index]),
    );
  }

//يبني بطاقة كتاب واحدة.
  Widget _buildBookCard(Map book) {
    bool canEditOrDelete = widget.role == 'admin' || widget.role == 'teacher';

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                    child: Text(book['book_title'] ?? 'لا يوجد عنوان',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.blue))),
                if (book['file_path'] != null)
                  IconButton(
                      icon:
                          const Icon(Icons.file_download, color: Colors.green),
                      onPressed: () => openFile(book['file_path'])),
                if (canEditOrDelete)
                  IconButton(
                      icon: const Icon(Icons.edit, color: Colors.orange),
                      onPressed: () => editBook(book)),
                if (canEditOrDelete)
                  IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => deleteBook(book['id'])),
              ],
            ),
            _buildBookInfo(book),
          ],
        ),
      ),
    );
  }

//يبني تفاصيل الكتاب أسفل العنوان
  Widget _buildBookInfo(Map book) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCompactInfoRow('المؤلف:', book['author']),
        _buildCompactInfoRow('الناشر:', book['publisher']),
        _buildCompactInfoRow('الفئة:', book['category']),
        _buildCompactInfoRow('الصف:', book['grade_id']),
        _buildCompactInfoRow('المادة:', book['subject_id']),
      ],
    );
  }

//يبني صفًا أفقيًا صغيرًايحتوي المؤلف
  Widget _buildCompactInfoRow(String label, dynamic value) {
    return Row(
      children: [
        Text('$label ',
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.grey)),
        Expanded(child: Text(value?.toString() ?? 'غير محدد')),
      ],
    );
  }
}
