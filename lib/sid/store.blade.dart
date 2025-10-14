import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:admin/screens/main/main_screen.dart';

class StorePage extends StatefulWidget {
  final String role; // <-- أضف هذا

  const StorePage({super.key, required this.role});

  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  // قائمة الاختبارات القادمة من API
  List<dynamic> _allExams = [];

  // قوائم المواد والصفوف
  Map<int, String> _subjectsMap = {};
  Map<int, String> _classesMap = {};

  // عوامل التصفية
  String? _selectedSubject;
  String? _selectedClass;
  String? _selectedStatus;
  String? _selectedImportance;
  DateTime? _selectedDate;
  String _searchQuery = '';

  bool _isLoading = true;

  final List<String> _statuses = ["قادم", "منتهي", "ملغي"];
  final List<String> _importanceLevels = ["عالية", "متوسطة", "منخفضة"];

  final String _apiUrl = 'http://192.168.1.102:8000/api/exams';
  final String _subjectsUrl = 'http://192.168.1.102:8000/api/subjects';
  final String _classesUrl = 'http://192.168.1.102:8000/api/classes';

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);
    try {
      // جلب البيانات بالتوازي
      final [examsResponse, subjectsResponse, classesResponse] =
          await Future.wait([
        http.get(Uri.parse(_apiUrl)),
        http.get(Uri.parse(_subjectsUrl)),
        http.get(Uri.parse(_classesUrl)),
      ]);

      // معالجة الاختبارات
      if (examsResponse.statusCode == 200) {
        final data = json.decode(examsResponse.body);
        if (data is List) {
          setState(() {
            _allExams = data;
          });
        } else if (data['data'] is List) {
          setState(() {
            _allExams = data['data'];
          });
        }
        print('Loaded ${_allExams.length} exams');
      }

      // معالجة المواد
      if (subjectsResponse.statusCode == 200) {
        final data = json.decode(subjectsResponse.body);
        final subjectsList =
            data is List ? data : data['data'] ?? data['subjects'] ?? [];
        _subjectsMap = _convertListToMap(subjectsList, 'id', 'subject_name');
        print('Loaded ${_subjectsMap.length} subjects: $_subjectsMap');
      }

      // معالجة الصفوف
      if (classesResponse.statusCode == 200) {
        final data = json.decode(classesResponse.body);
        final classesList =
            data is List ? data : data['data'] ?? data['classes'] ?? [];
        _classesMap = _convertListToMap(classesList, 'id', 'grade_name');
        print('Loaded ${_classesMap.length} classes: $_classesMap');
      }
    } catch (e) {
      print('Error loading data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Map<int, String> _convertListToMap(
      List<dynamic> list, String idKey, String nameKey) {
    final map = <int, String>{};
    for (var item in list) {
      if (item is Map) {
        final id = item[idKey] is int
            ? item[idKey]
            : int.tryParse(item[idKey]?.toString() ?? '');
        final name = item[nameKey]?.toString();
        if (id != null && name != null) {
          map[id] = name;
        }
      }
    }
    return map;
  }

  // الحصول على اسم المادة من الـ ID
  String _getSubjectName(int subjectId) {
    return _subjectsMap[subjectId] ?? 'مادة $subjectId';
  }

  // الحصول على اسم الصف من الـ ID
  String _getClassName(int gradeId) {
    return _classesMap[gradeId] ?? 'صف $gradeId';
  }

  // دالة محسنة للحصول على خصائص الامتحان
  String _getExamProperty(dynamic exam, String type) {
    if (exam is! Map) return 'غير معروف';

    switch (type) {
      case 'subject':
        final subjectId = exam['subject_id'] is int
            ? exam['subject_id']
            : int.tryParse(exam['subject_id']?.toString() ?? '');
        return subjectId != null ? _getSubjectName(subjectId) : 'غير معروف';

      case 'class':
        final gradeId = exam['grade_id'] is int
            ? exam['grade_id']
            : int.tryParse(exam['grade_id']?.toString() ?? '');
        return gradeId != null ? _getClassName(gradeId) : 'غير معروف';

      case 'status':
        final status = exam['status'];
        return (status != null && status != 'null')
            ? status.toString()
            : 'قادم';

      case 'importance':
        final importance = exam['importance'];
        return (importance != null && importance != 'null')
            ? importance.toString()
            : 'متوسطة';

      case 'type':
        final examType = exam['type'];
        return (examType != null && examType != 'null')
            ? examType.toString()
            : 'شهري';

      case 'note':
        final note = exam['note'];
        return (note != null && note != 'null') ? note.toString() : '';

      default:
        return 'غير معروف';
    }
  }

  List<dynamic> get _filteredExams {
    return _allExams.where((exam) {
      final subject = _getExamProperty(exam, 'subject');
      final className = _getExamProperty(exam, 'class');
      final status = _getExamProperty(exam, 'status');
      final importance = _getExamProperty(exam, 'importance');

      final matchesSubject =
          _selectedSubject == null || subject == _selectedSubject;
      final matchesClass =
          _selectedClass == null || className == _selectedClass;
      final matchesStatus =
          _selectedStatus == null || status == _selectedStatus;
      final matchesImportance =
          _selectedImportance == null || importance == _selectedImportance;
      final matchesSearch = _searchQuery.isEmpty ||
          subject.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          className.toLowerCase().contains(_searchQuery.toLowerCase());

      return matchesSubject &&
          matchesClass &&
          matchesStatus &&
          matchesImportance &&
          matchesSearch;
    }).toList();
  }

  void _clearFilters() {
    setState(() {
      _selectedSubject = null;
      _selectedClass = null;
      _selectedStatus = null;
      _selectedImportance = null;
      _selectedDate = null;
      _searchQuery = '';
    });
  }

  void _showExamDetails(dynamic exam) {
    if (exam is! Map) return;

    final subjectId = exam['subject_id'] is int
        ? exam['subject_id']
        : int.tryParse(exam['subject_id']?.toString() ?? '');
    final gradeId = exam['grade_id'] is int
        ? exam['grade_id']
        : int.tryParse(exam['grade_id']?.toString() ?? '');

    final subjectName =
        subjectId != null ? _getSubjectName(subjectId) : 'غير معروف';
    final className = gradeId != null ? _getClassName(gradeId) : 'غير معروف';
    final status = exam['status']?.toString() ?? 'قادم';
    final importance = exam['importance']?.toString() ?? 'متوسطة';
    final type = exam['type']?.toString() ?? 'شهري';
    final note = exam['note']?.toString() ?? '';

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
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
                  _buildSubjectIcon(subjectName),
                  SizedBox(width: 15),
                  Expanded(
                    child: Text(
                      subjectName,
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  _buildStatusChip(status),
                ],
              ),
              SizedBox(height: 20),
              _buildDetailRow("الصف", className, Icons.school),
              _buildDetailRow("نوع الاختبار", type, Icons.assignment),
              _buildDetailRow("الأهمية", importance, Icons.flag),
              _buildDetailRow("الحالة", status, Icons.info),
              SizedBox(height: 15),
              Text("ملاحظات:", style: TextStyle(fontWeight: FontWeight.bold)),
              Text(note.isEmpty ? "-" : note,
                  style: TextStyle(color: Colors.grey[700])),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          SizedBox(width: 10),
          Text("$label: ", style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildSubjectIcon(String subject) {
    Map<String, IconData> subjectIcons = {
      "الرياضيات": Icons.calculate,
      "اللغة العربية": Icons.menu_book,
      "العلوم": Icons.science,
      "اللغة الإنجليزية": Icons.language,
      "التربية الإسلامية": Icons.mosque,
      "الحاسب الآلي": Icons.computer,
      "الدراسات الاجتماعية": Icons.public,
      "التربية الفنية": Icons.brush,
    };

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child:
          Icon(subjectIcons[subject] ?? Icons.assignment, color: Colors.blue),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case "قادم":
        color = Colors.green;
        break;
      case "منتهي":
        color = Colors.grey;
        break;
      case "ملغي":
        color = Colors.red;
        break;
      default:
        color = Colors.blue;
    }

    return Chip(
      label: Text(status, style: TextStyle(color: Colors.white, fontSize: 12)),
      backgroundColor: color,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  // الحصول على قائمة المواد للفلاتر
  List<String> get _availableSubjects {
    final subjectIds = _allExams
        .map((exam) => exam['subject_id']?.toString())
        .whereType<String>()
        .toSet();
    return subjectIds
        .map((id) => _getSubjectName(int.tryParse(id) ?? 0))
        .toList();
  }

  // الحصول على قائمة الصفوف للفلاتر
  List<String> get _availableClasses {
    final gradeIds = _allExams
        .map((exam) => exam['grade_id']?.toString())
        .whereType<String>()
        .toSet();
    return gradeIds.map((id) => _getClassName(int.tryParse(id) ?? 0)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredExams = _filteredExams;
    final activeFiltersCount = [
      _selectedSubject,
      _selectedClass,
      _selectedStatus,
      _selectedImportance,
      _selectedDate,
      _searchQuery.isNotEmpty
    ].where((filter) => filter != null && filter != false).length;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          "جدول الاختبارات",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Color(0xFF667eea),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
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
          if (activeFiltersCount > 0)
            Chip(
              label: Text(activeFiltersCount.toString()),
              backgroundColor: Colors.red,
            ),
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadAllData,
            tooltip: "تحديث البيانات",
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // شريط البحث والفلاتر المبسط
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextField(
                        decoration: InputDecoration(
                          hintText: "ابحث باسم المادة أو الصف...",
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                      ),
                      SizedBox(height: 10),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            FilterChip(
                              label: Text("الكل"),
                              selected: activeFiltersCount == 0,
                              onSelected: (_) => _clearFilters(),
                            ),
                            SizedBox(width: 8),
                            FilterChip(
                              label: Text("قادم"),
                              selected: _selectedStatus == "قادم",
                              onSelected: (_) => setState(() {
                                _selectedStatus =
                                    _selectedStatus == "قادم" ? null : "قادم";
                              }),
                            ),
                            SizedBox(width: 8),
                            FilterChip(
                              label: Text("منتهي"),
                              selected: _selectedStatus == "منتهي",
                              onSelected: (_) => setState(() {
                                _selectedStatus =
                                    _selectedStatus == "منتهي" ? null : "منتهي";
                              }),
                            ),
                            SizedBox(width: 8),
                            FilterChip(
                              label: Text("ملغي"),
                              selected: _selectedStatus == "ملغي",
                              onSelected: (_) => setState(() {
                                _selectedStatus =
                                    _selectedStatus == "ملغي" ? null : "ملغي";
                              }),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // عدد النتائج
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "الاختبارات (${filteredExams.length})",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      if (activeFiltersCount > 0)
                        TextButton(
                          onPressed: _clearFilters,
                          child: Text("مسح الفلاتر"),
                        ),
                    ],
                  ),
                ),

                // قائمة الاختبارات
                Expanded(
                  child: filteredExams.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.assignment,
                                  size: 80, color: Colors.grey[300]),
                              SizedBox(height: 20),
                              Text(
                                _allExams.isEmpty
                                    ? "لا توجد اختبارات"
                                    : "لا توجد اختبارات مطابقة",
                                style: TextStyle(
                                    fontSize: 18, color: Colors.grey[600]),
                              ),
                              SizedBox(height: 10),
                              if (_allExams.isNotEmpty)
                                ElevatedButton(
                                  onPressed: _clearFilters,
                                  child: Text("مسح جميع الفلاتر"),
                                ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.all(16),
                          itemCount: filteredExams.length,
                          itemBuilder: (context, index) {
                            final exam = filteredExams[index];
                            return _buildExamCard(exam);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildExamCard(dynamic exam) {
    final subject = _getExamProperty(exam, 'subject');
    final status = _getExamProperty(exam, 'status');
    final className = _getExamProperty(exam, 'class');
    final importance = _getExamProperty(exam, 'importance');
    final type = _getExamProperty(exam, 'type');

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 3,
      child: ListTile(
        leading: _buildSubjectIcon(subject),
        title: Text(
          subject,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("الصف: $className"),
            Text("$type - الأهمية: $importance"),
          ],
        ),
        trailing: _buildStatusChip(status),
        onTap: () => _showExamDetails(exam),
      ),
    );
  }
}
