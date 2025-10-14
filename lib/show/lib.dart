import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:admin/screens/main/main_screen.dart';

class LibraryPage extends StatefulWidget {
  final String role; // <-- أضف هذا

  const LibraryPage({super.key, required this.role});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  List books = [];
  bool isLoading = true;
  String searchQuery = '';
  String? selectedCategory;

  @override
  void initState() {
    super.initState();
    fetchLibrary();
  }

  Future<void> fetchLibrary() async {
    final url = Uri.parse('http://192.168.1.107:8000/api/library');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          books = json.decode(response.body);
          isLoading = false;
        });
      } else {
        _showErrorSnackBar('فشل في تحميل بيانات المكتبة');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error: $e');
      _showErrorSnackBar('حدث خطأ في الاتصال');
      setState(() {
        isLoading = false;
      });
    }
  }

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

  List<String> get categories {
    Set<String> categories = {};
    for (var book in books) {
      if (book['category'] != null) {
        categories.add(book['category']);
      }
    }
    return categories.toList()..sort();
  }

  Future<void> openFile(String filePath) async {
    String url = filePath.startsWith('http')
        ? filePath
        : 'http://192.168.1.106:8000/storage/$filePath';

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      print('لا يمكن فتح الرابط: $url');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // دالة لحساب الحجم النسبي بناءً على حجم الشاشة
  double _getResponsiveSize(double baseSize, BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final minDimension =
        screenWidth < screenHeight ? screenWidth : screenHeight;

    if (minDimension < 360) {
      return baseSize * 0.75;
    } else if (minDimension < 400) {
      return baseSize * 0.85;
    } else if (minDimension > 1000) {
      return baseSize * 1.4;
    } else {
      return baseSize;
    }
  }

  // دالة لحساب الحجم النسبي للنص
  double _getResponsiveTextSize(double baseSize, BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < 360) {
      return baseSize * 0.8;
    } else if (screenWidth < 400) {
      return baseSize * 0.9;
    } else if (screenWidth > 1000) {
      return baseSize * 1.3;
    } else {
      return baseSize;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: Colors.black, size: _getResponsiveSize(24, context)),
          onPressed: () {
           Navigator.pushReplacement(
  context,
  MaterialPageRoute(
    builder: (context) => MainScreen(role: widget.role), // <-- هنا
  ),
);

          },
        ),
        title: Text(
          'المكتبة',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: _getResponsiveTextSize(18, context),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        toolbarHeight: _getResponsiveSize(56, context),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                // شريط البحث والتصفية
                _buildSearchFilterBar(context),

                // معلومات النتائج
                _buildResultsInfo(context),

                // مؤشر التحميل أو قائمة الكتب
                Expanded(
                  child: isLoading
                      ? _buildLoadingIndicator(context)
                      : filteredBooks.isEmpty
                          ? _buildEmptyState(context)
                          : _buildBooksList(context),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddBookDialog();
        },
        backgroundColor: Colors.blue,
        child: Icon(Icons.add,
            color: Colors.white, size: _getResponsiveSize(28, context)),
      ),
    );
  }

  Widget _buildSearchFilterBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(_getResponsiveSize(12, context)),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          // شريط البحث
          TextField(
            decoration: InputDecoration(
              hintText: 'ابحث عن كتاب...',
              prefixIcon:
                  Icon(Icons.search, size: _getResponsiveSize(20, context)),
              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(_getResponsiveSize(10, context)),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: _getResponsiveSize(12, context),
                vertical: _getResponsiveSize(8, context),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            onChanged: (value) {
              setState(() {
                searchQuery = value;
              });
            },
          ),
          SizedBox(height: _getResponsiveSize(8, context)),

          // قائمة التصفية بالفئة
          if (categories.isNotEmpty)
            SizedBox(
              height: _getResponsiveSize(40, context),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildFilterChip('الكل', null, context),
                  ...categories
                      .map((category) =>
                          _buildFilterChip(category, category, context))
                      ,
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String? value, BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: _getResponsiveSize(4, context)),
      child: FilterChip(
        label: Text(
          label,
          style: TextStyle(fontSize: _getResponsiveTextSize(12, context)),
        ),
        selected: selectedCategory == value,
        onSelected: (selected) {
          setState(() {
            selectedCategory = selected ? value : null;
          });
        },
        backgroundColor: Colors.grey[200],
        selectedColor: Colors.blue[100],
        checkmarkColor: Colors.blue,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        labelPadding:
            EdgeInsets.symmetric(horizontal: _getResponsiveSize(8, context)),
      ),
    );
  }

  Widget _buildResultsInfo(BuildContext context) {
    if (isLoading) return const SizedBox();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _getResponsiveSize(16, context),
        vertical: _getResponsiveSize(8, context),
      ),
      color: Colors.grey[50],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'عدد الكتب: ${filteredBooks.length}',
            style: TextStyle(
              fontSize: _getResponsiveTextSize(12, context),
              color: Colors.grey,
            ),
          ),
          if (selectedCategory != null || searchQuery.isNotEmpty)
            TextButton(
              onPressed: () {
                setState(() {
                  searchQuery = '';
                  selectedCategory = null;
                });
              },
              child: Text(
                'مسح الفلتر',
                style: TextStyle(fontSize: _getResponsiveTextSize(12, context)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            strokeWidth: _getResponsiveSize(2, context),
          ),
          SizedBox(height: _getResponsiveSize(12, context)),
          Text(
            'جاري تحميل الكتب...',
            style: TextStyle(
              fontSize: _getResponsiveTextSize(14, context),
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(_getResponsiveSize(20, context)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.menu_book,
                size: _getResponsiveSize(60, context),
                color: Colors.grey[300],
              ),
              SizedBox(height: _getResponsiveSize(16, context)),
              Text(
                'لا توجد كتب في المكتبة',
                style: TextStyle(
                  fontSize: _getResponsiveTextSize(16, context),
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: _getResponsiveSize(8, context)),
              Text(
                'انقر على زر + لإضافة كتاب جديد',
                style: TextStyle(
                  fontSize: _getResponsiveTextSize(12, context),
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBooksList(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(_getResponsiveSize(8, context)),
      itemCount: filteredBooks.length,
      itemBuilder: (context, index) {
        final book = filteredBooks[index];
        return _buildBookCard(book, context);
      },
    );
  }

  Widget _buildBookCard(Map book, BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_getResponsiveSize(12, context)),
      ),
      margin: EdgeInsets.symmetric(
        horizontal: _getResponsiveSize(8, context),
        vertical: _getResponsiveSize(6, context),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(_getResponsiveSize(12, context)),
          color: Colors.white,
        ),
        child: Padding(
          padding: EdgeInsets.all(_getResponsiveSize(12, context)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // العنوان والأزرار
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      book['book_title'] ?? 'لا يوجد عنوان',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: _getResponsiveTextSize(16, context),
                        color: Colors.blue,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(
                      width:
                          _getResponsiveSize(4, context)), // تقليل المسافة هنا
                  _buildActionButtons(book, context),
                ],
              ),
              SizedBox(height: _getResponsiveSize(8, context)),

              // معلومات الكتاب
              _buildBookInfo(book, context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(Map book, BuildContext context) {
    return Container(
      // إزالة العرض الثابت لجعل الأزرار تتكيف مع المحتوى
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min, // مهم: يجعل الصف يأخذ أقل مساحة ممكنة
        children: [
          if (book['file_path'] != null)
            _buildSmallActionButton(
              Icons.file_download,
              Colors.green,
              'فتح الملف',
              () => openFile(book['file_path']),
              context,
            ),
          _buildSmallActionButton(
            Icons.edit,
            Colors.orange,
            'تعديل',
            () => showEditDialog(book, context),
            context,
          ),
          _buildSmallActionButton(
            Icons.delete,
            Colors.red,
            'حذف',
            () => _showDeleteConfirmation(book, context),
            context,
          ),
        ],
      ),
    );
  }

  Widget _buildSmallActionButton(IconData icon, Color color, String tooltip,
      VoidCallback onPressed, BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
          horizontal:
              _getResponsiveSize(1, context)), // تقليل المسافة بين الأزرار
      child: IconButton(
        icon: Icon(icon, size: _getResponsiveSize(18, context)),
        color: color,
        tooltip: tooltip,
        onPressed: onPressed,
        padding: EdgeInsets.all(
            _getResponsiveSize(3, context)), // تقليل الحشوة الداخلية
        constraints: BoxConstraints(
          minWidth: _getResponsiveSize(28, context), // تقليل العرض الأدنى
          minHeight: _getResponsiveSize(28, context), // تقليل الارتفاع الأدنى
        ),
      ),
    );
  }

  Widget _buildBookInfo(Map book, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCompactInfoRow('المؤلف:', book['author'], context),
        _buildCompactInfoRow('الناشر:', book['publisher'], context),
        _buildCompactInfoRow('الفئة:', book['category'], context),
        _buildCompactInfoRow('الصف:', book['grade_id'], context),
        _buildCompactInfoRow('المادة:', book['subject_id'], context),
        if (book['file_name'] != null)
          _buildCompactInfoRow('الملف:', book['file_name'], context),
      ],
    );
  }

  Widget _buildCompactInfoRow(
      String label, dynamic value, BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: _getResponsiveSize(1, context)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label ',
            style: TextStyle(
              fontSize: _getResponsiveTextSize(12, context),
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          Expanded(
            child: Text(
              value?.toString() ?? 'غير محدد',
              style: TextStyle(fontSize: _getResponsiveTextSize(12, context)),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(Map book, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_getResponsiveSize(12, context)),
        ),
        child: Padding(
          padding: EdgeInsets.all(_getResponsiveSize(16, context)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'تأكيد الحذف',
                style: TextStyle(
                  fontSize: _getResponsiveTextSize(16, context),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: _getResponsiveSize(16, context)),
              Text(
                'هل أنت متأكد من حذف الكتاب "${book['book_title']}"؟',
                style: TextStyle(fontSize: _getResponsiveTextSize(14, context)),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: _getResponsiveSize(16, context)),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'إلغاء',
                        style: TextStyle(
                            fontSize: _getResponsiveTextSize(14, context)),
                      ),
                    ),
                  ),
                  SizedBox(width: _getResponsiveSize(8, context)),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        deleteBook(book['id']);
                      },
                      style:
                          ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: Text(
                        'حذف',
                        style: TextStyle(
                            fontSize: _getResponsiveTextSize(14, context)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> deleteBook(int id) async {
    final url = Uri.parse('http://192.168.1.107:8000/api/library/$id');
    try {
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        _showSuccessSnackBar('تم حذف الكتاب بنجاح');
        fetchLibrary();
      } else {
        _showErrorSnackBar('فشل حذف الكتاب');
      }
    } catch (e) {
      _showErrorSnackBar('حدث خطأ أثناء الحذف');
    }
  }

  Future<void> updateBook(int id, Map<String, String> updatedData) async {
    final url = Uri.parse('http://192.168.1.107:8000/api/library/$id');
    try {
      final response = await http.put(url, body: updatedData);
      if (response.statusCode == 200) {
        _showSuccessSnackBar('تم تعديل الكتاب بنجاح');
        fetchLibrary();
      } else {
        _showErrorSnackBar('فشل تعديل الكتاب');
      }
    } catch (e) {
      _showErrorSnackBar('حدث خطأ أثناء التعديل');
    }
  }

  void showEditDialog(Map book, BuildContext context) {
    final titleController = TextEditingController(text: book['book_title']);
    final authorController = TextEditingController(text: book['author']);
    final publisherController = TextEditingController(text: book['publisher']);
    final categoryController = TextEditingController(text: book['category']);

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(_getResponsiveSize(12, context)),
          ),
          child: Padding(
            padding: EdgeInsets.all(_getResponsiveSize(16, context)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'تعديل الكتاب',
                  style: TextStyle(
                    fontSize: _getResponsiveTextSize(16, context),
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(height: _getResponsiveSize(16, context)),
                _buildCompactTextField(
                    titleController, 'العنوان', Icons.title, context),
                _buildCompactTextField(
                    authorController, 'المؤلف', Icons.person, context),
                _buildCompactTextField(
                    publisherController, 'الناشر', Icons.business, context),
                _buildCompactTextField(
                    categoryController, 'الفئة', Icons.category, context),
                SizedBox(height: _getResponsiveSize(16, context)),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'إلغاء',
                          style: TextStyle(
                              fontSize: _getResponsiveTextSize(14, context)),
                        ),
                      ),
                    ),
                    SizedBox(width: _getResponsiveSize(8, context)),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          await updateBook(book['id'], {
                            'book_title': titleController.text,
                            'author': authorController.text,
                            'publisher': publisherController.text,
                            'category': categoryController.text,
                            'grade_id': book['grade_id'].toString(),
                            'subject_id': book['subject_id'].toString(),
                          });
                          Navigator.pop(context);
                        },
                        child: Text(
                          'حفظ',
                          style: TextStyle(
                              fontSize: _getResponsiveTextSize(14, context)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCompactTextField(TextEditingController controller, String label,
      IconData icon, BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: _getResponsiveSize(6, context)),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: _getResponsiveSize(18, context)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_getResponsiveSize(8, context)),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: _getResponsiveSize(12, context),
            vertical: _getResponsiveSize(8, context),
          ),
          labelStyle: TextStyle(fontSize: _getResponsiveTextSize(14, context)),
        ),
        style: TextStyle(fontSize: _getResponsiveTextSize(14, context)),
      ),
    );
  }

  void _showAddBookDialog() {
    _showSuccessSnackBar('سيتم إضافة وظيفة إضافة كتاب جديد قريباً');
  }
}
