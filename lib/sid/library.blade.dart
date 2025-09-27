import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:admin/screens/main/main_screen.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  // المواد والصفوف
  final List<String> subjects = [
    "الرياضيات",
    "العلوم",
    "اللغة العربية",
    "اللغة الإنجليزية",
    "الدراسات الاجتماعية",
    "التربية الإسلامية",
    "الحاسب الآلي",
    "التربية الفنية"
  ];

  final List<String> grades = [
    "الصف الأول",
    "الصف الثاني",
    "الصف الثالث",
    "الصف الرابع",
    "الصف الخامس",
    "الصف السادس"
  ];

  // الفلاتر والبحث
  String? selectedSubject;
  String? selectedGrade;
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _fileNameController = TextEditingController();

  // تخزين الملفات مع بيانات إضافية
  final List<Map<String, dynamic>> allFiles = [
    {
      "name": "كتاب الرياضيات.pdf",
      "size": 2456789,
      "type": "pdf",
      "subject": "الرياضيات",
      "grade": "الصف الأول",
      "uploadDate": "2024-03-15",
      "pages": 120,
      "author": "وزارة التعليم"
    },
    {
      "name": "تمارين العلوم.docx",
      "size": 1567890,
      "type": "doc",
      "subject": "العلوم",
      "grade": "الصف الثاني",
      "uploadDate": "2024-03-14",
      "pages": 45,
      "author": "المعلم أحمد"
    },
    {
      "name": "قواعد اللغة العربية.pptx",
      "size": 3456789,
      "type": "ppt",
      "subject": "اللغة العربية",
      "grade": "الصف الثالث",
      "uploadDate": "2024-03-13",
      "pages": 80,
      "author": "المدرسة الذكية"
    },
    {
      "name": "English Vocabulary.pdf",
      "size": 1890123,
      "type": "pdf",
      "subject": "اللغة الإنجليزية",
      "grade": "الصف الأول",
      "uploadDate": "2024-03-12",
      "pages": 60,
      "author": "Mr. Smith"
    },
    {
      "name": "أنشطة الرياضيات.pdf",
      "size": 987654,
      "type": "pdf",
      "subject": "الرياضيات",
      "grade": "الصف الثاني",
      "uploadDate": "2024-03-11",
      "pages": 35,
      "author": "المعلم محمد"
    },
  ];

  // رفع ملف جديد مع إدخال الاسم
  Future<void> _uploadFile() async {
    if (selectedSubject == null || selectedGrade == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("الرجاء اختيار المادة والصف أولاً"),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'pdf',
        'doc',
        'docx',
        'ppt',
        'pptx',
        'jpg',
        'jpeg',
        'png'
      ],
      allowMultiple: false, // رفع ملف واحد لإدخال اسم لكل ملف
    );

    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;

      if (file.extension?.toLowerCase() == "gif") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("ملفات GIF غير مسموحة ❌"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // عرض dialog لإدخال اسم الملف
      await _showFileNameDialog(file);
    }
  }

  // dialog لإدخال اسم الملف
  Future<void> _showFileNameDialog(PlatformFile file) async {
    _fileNameController.text = file.name; // تعيين الاسم الافتراضي
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("إدخال اسم الملف"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("الرجاء إدخال اسم للملف:"),
            SizedBox(height: 10),
            TextFormField(
              controller: _fileNameController,
              decoration: InputDecoration(
                labelText: "اسم الملف",
                border: OutlineInputBorder(),
                hintText: "أدخل اسمًا وصفياً للملف",
              ),
              maxLength: 100,
            ),
            SizedBox(height: 10),
            Text(
              "الملف: ${file.name}",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            Text(
              "الحجم: ${_formatFileSize(file.size ?? 0)}",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("إلغاء"),
          ),
          ElevatedButton(
            onPressed: () {
              if (_fileNameController.text.trim().isNotEmpty) {
                _addFileToLibrary(file, _fileNameController.text.trim());
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("الرجاء إدخال اسم للملف")),
                );
              }
            },
            child: Text("حفظ"),
          ),
        ],
      ),
    );
  }

  // إضافة الملف إلى المكتبة
  void _addFileToLibrary(PlatformFile file, String fileName) {
    setState(() {
      allFiles.insert(0, {
        "name": fileName,
        "size": file.size ?? 0,
        "type": file.extension ?? 'file',
        "subject": selectedSubject,
        "grade": selectedGrade,
        "uploadDate":
            "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}",
        "pages": 0,
        "author": "المستخدم",
        "originalName": file.name, // حفظ الاسم الأصلي
      });
    });

    _fileNameController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("تم رفع الملف '$fileName' بنجاح ✅"),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // حذف ملف
  void _deleteFile(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("حذف الملف"),
        content: Text("هل أنت متأكد من أنك تريد حذف هذا الملف؟"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("إلغاء"),
          ),
          TextButton(
            onPressed: () {
              final fileName = allFiles[index]["name"];
              setState(() {
                allFiles.removeAt(index);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("تم حذف الملف '$fileName' بنجاح"),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: Text("حذف", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // عرض معلومات الملف
  void _showFileDetails(Map<String, dynamic> file) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                _buildFileIcon(file["type"]),
                SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        file["name"],
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      if (file["originalName"] != null)
                        Text(
                          "الاسم الأصلي: ${file["originalName"]}",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            _buildDetailRow("المادة", file["subject"]),
            _buildDetailRow("الصف", file["grade"]),
            _buildDetailRow("المؤلف", file["author"]),
            _buildDetailRow("تاريخ الرفع", file["uploadDate"]),
            _buildDetailRow("عدد الصفحات", "${file["pages"]} صفحة"),
            _buildDetailRow("الحجم", _formatFileSize(file["size"])),
            _buildDetailRow(
                "النوع", file["type"]?.toUpperCase() ?? "غير معروف"),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.download),
                    label: Text("تحميل"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF667eea),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _deleteFile(allFiles.indexOf(file)),
                    icon: Icon(Icons.delete),
                    label: Text("حذف"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // البحث في الملفات
  void _performSearch(String query) {
    setState(() {
      searchQuery = query.toLowerCase();
    });
  }

  // فلترة الملفات مع البحث
  List<Map<String, dynamic>> get filteredFiles {
    return allFiles.where((file) {
      final matchesSearch = searchQuery.isEmpty ||
          file["name"].toLowerCase().contains(searchQuery) ||
          file["subject"].toLowerCase().contains(searchQuery) ||
          file["grade"].toLowerCase().contains(searchQuery);

      final matchesSubject =
          selectedSubject == null || file["subject"] == selectedSubject;
      final matchesGrade =
          selectedGrade == null || file["grade"] == selectedGrade;

      return matchesSearch && matchesSubject && matchesGrade;
    }).toList();
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            "$label: ",
            style:
                TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[600]),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildFileIcon(String type) {
    Color color;
    IconData icon;

    switch (type) {
      case 'pdf':
        color = Colors.red;
        icon = Icons.picture_as_pdf;
        break;
      case 'doc':
      case 'docx':
        color = Colors.blue;
        icon = Icons.description;
        break;
      case 'ppt':
      case 'pptx':
        color = Colors.orange;
        icon = Icons.slideshow;
        break;
      case 'jpg':
      case 'jpeg':
      case 'png':
        color = Colors.green;
        icon = Icons.image;
        break;
      default:
        color = Colors.grey;
        icon = Icons.insert_drive_file;
    }

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: 30),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return "$bytes B";
    if (bytes < 1048576) return "${(bytes / 1024).toStringAsFixed(1)} KB";
    return "${(bytes / 1048576).toStringAsFixed(1)} MB";
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fileNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filesToShow = filteredFiles;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          "المكتبة الرقمية",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        backgroundColor: Color(0xFF667eea),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MainScreen()),
            );
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, color: Colors.white),
            onPressed: () {
              // إعادة تعيين الفلاتر
              setState(() {
                selectedSubject = null;
                selectedGrade = null;
                searchQuery = '';
                _searchController.clear();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // إحصائيات سريعة
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF667eea),
                  Color(0xFF764ba2),
                ],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                    Icons.library_books, "${allFiles.length}", "الملفات"),
                _buildStatItem(Icons.school, "${subjects.length}", "المواد"),
                _buildStatItem(Icons.people, "${grades.length}", "الصفوف"),
                _buildStatItem(Icons.cloud_upload, "∞", "مساحة"),
              ],
            ),
          ),

          // شريط البحث
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      // border: Border.all(color: Colors.grey[300]),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _performSearch,
                      decoration: InputDecoration(
                        hintText: "ابحث في الملفات...",
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
                        suffixIcon: searchQuery.isNotEmpty
                            ? IconButton(
                                icon:
                                    Icon(Icons.clear, color: Colors.grey[500]),
                                onPressed: () {
                                  _searchController.clear();
                                  _performSearch('');
                                },
                              )
                            : null,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Color(0xFF667eea),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.upload_file, color: Colors.white),
                    onPressed: _uploadFile,
                    tooltip: "رفع ملف جديد",
                  ),
                ),
              ],
            ),
          ),

          // فلاتر المواد والصفوف
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.grey[100],
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedSubject,
                      hint: Text("جميع المواد", style: TextStyle(fontSize: 12)),
                      items: [
                        DropdownMenuItem(
                            value: null, child: Text("جميع المواد")),
                        ...subjects.map((subject) => DropdownMenuItem(
                              value: subject,
                              child:
                                  Text(subject, style: TextStyle(fontSize: 12)),
                            )),
                      ],
                      onChanged: (value) =>
                          setState(() => selectedSubject = value),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedGrade,
                      hint: Text("جميع الصفوف", style: TextStyle(fontSize: 12)),
                      items: [
                        DropdownMenuItem(
                            value: null, child: Text("جميع الصفوف")),
                        ...grades.map((grade) => DropdownMenuItem(
                              value: grade,
                              child:
                                  Text(grade, style: TextStyle(fontSize: 12)),
                            )),
                      ],
                      onChanged: (value) =>
                          setState(() => selectedGrade = value),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // عدد النتائج
          if (filesToShow.isNotEmpty)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.grey[50],
              child: Row(
                children: [
                  Text(
                    "عرض ${filesToShow.length} من ${allFiles.length} ملف",
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  Spacer(),
                  if (searchQuery.isNotEmpty)
                    Chip(
                      label: Text("بحث: $searchQuery"),
                      backgroundColor: Color(0xFF667eea).withOpacity(0.1),
                    ),
                  if (selectedSubject != null)
                    Chip(
                      label: Text(selectedSubject!),
                      backgroundColor: Colors.blue.withOpacity(0.1),
                    ),
                ],
              ),
            ),

          // قائمة الملفات
          Expanded(
            child: filesToShow.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off,
                            size: 80, color: Colors.grey[300]),
                        SizedBox(height: 20),
                        Text(
                          searchQuery.isNotEmpty
                              ? "لا توجد نتائج للبحث عن '$searchQuery'"
                              : "لا توجد ملفات مطابقة",
                          style:
                              TextStyle(fontSize: 18, color: Colors.grey[600]),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 10),
                        Text(
                          searchQuery.isNotEmpty
                              ? "جرب مصطلحات بحث مختلفة أو أعد تعيين الفلاتر"
                              : "اختر مادة وصف أو قم برفع ملف جديد",
                          style: TextStyle(color: Colors.grey[500]),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: _uploadFile,
                          icon: Icon(Icons.upload),
                          label: Text("رفع ملف جديد"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF667eea),
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: filesToShow.length,
                    itemBuilder: (context, index) {
                      final file = filesToShow[index];
                      return _buildFileCard(file, index);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String count, String label) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        SizedBox(height: 5),
        Text(
          count,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildFileCard(Map<String, dynamic> file, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showFileDetails(file),
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                _buildFileIcon(file["type"]),
                SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        file["name"],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.school, size: 12, color: Colors.grey),
                          SizedBox(width: 4),
                          Text(
                            file["subject"],
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey[600]),
                          ),
                          SizedBox(width: 10),
                          Icon(Icons.grade, size: 12, color: Colors.grey),
                          SizedBox(width: 4),
                          Text(
                            file["grade"],
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.calendar_today,
                              size: 12, color: Colors.grey),
                          SizedBox(width: 4),
                          Text(
                            file["uploadDate"],
                            style: TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                          Spacer(),
                          Text(
                            _formatFileSize(file["size"]),
                            style: TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton(
                  icon: Icon(Icons.more_vert, color: Colors.grey[400]),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: Row(
                        children: [
                          Icon(Icons.download, size: 20),
                          SizedBox(width: 8),
                          Text("تحميل"),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      child: Row(
                        children: [
                          Icon(Icons.share, size: 20),
                          SizedBox(width: 8),
                          Text("مشاركة"),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 20, color: Colors.red),
                          SizedBox(width: 8),
                          Text("حذف", style: TextStyle(color: Colors.red)),
                        ],
                      ),
                      onTap: () => _deleteFile(allFiles.indexOf(file)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
