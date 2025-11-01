import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'dart:io';
import 'package:admin/screens/main/main_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SimpleLibraryPage extends StatefulWidget {
  final String role; 

  const SimpleLibraryPage({super.key, required this.role});

  @override
  State<SimpleLibraryPage> createState() => _SimpleLibraryPageState();
}

class _SimpleLibraryPageState extends State<SimpleLibraryPage> {
  // controllers للنموذج
  final TextEditingController _bookTitleController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _publisherController = TextEditingController();
  final TextEditingController _fileNameController = TextEditingController();
  final TextEditingController _filePathController = TextEditingController();

  // المتغيرات
  String? _selectedCategory;
  int? _selectedGradeId;
  int? _selectedSubjectId;
  File? _selectedFile;

  // حالة التحميل
  bool _isLoading = false;
  bool _isLoadingData = false;

  // البيانات
  List<dynamic> _grades = [];
  List<dynamic> _subjects = [];

  // رابط الـ API
  final String _baseUrl = 'http://192.168.1.101:8000/api/library';

  // التصنيفات الثابتة
  final List<String> _categories = [
    'كتب دراسية',
    'مراجع علمية',
    'قصص تعليمية',
    'أبحاث',
    'تمارين',
    'نماذج اختبارات',
    'كتب منهجية',
    'مراجع إضافية',
    'وسائل تعليمية',
    'موسوعات'
  ];

  @override
  void initState() {
    //اول دالة تنفذ
    super.initState();
    //جلب الصفوف و المواد
    _loadGradesAndSubjects();
  }

  // دالة لجلب الصفوف والمواد مع print لتشخيص البيانات
  Future<void> _loadGradesAndSubjects() async {
    setState(() {
      _isLoadingData = true;
    });

    try {
      final [gradesResponse, subjectsResponse] = await Future.wait([
        http.get(Uri.parse('$_baseUrl/classes')),
        http.get(Uri.parse('$_baseUrl/subjects')),
      ]);

      if (gradesResponse.statusCode == 200) {
        final data = json.decode(gradesResponse.body);
        print('Grades API data: $data'); // << Print added

        setState(() {
          _grades = data['classes'] ?? data['data'] ?? data ?? [];
        });
      }

      if (subjectsResponse.statusCode == 200) {
        final data = json.decode(subjectsResponse.body);
        print('Subjects API data: $data'); // << Print added
        setState(() {
          _subjects = data['subjects'] ?? data['data'] ?? data ?? [];
        });
      }
    } catch (e) {
      print('Error loading data: $e');
    } finally {
      setState(() {
        _isLoadingData = false;
      });
    }
  }

  // دالة لاختيار الملف
  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
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
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        PlatformFile file = result.files.first;
        setState(() {
          _selectedFile = File(file.path!);
          _fileNameController.text = file.name;
          _filePathController.text = file.path!;
        });
        _showMessage('تم اختيار الملف: ${file.name}', Colors.green);
      }
    } catch (e) {
      _showMessage('خطأ في اختيار الملف: $e', Colors.red);
    }
  }

  // دالة لإضافة كتاب
  Future<void> _addBook() async {
    if (_bookTitleController.text.isEmpty || _authorController.text.isEmpty) {
      _showMessage('الرجاء إدخال عنوان الكتاب والمؤلف', Colors.red);
      return;
    }

    if (_selectedGradeId == null || _selectedSubjectId == null) {
      _showMessage('الرجاء اختيار الصف والمادة', Colors.red);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // جلب التوكن من SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      if (token == null) {
        _showMessage('لم يتم تسجيل الدخول بعد', Colors.red);
        setState(() {
          _isLoading = false;
        });
        return;
      }

      var request = http.MultipartRequest('POST', Uri.parse(_baseUrl));

      // إضافة Authorization header
      request.headers['Authorization'] = 'Bearer $token';

      request.fields['book_title'] = _bookTitleController.text;
      request.fields['author'] = _authorController.text;
      request.fields['grade_id'] = _selectedGradeId.toString();
      request.fields['subject_id'] = _selectedSubjectId.toString();

      if (_publisherController.text.isNotEmpty) {
        request.fields['publisher'] = _publisherController.text;
      }

      if (_selectedCategory != null) {
        request.fields['category'] = _selectedCategory!;
      }

      if (_fileNameController.text.isNotEmpty) {
        request.fields['file_name'] = _fileNameController.text;
      }

      if (_selectedFile != null && await _selectedFile!.exists()) {
        request.files.add(await http.MultipartFile.fromPath(
          'file',
          _selectedFile!.path,
          filename: _fileNameController.text.isEmpty
              ? 'book_${DateTime.now().millisecondsSinceEpoch}.${_selectedFile!.path.split('.').last}'
              : _fileNameController.text,
        ));
      }

      var response = await request.send();
      var responseString = await response.stream.bytesToString();

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 201 || response.statusCode == 200) {
        _showMessage('تم إضافة الكتاب بنجاح ✅', Colors.green);
        _clearForm();
      } else {
        _showMessage('فشل في إضافة الكتاب: ${response.statusCode}', Colors.red);
        print('Response body: $responseString');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showMessage('خطأ في الاتصال: $e', Colors.red);
    }
  }




  void _clearForm() {
    _bookTitleController.clear();
    _authorController.clear();
    _publisherController.clear();
    _fileNameController.clear();
    _filePathController.clear();
    setState(() {
      _selectedCategory = null;
      _selectedGradeId = null;
      _selectedSubjectId = null;
      _selectedFile = null;
    });
  }

  void _showMessage(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'إضافة كتاب جديد',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue[700],
        elevation: 0,
        leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      MainScreen(role: widget.role), // <-- هنا
                ),
              );
            }),
      ),
      body: _isLoadingData
          ? Center(child: CircularProgressIndicator(color: Colors.blue[700]))
          : Padding(
              padding: EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Icon(Icons.library_add,
                                size: 50, color: Colors.blue[700]),
                            SizedBox(height: 10),
                            Text(
                              'إضافة كتاب جديد إلى المكتبة',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[700],
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'املأ البيانات الأساسية للكتاب',
                              style: TextStyle(color: Colors.grey[600]),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          children: [
                            _buildTextField(
                                controller: _bookTitleController,
                                label: 'عنوان الكتاب *',
                                hint: 'أدخل عنوان الكتاب',
                                icon: Icons.title),
                            SizedBox(height: 15),
                            _buildTextField(
                                controller: _authorController,
                                label: 'المؤلف *',
                                hint: 'أدخل اسم المؤلف',
                                icon: Icons.person),
                            SizedBox(height: 15),
                            _buildTextField(
                                controller: _publisherController,
                                label: 'الناشر',
                                hint: 'أدخل اسم الناشر (اختياري)',
                                icon: Icons.business),
                            SizedBox(height: 15),
                            _buildDropdown(
                              value: _selectedCategory,
                              label: 'التصنيف',
                              hint: 'اختر التصنيف',
                              icon: Icons.category,
                              items: _categories.map((cat) {
                                return DropdownMenuItem(
                                  value: cat,
                                  child: Text(cat),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedCategory = value;
                                });
                              },
                            ),
                            SizedBox(height: 15),
                            _buildDropdown(
                              value: _selectedGradeId,
                              label: 'الصف *',
                              hint: 'اختر الصف',
                              icon: Icons.school,
                              items: _grades.map((grade) {
                                return DropdownMenuItem(
                                  value: grade['id'],
                                  child:
                                      Text(grade['grade_name'] ?? 'غير معروف'),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedGradeId = value;
                                });
                              },
                            ),
                            SizedBox(height: 15),
                            _buildDropdown(
                              value: _selectedSubjectId,
                              label: 'المادة *',
                              hint: 'اختر المادة',
                              icon: Icons.subject,
                              items: _subjects.map((subject) {
                                return DropdownMenuItem(
                                  value: subject['id'],
                                  child: Text(
                                      subject['subject_name'] ?? 'غير معروف'),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedSubjectId = value;
                                });
                              },
                            ),
                            SizedBox(height: 15),
                            _buildTextField(
                              controller: _fileNameController,
                              label: 'اسم الملف',
                              hint: 'اسم الملف (اختياري)',
                              icon: Icons.attach_file,
                            ),
                            SizedBox(height: 15),
                            _buildFilePicker(),
                            SizedBox(height: 25),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: _clearForm,
                                    style: OutlinedButton.styleFrom(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 15),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: Text(
                                      'مسح الكل',
                                      style: TextStyle(color: Colors.grey[700]),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 15),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _addBook,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue[700],
                                      foregroundColor: Colors.white,
                                      padding:
                                          EdgeInsets.symmetric(vertical: 15),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: _isLoading
                                        ? SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : Text(
                                            'إضافة الكتاب',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                  ),
                                ),
                              ],
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.blue[700]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.blue[700]!),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required dynamic value,
    required String label,
    required String hint,
    required IconData icon,
    required List<DropdownMenuItem<dynamic>> items,
    required Function(dynamic) onChanged,
  }) {
    return DropdownButtonFormField(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.blue[700]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.blue[700]!),
        ),
      ),
      items: [
        DropdownMenuItem(
          value: null,
          child: Text(hint, style: TextStyle(color: Colors.grey)),
        ),
        ...items,
      ],
      onChanged: onChanged,
      validator: (value) {
        if (label.contains('*') && value == null) {
          return 'هذا الحقل مطلوب';
        }
        return null;
      },
    );
  }

  Widget _buildFilePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'اختر ملف الكتاب *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 8),
        Container(
          height: 120,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(10),
            color: Colors.grey[50],
          ),
          child: InkWell(
            onTap: _pickFile,
            borderRadius: BorderRadius.circular(10),
            child: _selectedFile == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cloud_upload,
                          size: 40, color: Colors.grey[400]),
                      SizedBox(height: 8),
                      Text(
                        'انقر لاختيار الملف',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      Text(
                        'PDF, Word, PowerPoint, Images',
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ],
                  )
                : Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.attach_file, size: 40, color: Colors.green),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _fileNameController.text,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 4),
                              Text(
                                _filePathController.text,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 4),
                              Text(
                                '${(_selectedFile!.lengthSync() / 1024 / 1024).toStringAsFixed(2)} MB',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _selectedFile = null;
                              _fileNameController.clear();
                              _filePathController.clear();
                            });
                          },
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _bookTitleController.dispose();
    _authorController.dispose();
    _publisherController.dispose();
    _fileNameController.dispose();
    _filePathController.dispose();
    super.dispose();
  }
}
