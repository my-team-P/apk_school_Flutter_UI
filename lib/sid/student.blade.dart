import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:admin/screens/main/main_screen.dart';

class StudentPreparationPage extends StatefulWidget {
  final String role; // <-- أضف هذا

  const StudentPreparationPage({super.key, required this.role});


  @override
  State<StudentPreparationPage> createState() => _StudentPreparationPageState();
}

class _StudentPreparationPageState extends State<StudentPreparationPage> {
  List<dynamic> _students = [];
  List<dynamic> _classes = [];
  List<dynamic> _sections = [];
  List<dynamic> _filteredStudents = [];

  int? _selectedClassId;
  int? _selectedSectionId;

  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;

  final String _baseUrl = 'http://192.168.1.102:8000/api';
  DateTime _selectedDate = DateTime.now();

  // تخزين بيانات الحضور والسلوك لكل طالب
  final Map<int, String> _attendanceStatus = {};
  final Map<int, String> _behaviorStatus = {};
  final Map<int, String> _notes = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _loadClasses();
      await _loadSections();
      await _loadStudents();
    } catch (e) {
      setState(() => _errorMessage = 'خطأ في تحميل البيانات: $e');
      print('❌ خطأ عام في تحميل البيانات: $e');
      _loadSampleData();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadClasses() async {
    try {
      final response = await http.get(Uri.parse("$_baseUrl/classes"));
      print('📡 استجابة الصفوف: ${response.statusCode}');
      print('📄 محتوى الصفوف: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        print('🔍 هيكل بيانات الصفوف: ${data.runtimeType}');

        // معالجة هيكل البيانات المختلف
        if (data is Map<String, dynamic>) {
          if (data.containsKey('data') && data['data'] is List) {
            _classes = data['data'];
          } else if (data.containsKey('classes') && data['classes'] is List) {
            _classes = data['classes'];
          } else {
            // إذا كان الـ Map نفسه يحتوي على بيانات الصفوف
            _classes = [data];
          }
        } else if (data is List) {
          _classes = data;
        } else {
          _classes = [];
        }

        print('✅ تم تحميل ${_classes.length} صف');
        print('📋 قائمة الصفوف: $_classes');
      } else {
        print('❌ خطأ في تحميل الصفوف: ${response.statusCode}');
        _classes = [];
      }
    } catch (e) {
      print('❌ استثناء في تحميل الصفوف: $e');
      _classes = [];
    }
  }

  Future<void> _loadSections() async {
    try {
      final response = await http.get(Uri.parse("$_baseUrl/sections"));
      print('📡 استجابة الشعب: ${response.statusCode}');
      print('📄 محتوى الشعب: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        print('🔍 هيكل بيانات الشعب: ${data.runtimeType}');

        // معالجة هيكل البيانات المختلف
        if (data is Map<String, dynamic>) {
          if (data.containsKey('data') && data['data'] is List) {
            _sections = data['data'];
          } else if (data.containsKey('sections') && data['sections'] is List) {
            _sections = data['sections'];
          } else {
            _sections = [];
          }
        } else if (data is List) {
          _sections = data;
        } else {
          _sections = [];
        }

        print('✅ تم تحميل ${_sections.length} شعبة');
        print('📋 قائمة الشعب: $_sections');
      } else {
        print('❌ خطأ في تحميل الشعب: ${response.statusCode}');
        _sections = [];
      }
    } catch (e) {
      print('❌ استثناء في تحميل الشعب: $e');
      _sections = [];
    }
  }

  Future<void> _loadStudents() async {
    try {
      final response = await http.get(Uri.parse("$_baseUrl/students"));
      print('📡 استجابة الطلاب: ${response.statusCode}');
      print('📄 محتوى الطلاب: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        print('🔍 هيكل بيانات الطلاب: ${data.runtimeType}');

        // معالجة هيكل البيانات المختلف
        if (data is Map<String, dynamic>) {
          if (data.containsKey('data') && data['data'] is List) {
            _students = data['data'];
          } else if (data.containsKey('students') && data['students'] is List) {
            _students = data['students'];
          } else {
            _students = [];
          }
        } else if (data is List) {
          _students = data;
        } else {
          _students = [];
        }

        _filteredStudents = _students;

        // تهيئة القيم الافتراضية لكل طالب
        for (var student in _students) {
          int studentId = _getStudentId(student);
          _attendanceStatus[studentId] = 'حاضر';
          _behaviorStatus[studentId] = 'منتظم';
          _notes[studentId] = '';
        }
        print('✅ تم تحميل ${_students.length} طالب');
      } else {
        print('❌ خطأ في تحميل الطلاب: ${response.statusCode}');
        _loadSampleData();
      }
    } catch (e) {
      print('❌ استثناء في تحميل الطلاب: $e');
      _loadSampleData();
    }
  }

  int _getStudentId(dynamic student) {
    try {
      if (student is Map) {
        if (student['id'] is int) return student['id'];
        if (student['id'] is String) return int.tryParse(student['id']) ?? 0;
        if (student['student_id'] is int) return student['student_id'];
        if (student['student_id'] is String) {
          return int.tryParse(student['student_id']) ?? 0;
        }
      }
      return 0;
    } catch (e) {
      print('❌ خطأ في استخراج ID الطالب: $e');
      return 0;
    }
  }

  String _getStudentName(dynamic student) {
    try {
      if (student is Map) {
        return student['name'] ??
            student['student_name'] ??
            student['full_name'] ??
            'غير معروف';
      }
      return 'غير معروف';
    } catch (e) {
      return 'غير معروف';
    }
  }

  int? _getStudentClassId(dynamic student) {
    try {
      if (student is Map) {
        if (student['class_id'] is int) return student['class_id'];
        if (student['class_id'] is String) {
          return int.tryParse(student['class_id']);
        }
        if (student['grade_id'] is int) return student['grade_id'];
        if (student['grade_id'] is String) {
          return int.tryParse(student['grade_id']);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  int? _getStudentSectionId(dynamic student) {
    try {
      if (student is Map) {
        if (student['section_id'] is int) return student['section_id'];
        if (student['section_id'] is String) {
          return int.tryParse(student['section_id']);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  void _loadSampleData() {
    print('🔄 تحميل بيانات تجريبية...');

    _classes = [
      {'id': 1, 'class_name': 'الصف الأول', 'grade_name': 'الصف الأول'},
      {'id': 2, 'class_name': 'الصف الثاني', 'grade_name': 'الصف الثاني'},
    ];
    _sections = [
      {'id': 1, 'section_name': 'أ', 'class_id': 1},
      {'id': 2, 'section_name': 'ب', 'class_id': 1},
      {'id': 3, 'section_name': 'أ', 'class_id': 2},
    ];
    _students = [
      {'id': 1, 'name': 'أحمد محمد', 'class_id': 1, 'section_id': 1},
      {'id': 2, 'name': 'ليلى عبدالله', 'class_id': 1, 'section_id': 1},
      {'id': 3, 'name': 'سارة خالد', 'class_id': 1, 'section_id': 1},
      {'id': 4, 'name': 'محمد علي', 'class_id': 1, 'section_id': 2},
      {'id': 5, 'name': 'فاطمة إبراهيم', 'class_id': 2, 'section_id': 3},
    ];
    _filteredStudents = _students;

    // تهيئة القيم الافتراضية للبيانات التجريبية
    for (var student in _students) {
      int studentId = student['id'];
      _attendanceStatus[studentId] = 'حاضر';
      _behaviorStatus[studentId] = 'منتظم';
      _notes[studentId] = '';
    }

    _errorMessage = 'تم تحميل بيانات تجريبية للاختبار';
    print('✅ تم تحميل بيانات تجريبية: ${_students.length} طالب');
  }

  void _filterStudents() {
    _filteredStudents = _students.where((student) {
      final studentClassId = _getStudentClassId(student);
      final studentSectionId = _getStudentSectionId(student);

      final matchesClass =
          _selectedClassId == null || studentClassId == _selectedClassId;
      final matchesSection =
          _selectedSectionId == null || studentSectionId == _selectedSectionId;

      return matchesClass && matchesSection;
    }).toList();

    print('🔍 تم تصفية الطلاب: ${_filteredStudents.length} طالب');
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _saveAllAttendance() async {
    if (_filteredStudents.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا يوجد طلاب لحفظ بياناتهم')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      int successCount = 0;
      int errorCount = 0;

      for (var student in _filteredStudents) {
        final int studentId = _getStudentId(student);

        final payload = {
          'student_id': studentId,
          'date': DateFormat("yyyy-MM-dd").format(_selectedDate),
          'status': _attendanceStatus[studentId] ?? 'حاضر',
          'behavior': _behaviorStatus[studentId] ?? 'منتظم',
          'notes': _notes[studentId] ?? '',
        };

        print('📤 إرسال بيانات الطالب $studentId: $payload');

        try {
          final response = await http.post(
            Uri.parse("$_baseUrl/attendance"),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: json.encode(payload),
          );

          print('📥 استجابة السيرفر للطالب $studentId: ${response.statusCode}');

          if (response.statusCode == 200 || response.statusCode == 201) {
            successCount++;
          } else {
            errorCount++;
            final errorBody = json.decode(response.body);
            print('❌ فشل في حفظ بيانات الطالب $studentId: $errorBody');
          }
        } catch (e) {
          errorCount++;
          print('❌ استثناء في حفظ بيانات الطالب $studentId: $e');
        }

        // تأخير بسيط بين الطلبات لتجنب إرباك السيرفر
        await Future.delayed(const Duration(milliseconds: 100));
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم حفظ $successCount طالب ✅ | فشل $errorCount'),
          backgroundColor: errorCount == 0 ? Colors.green : Colors.orange,
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في الحفظ: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Widget _buildStudentTable() {
    if (_filteredStudents.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.group_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'لا يوجد طلاب في هذا الصف والشعبة',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            Text(
              'يرجى اختيار صف وشعبة مختلفة',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 20,
          headingRowColor: WidgetStateProperty.all(Colors.blue[50]),
          columns: const [
            DataColumn(label: Text('م', textAlign: TextAlign.center)),
            DataColumn(label: Text('اسم الطالب', textAlign: TextAlign.center)),
            DataColumn(label: Text('الحضور', textAlign: TextAlign.center)),
            DataColumn(label: Text('السلوك', textAlign: TextAlign.center)),
            DataColumn(label: Text('ملاحظات', textAlign: TextAlign.center)),
          ],
          rows: _filteredStudents.asMap().entries.map((entry) {
            final index = entry.key;
            final student = entry.value;
            final int studentId = _getStudentId(student);

            return DataRow(
              cells: [
                DataCell(Center(child: Text('${index + 1}'))),
                DataCell(Center(
                  child: Text(
                    _getStudentName(student),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                )),
                DataCell(
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: DropdownButton<String>(
                        value: _attendanceStatus[studentId] ?? 'حاضر',
                        items: ['حاضر', 'غائب', 'متأخر']
                            .map((status) => DropdownMenuItem(
                                  value: status,
                                  child: Text(
                                    status,
                                    style: TextStyle(
                                      color: status == 'غائب'
                                          ? Colors.red
                                          : status == 'متأخر'
                                              ? Colors.orange
                                              : Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ))
                            .toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _attendanceStatus[studentId] = newValue!;
                          });
                        },
                        underline: Container(),
                        isExpanded: true,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: DropdownButton<String>(
                        value: _behaviorStatus[studentId] ?? 'منتظم',
                        items: ['منتظم', 'مشاغب', 'هادئ', 'نشيط']
                            .map((behavior) => DropdownMenuItem(
                                  value: behavior,
                                  child: Text(
                                    behavior,
                                    style: TextStyle(
                                      color: behavior == 'مشاغب'
                                          ? Colors.red
                                          : behavior == 'نشيط'
                                              ? Colors.green
                                              : Colors.blue,
                                    ),
                                  ),
                                ))
                            .toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _behaviorStatus[studentId] = newValue!;
                          });
                        },
                        underline: Container(),
                        isExpanded: true,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  SizedBox(
                    width: 150,
                    child: TextFormField(
                      initialValue: _notes[studentId] ?? '',
                      decoration: const InputDecoration(
                        hintText: 'ملاحظات...',
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      ),
                      maxLines: 2,
                      onChanged: (value) {
                        _notes[studentId] = value;
                      },
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تسجيل حضور وسلوك الطلاب'),
        backgroundColor: Colors.blue[700],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
           Navigator.pushReplacement(
  context,
  MaterialPageRoute(
    builder: (context) => MainScreen(role: widget.role), // <-- هنا
  ),
);
          },
        ),
        actions: [
          if (_filteredStudents.isNotEmpty && !_isSaving)
            IconButton(
              icon: const Icon(Icons.save, color: Colors.white),
              onPressed: _saveAllAttendance,
              tooltip: 'حفظ جميع البيانات',
            ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _isLoading ? null : _loadData,
            tooltip: 'تحديث البيانات',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // معلومات التصفية والتاريخ
                Card(
                  margin: const EdgeInsets.all(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<int>(
                                decoration: const InputDecoration(
                                  labelText: "اختر الصف",
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.school),
                                ),
                                value: _selectedClassId,
                                items: [
                                  const DropdownMenuItem(
                                    value: null,
                                    child: Text('جميع الصفوف'),
                                  ),
                                  ..._classes
                                      .where((c) => c['id'] != null)
                                      .map((c) => DropdownMenuItem<int>(
                                            value: c['id'] is int
                                                ? c['id']
                                                : int.tryParse(
                                                    c['id'].toString()),
                                            child: Text(c['class_name'] ??
                                                c['grade_name'] ??
                                                'الصف ${c['id']}'),
                                          ))
                                      ,
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _selectedClassId = value;
                                    _selectedSectionId = null; // نصفر الشعبة
                                    _filterStudents(); // نصفي الطلاب
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: DropdownButtonFormField<int>(
                                decoration: const InputDecoration(
                                  labelText: "اختر الشعبة",
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.group),
                                ),
                                value: _selectedSectionId,
                                items: [
                                  const DropdownMenuItem(
                                    value: null,
                                    child: Text('جميع الشعب'),
                                  ),
                                  ..._sections
                                      .where((s) => s['id'] != null)
                                      .where((s) =>
                                          _selectedClassId == null ||
                                          s['class_id'] ==
                                              _selectedClassId || // ربط بالشعب حسب الصف
                                          s['grade_id'] == _selectedClassId)
                                      .map((s) => DropdownMenuItem<int>(
                                            value: s['id'] is int
                                                ? s['id']
                                                : int.tryParse(
                                                    s['id'].toString()),
                                            child: Text(s['section_name'] ??
                                                'الشعبة ${s['id']}'),
                                          ))
                                      ,
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _selectedSectionId = value;
                                    _filterStudents();
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Card(
                                color: Colors.blue[50],
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.calendar_today,
                                          color: Colors.blue),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              "تاريخ اليوم",
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey),
                                            ),
                                            Text(
                                              DateFormat("yyyy-MM-dd")
                                                  .format(_selectedDate),
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.edit_calendar,
                                            size: 20),
                                        onPressed: _pickDate,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            if (_filteredStudents.isNotEmpty)
                              Card(
                                color: Colors.green[50],
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.people,
                                          color: Colors.green),
                                      const SizedBox(width: 8),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            "عدد الطلاب",
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey),
                                          ),
                                          Text(
                                            '${_filteredStudents.length}',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // جدول الطلاب
                Expanded(
                  child: _buildStudentTable(),
                ),

                // زر الحفظ
                if (_filteredStudents.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: ElevatedButton.icon(
                      icon: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.save),
                      label: Text(_isSaving
                          ? "جاري حفظ جميع البيانات..."
                          : "حفظ بيانات ${_filteredStudents.length} طالب"),
                      onPressed: _isSaving ? null : _saveAllAttendance,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
