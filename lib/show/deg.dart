import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ViewGradesPage extends StatefulWidget {
  const ViewGradesPage({super.key});

  @override
  State<ViewGradesPage> createState() => _ViewGradesPageState();
}

class _ViewGradesPageState extends State<ViewGradesPage> {
  List<dynamic> _grades = [];
  List<dynamic> _students = [];
  List<dynamic> _filteredGrades = [];
  String? _selectedStudentId;
  bool _isLoading = true;
  String? _errorMessage;

  final String _baseUrl = 'http://192.168.1.102:8000/api';

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
      final [gradesResponse, studentsResponse] = await Future.wait([
        http.get(Uri.parse("$_baseUrl/grades")),
        http.get(Uri.parse("$_baseUrl/students")),
      ]);

      print('Grades Status: ${gradesResponse.statusCode}');
      print('Students Status: ${studentsResponse.statusCode}');

      if (studentsResponse.statusCode == 200) {
        final studentsData = json.decode(studentsResponse.body);
        setState(() {
          _students = studentsData is List
              ? studentsData
              : studentsData['data'] ?? studentsData['students'] ?? [];
        });
      } else {
        print('Students API Error: ${studentsResponse.body}');
        throw Exception('فشل في تحميل بيانات الطلاب');
      }

      if (gradesResponse.statusCode == 200) {
        final gradesData = json.decode(gradesResponse.body);
        setState(() {
          _grades = gradesData is List
              ? gradesData
              : gradesData['data'] ?? gradesData['grades'] ?? [];
          _filteredGrades = _grades;
        });
      } else {
        print('Grades API Error: ${gradesResponse.body}');
        if (gradesResponse.statusCode == 500) {
          setState(() {
            _grades = [];
            _filteredGrades = [];
          });
          _showErrorSnackBar('لا توجد درجات مسجلة بعد أو هناك مشكلة في الخادم');
        } else {
          throw Exception('فشل في تحميل بيانات الدرجات');
        }
      }

      print('Loaded ${_grades.length} grades, ${_students.length} students');
    } catch (e) {
      print('Error loading data: $e');
      setState(() {
        _errorMessage = e.toString();
      });
      _showErrorSnackBar('خطأ في تحميل البيانات: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _filterGrades() {
    if (_selectedStudentId == null) {
      setState(() {
        _filteredGrades = _grades;
      });
    } else {
      setState(() {
        _filteredGrades = _grades.where((grade) {
          final studentId = grade['student_id']?.toString();
          return studentId == _selectedStudentId;
        }).toList();
      });
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
        ),
      );
    }
  }

  String _getStudentName(dynamic student) {
    if (student is! Map) return 'غير معروف';
    return student['name'] ??
        student['student_name'] ??
        student['full_name'] ??
        'طالب ${student['id'] ?? ''}';
  }

  String _getTeacherName(dynamic grade) {
    if (grade['teacher'] is Map) {
      final teacher = grade['teacher'];
      return teacher['name'] ??
          teacher['teacher_name'] ??
          teacher['full_name'] ??
          'معلم ${teacher['id'] ?? ''}';
    }
    return 'غير معروف';
  }

  String _getSubjectName(dynamic grade) {
    if (grade['subject'] is Map) {
      final subject = grade['subject'];
      return subject['name'] ??
          subject['subject_name'] ??
          subject['title'] ??
          'مادة ${subject['id'] ?? ''}';
    }
    return 'غير معروف';
  }

  double _calculatePercentage(double score, double totalScore) {
    if (totalScore == 0) return 0;
    return (score / totalScore) * 100;
  }

  Color _getEvaluationColor(String evaluation) {
    switch (evaluation) {
      case 'ممتاز':
        return Colors.green;
      case 'جيد':
        return Colors.blue;
      case 'مقبول':
        return Colors.orange;
      case 'ضعيف':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("عرض درجات الطلاب"),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: "تحديث البيانات",
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorWidget()
              : Column(
                  children: [
                    _buildStudentFilter(),
                    _buildStatistics(),
                    Expanded(child: _buildGradesList()),
                  ],
                ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error, size: 60, color: Colors.red),
          SizedBox(height: 16),
          Text(
            'خطأ في تحميل البيانات',
            style: TextStyle(fontSize: 18, color: Colors.red),
          ),
          SizedBox(height: 8),
          Text(
            _errorMessage ?? '',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadData,
            child: Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentFilter() {
    return Card(
      margin: EdgeInsets.all(16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.filter_list, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  "فلتر الدرجات حسب الطالب",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: "اختر الطالب",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              value: _selectedStudentId,
              items: [
                DropdownMenuItem(
                  value: null,
                  child:
                      Text("جميع الطلاب", style: TextStyle(color: Colors.blue)),
                ),
                ..._students.map((student) {
                  final studentId = student['id']?.toString();
                  final studentName = _getStudentName(student);
                  return DropdownMenuItem(
                    value: studentId,
                    child: Text(studentName),
                  );
                }),
              ],
              onChanged: (v) {
                setState(() => _selectedStudentId = v);
                _filterGrades();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatistics() {
    double averagePercentage = 0;
    final totalGrades = _filteredGrades.length;
    if (_filteredGrades.isNotEmpty) {
      averagePercentage = _filteredGrades
              .map((grade) {
                final score =
                    double.tryParse(grade['score']?.toString() ?? '0') ?? 0;
                final totalScore =
                    double.tryParse(grade['total_score']?.toString() ?? '0') ??
                        0;
                return _calculatePercentage(score, totalScore);
              })
              .reduce((a, b) => a + b) /
          totalGrades;
    }

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
                Icons.assignment, 'عدد الدرجات', totalGrades.toString(), Colors.blue),
            _buildStatItem(Icons.percent, 'متوسط النسبة',
                '${averagePercentage.toStringAsFixed(1)}%', Colors.green),
            _buildStatItem(Icons.person, 'عدد الطلاب',
                _selectedStudentId == null ? _students.length.toString() : '1',
                Colors.orange),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String title, String value, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 30),
        SizedBox(height: 4),
        Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }

  Widget _buildGradesList() {
    if (_filteredGrades.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment, size: 60, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              _selectedStudentId == null
                  ? "لا توجد درجات مسجلة بعد"
                  : "لا توجد درجات لهذا الطالب",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              "استخدم صفحة 'إضافة درجة' لتسجيل الدرجات الأولى",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _filteredGrades.length,
      itemBuilder: (context, index) {
        final grade = _filteredGrades[index];
        final score = double.tryParse(grade['score']?.toString() ?? '0') ?? 0;
        final totalScore =
            double.tryParse(grade['total_score']?.toString() ?? '0') ?? 0;
        final percentage = _calculatePercentage(score, totalScore);
        final evaluation = grade['evaluation'] ?? 'غير محدد';
        final examType = grade['exam_type'] ?? 'غير محدد';

        return Card(
          elevation: 2,
          margin: EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getSubjectName(grade),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[700],
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'المعلم: ${_getTeacherName(grade)}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                    if (_selectedStudentId == null)
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getStudentName(grade['student'] ?? {}),
                          style: TextStyle(fontSize: 12, color: Colors.blue[700]),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    _buildGradeItem('الدرجة', '$score/$totalScore'),
                    _buildGradeItem('النسبة', '${percentage.toStringAsFixed(1)}%'),
                    _buildGradeItem('نوع الاختبار', examType),
                  ],
                ),
                SizedBox(height: 12),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getEvaluationColor(evaluation).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _getEvaluationColor(evaluation)),
                  ),
                  child: Text(
                    evaluation,
                    style: TextStyle(
                      color: _getEvaluationColor(evaluation),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGradeItem(String title, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blue[700]),
          ),
        ],
      ),
    );
  }
}
