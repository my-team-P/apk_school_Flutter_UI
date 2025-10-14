import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:admin/screens/main/main_screen.dart';

class SimpleExamsPage extends StatefulWidget {
  final String role; // <-- أضف هذا

  const SimpleExamsPage({super.key, required this.role});


  @override
  State<SimpleExamsPage> createState() => _SimpleExamsPageState();
}

class _SimpleExamsPageState extends State<SimpleExamsPage> {
  final TextEditingController _noteController = TextEditingController();

  int? _selectedGradeId;
  int? _selectedSubjectId;
  String? _selectedImportance;
  String? _selectedStatus;
  String? _selectedType;

  bool _isLoading = false;
  bool _isLoadingData = false;

  List<dynamic> _grades = [];
  List<dynamic> _subjects = [];

  final String _baseUrlExams = 'http://192.168.1.102:8000/api/exams';
  final String _baseUrlClasses = 'http://192.168.1.102:8000/api/classes';
  final String _baseUrlSubjects = 'http://192.168.1.102:8000/api/subjects';

  final List<String> _importanceLevels = ['عالية', 'متوسطة', 'منخفضة'];
  final List<String> _statusTypes = ['قادم', 'منتهي', 'ملغي'];
  final List<String> _examTypes = ['شهري', 'نهائي', 'تجريبي'];

  @override
  void initState() {
    super.initState();
    _loadGradesAndSubjects();
  }

  Future<void> _loadGradesAndSubjects() async {
    setState(() {
      _isLoadingData = true;
    });

    try {
      final gradesResponse = await http.get(Uri.parse(_baseUrlClasses));
      final subjectsResponse = await http.get(Uri.parse(_baseUrlSubjects));

      if (gradesResponse.statusCode == 200) {
        final data = json.decode(gradesResponse.body);
        setState(() {
          // استخرج القائمة من المفتاح الصحيح
          _grades = data['classes'] ?? [];
        });
      }

      if (subjectsResponse.statusCode == 200) {
        final data = json.decode(subjectsResponse.body);
        setState(() {
          _subjects = data['subjects'] ?? [];
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

  Future<void> _addExam() async {
    if (_selectedGradeId == null || _selectedSubjectId == null) {
      _showMessage('الرجاء اختيار الصف والمادة', Colors.red);
      return;
    }
    if (_selectedImportance == null ||
        _selectedStatus == null ||
        _selectedType == null) {
      _showMessage(
          'الرجاء اختيار مستوى الأهمية والحالة ونوع الامتحان', Colors.red);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(_baseUrlExams),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'grade_id': _selectedGradeId,
          'subject_id': _selectedSubjectId,
          'importance': _selectedImportance,
          'status': _selectedStatus,
          'type': _selectedType,
          'note': _noteController.text.isEmpty ? null : _noteController.text,
        }),
      );

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = json.decode(response.body);
        _showMessage(
            responseData['message'] ?? 'تم إضافة الامتحان بنجاح', Colors.green);
        _clearForm();
      } else {
        _showMessage(
            'فشل في إضافة الامتحان: ${response.statusCode}', Colors.red);
        print('Response body: ${response.body}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showMessage('خطأ في الاتصال: $e', Colors.red);
    }
  }

  void _clearForm() {
    _noteController.clear();
    setState(() {
      _selectedGradeId = null;
      _selectedSubjectId = null;
      _selectedImportance = null;
      _selectedStatus = null;
      _selectedType = null;
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
        title: const Text(
          'إضافة امتحان جديد',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.orange[700],
        elevation: 0,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.pushReplacement(
  context,
  MaterialPageRoute(
    builder: (context) => MainScreen(role: widget.role), // <-- هنا
  ),
);
            }),
      ),
      body: _isLoadingData
          ? Center(child: CircularProgressIndicator(color: Colors.orange[700]))
          : Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildDropdown(
                      value: _selectedGradeId,
                      label: 'الصف *',
                      hint: 'اختر الصف',
                      icon: Icons.school,
                      items: _grades.map((grade) {
                        return DropdownMenuItem(
                          value: grade['id'],
                          child: Text(grade['grade_name'] ?? 'غير معروف'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedGradeId = value;
                        });
                      },
                    ),
                    const SizedBox(height: 15),
                    _buildDropdown(
                      value: _selectedSubjectId,
                      label: 'المادة *',
                      hint: 'اختر المادة',
                      icon: Icons.subject,
                      items: _subjects.map((subject) {
                        return DropdownMenuItem(
                          value: subject['id'],
                          child: Text(subject['subject_name'] ?? 'غير معروف'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedSubjectId = value;
                        });
                      },
                    ),
                    const SizedBox(height: 15),
                    _buildDropdown(
                      value: _selectedImportance,
                      label: 'مستوى الأهمية *',
                      hint: 'اختر مستوى الأهمية',
                      icon: Icons.priority_high,
                      items: _importanceLevels.map((importance) {
                        return DropdownMenuItem(
                          value: importance,
                          child: Text(importance),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedImportance = value;
                        });
                      },
                    ),
                    const SizedBox(height: 15),
                    _buildDropdown(
                      value: _selectedStatus,
                      label: 'حالة الامتحان *',
                      hint: 'اختر حالة الامتحان',
                      icon: Icons.event_available,
                      items: _statusTypes.map((status) {
                        return DropdownMenuItem(
                          value: status,
                          child: Text(status),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedStatus = value;
                        });
                      },
                    ),
                    const SizedBox(height: 15),
                    _buildDropdown(
                      value: _selectedType,
                      label: 'نوع الامتحان *',
                      hint: 'اختر نوع الامتحان',
                      icon: Icons.assignment_turned_in,
                      items: _examTypes.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedType = value;
                        });
                      },
                    ),
                    const SizedBox(height: 15),
                    _buildTextField(
                        controller: _noteController,
                        label: 'ملاحظات',
                        hint: 'أدخل أي ملاحظات إضافية (اختياري)',
                        icon: Icons.note,
                        maxLines: 3),
                    const SizedBox(height: 25),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _clearForm,
                            child: const Text('مسح الكل'),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _addExam,
                            child: _isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white)
                                : const Text('إضافة الامتحان'),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.orange[700]),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.orange[700]!)),
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
    return DropdownButtonFormField<dynamic>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.orange[700]),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.orange[700]!)),
      ),
      items: [
        DropdownMenuItem(
          value: null,
          child: Text(hint, style: const TextStyle(color: Colors.grey)),
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

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }
}
