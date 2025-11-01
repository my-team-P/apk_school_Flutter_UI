import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:admin/screens/main/main_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';


class AddGradePage extends StatefulWidget {
  const AddGradePage({super.key});

  @override
  State<AddGradePage> createState() => _ExamGradePageState();
}

class _ExamGradePageState extends State<AddGradePage> {
  String? selectedStudentId;
  String? selectedTeacherId;
  String? selectedSubjectId;
  String? selectedExamType;
  String? selectedGrade;
  String? selectedFinalGrade;
  String? selectedEvaluation;
  File? _examPaperImage;
  final ImagePicker _picker = ImagePicker();

  List<dynamic> _students = [];
  List<dynamic> _teachers = [];
  List<dynamic> _subjects = [];

  bool _isLoading = true;
  bool _isSubmitting = false;

  final List<String> examTypes = ["تجريبي", "شهري", "نهائي"];
  final gradesPercentages = List.generate(10, (i) => "${(i + 1) * 10}%");
  final evaluations = ["ضعيف", "مقبول", "جيد", "ممتاز"];
  final String _baseUrl = 'http://192.168.1.101:8000/api';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final [studentsResponse, teachersResponse, subjectsResponse] =
          await Future.wait([
        http.get(Uri.parse("$_baseUrl/students")),
        http.get(Uri.parse("$_baseUrl/teachers")),
        http.get(Uri.parse("$_baseUrl/subjects")),
      ]);

      if (studentsResponse.statusCode == 200 && mounted) {
        final data = json.decode(studentsResponse.body);
        setState(() {
          _students =
              data is List ? data : data['data'] ?? data['students'] ?? [];
        });
      } else {
        _showErrorSnackBar('فشل في تحميل بيانات الطلاب');
      }

      if (teachersResponse.statusCode == 200 && mounted) {
        final data = json.decode(teachersResponse.body);
        setState(() {
          _teachers =
              data is List ? data : data['data'] ?? data['teachers'] ?? [];
        });
      } else {
        _showErrorSnackBar('فشل في تحميل بيانات المعلمين');
      }

      if (subjectsResponse.statusCode == 200 && mounted) {
        final data = json.decode(subjectsResponse.body);
        setState(() {
          _subjects =
              data is List ? data : data['data'] ?? data['subjects'] ?? [];
        });
      } else {
        _showErrorSnackBar('فشل في تحميل بيانات المواد');
      }
    } catch (e) {
      _showErrorSnackBar('خطأ في تحميل البيانات: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 80,
      );
      if (photo != null && mounted) {
        setState(() => _examPaperImage = File(photo.path));
      }
    } catch (e) {
      _showErrorSnackBar('خطأ في التقاط الصورة: $e');
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 80,
      );
      if (image != null && mounted) {
        setState(() => _examPaperImage = File(image.path));
      }
    } catch (e) {
      _showErrorSnackBar('خطأ في اختيار الصورة: $e');
    }
  }

  void _removeImage() {
    if (!mounted) return;
    setState(() => _examPaperImage = null);
  }

  String _getStudentName(dynamic student) {
    if (student is! Map) return 'غير معروف';
    return student['name'] ??
        student['student_name'] ??
        student['full_name'] ??
        'طالب ${student['id']}';
  }

  String _getTeacherName(dynamic teacher) {
    if (teacher is! Map) return 'غير معروف';
    return teacher['name'] ??
        teacher['teacher_name'] ??
        teacher['full_name'] ??
        'معلم ${teacher['id']}';
  }

  String _getSubjectName(dynamic subject) {
    if (subject is! Map) return 'غير معروف';
    return subject['name'] ??
        subject['subject_name'] ??
        subject['title'] ??
        'مادة ${subject['id']}';
  }

  Future<void> _submitGrade() async {
    if (selectedStudentId == null ||
        selectedTeacherId == null ||
        selectedSubjectId == null ||
        selectedExamType == null ||
        selectedGrade == null ||
        selectedFinalGrade == null ||
        selectedEvaluation == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("يرجى تعبئة كل الحقول المطلوبة"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final score = _convertPercentageToNumber(selectedGrade!);
    final totalScore = _convertPercentageToNumber(selectedFinalGrade!);

    if (score > totalScore) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              "الدرجة التي حصل عليها لا يمكن أن تكون أكبر من الدرجة النهائية"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      if (mounted) setState(() => _isSubmitting = true);

      var request = http.MultipartRequest(
        'POST',
        Uri.parse("$_baseUrl/grades"),
      );

      request.fields.addAll({
        'student_id': selectedStudentId!,
        'teacher_id': selectedTeacherId!,
        'subject_id': selectedSubjectId!,
        'exam_type': selectedExamType!,
        'score': score.toString(),
        'total_score': totalScore.toString(),
        'evaluation': selectedEvaluation!,
      });

      if (_examPaperImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'exam_paper',
          _examPaperImage!.path,
          filename: 'exam_paper_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ));
      }

      final streamedResponse = await request.send();
      final responseBody = await streamedResponse.stream.bytesToString();

      dynamic data;
      try {
        data = json.decode(responseBody);
      } catch (_) {
        data = null;
      }

      if (!mounted) return;

      if (streamedResponse.statusCode == 200 ||
          streamedResponse.statusCode == 201) {
        _showSuccessMessage(
            message: data?['message'] ?? 'تم إضافة الدرجة بنجاح');
      } else if (streamedResponse.statusCode == 422) {
        final errors = data?['errors'] ?? {};
        String errorMessage = errors.entries
            .map((e) => "${e.key}: ${e.value.join(", ")}")
            .join("\n");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("خطأ في البيانات:\n$errorMessage"),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                "فشل في إضافة الدرجة: ${data?['message'] ?? 'خطأ غير معروف'}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("خطأ في الاتصال: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showSuccessMessage({String message = 'تم إضافة الدرجة بنجاح'}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
    _clearForm();
  }

  double _convertPercentageToNumber(String percentage) {
    try {
      return double.parse(percentage.replaceAll('%', ''));
    } catch (e) {
      return 0.0;
    }
  }

  void _clearForm() {
    if (!mounted) return;
    setState(() {
      selectedStudentId = null;
      selectedTeacherId = null;
      selectedSubjectId = null;
      selectedExamType = null;
      selectedGrade = null;
      selectedFinalGrade = null;
      selectedEvaluation = null;
      _examPaperImage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("إضافة درجة للطالب"),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => MainScreen(role: 'teacher')),
            );
          },
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
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  _buildStudentDropdown(),
                  const SizedBox(height: 16),
                  _buildTeacherDropdown(),
                  const SizedBox(height: 16),
                  _buildSubjectDropdown(),
                  const SizedBox(height: 16),
                  _buildExamTypeDropdown(),
                  const SizedBox(height: 16),
                  _buildGradeDropdown("الدرجة التي حصل عليها *", selectedGrade,
                      (v) {
                    if (!mounted) return;
                    setState(() => selectedGrade = v);
                  }),
                  const SizedBox(height: 16),
                  _buildGradeDropdown("الدرجة النهائية *", selectedFinalGrade,
                      (v) {
                    if (!mounted) return;
                    setState(() => selectedFinalGrade = v);
                  }),
                  const SizedBox(height: 16),
                  _buildEvaluationDropdown(),
                  const SizedBox(height: 16),
                  _buildImageUploadSection(),
                  const SizedBox(height: 30),
                  _buildActionButtons(),
                  _buildNotesSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildStudentDropdown() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: "الطالب *",
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.person),
      ),
      value: selectedStudentId,
      items: [
        DropdownMenuItem(
          value: null,
          child: Text("اختر الطالب", style: TextStyle(color: Colors.grey)),
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
      onChanged: (v) => setState(() => selectedStudentId = v),
    );
  }

  Widget _buildTeacherDropdown() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: "المعلم *",
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.school),
      ),
      value: selectedTeacherId,
      items: [
        DropdownMenuItem(
          value: null,
          child: Text("اختر المعلم", style: TextStyle(color: Colors.grey)),
        ),
        ..._teachers.map((teacher) {
          final teacherId = teacher['id']?.toString();
          final teacherName = _getTeacherName(teacher);
          return DropdownMenuItem(
            value: teacherId,
            child: Text(teacherName),
          );
        }),
      ],
      onChanged: (v) => setState(() => selectedTeacherId = v),
    );
  }

  Widget _buildSubjectDropdown() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: "المادة *",
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.menu_book),
      ),
      value: selectedSubjectId,
      items: [
        DropdownMenuItem(
          value: null,
          child: Text("اختر المادة", style: TextStyle(color: Colors.grey)),
        ),
        ..._subjects.map((subject) {
          final subjectId = subject['id']?.toString();
          final subjectName = _getSubjectName(subject);
          return DropdownMenuItem(
            value: subjectId,
            child: Text(subjectName),
          );
        }),
      ],
      onChanged: (v) => setState(() => selectedSubjectId = v),
    );
  }

  Widget _buildExamTypeDropdown() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: "نوع الاختبار *",
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.quiz),
      ),
      value: selectedExamType,
      items: [
        DropdownMenuItem(
          value: null,
          child:
              Text("اختر نوع الاختبار", style: TextStyle(color: Colors.grey)),
        ),
        ...examTypes.map((type) {
          return DropdownMenuItem(
            value: type,
            child: Text(type),
          );
        }),
      ],
      onChanged: (v) => setState(() => selectedExamType = v),
    );
  }

  Widget _buildGradeDropdown(
      String label, String? value, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.score),
      ),
      value: value,
      items: [
        DropdownMenuItem(
          value: null,
          child: Text("اختر $label", style: TextStyle(color: Colors.grey)),
        ),
        ...gradesPercentages.map((g) {
          return DropdownMenuItem(value: g, child: Text(g));
        }),
      ],
      onChanged: onChanged,
    );
  }

  Widget _buildEvaluationDropdown() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: "التقييم *",
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.star),
      ),
      value: selectedEvaluation,
      items: [
        DropdownMenuItem(
          value: null,
          child: Text("اختر التقييم", style: TextStyle(color: Colors.grey)),
        ),
        ...evaluations.map((ev) {
          return DropdownMenuItem(value: ev, child: Text(ev));
        }),
      ],
      onChanged: (v) => setState(() => selectedEvaluation = v),
    );
  }

  Widget _buildImageUploadSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.photo_library, color: Colors.purple),
                SizedBox(width: 8),
                Text(
                  "ورقة الامتحان (اختياري)",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple[700],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            if (_examPaperImage == null) ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickImage,
                      icon: Icon(Icons.photo_library),
                      label: Text("اختيار من المعرض"),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _takePhoto,
                      icon: Icon(Icons.camera_alt),
                      label: Text("التقاط صورة"),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              Column(
                children: [
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        _examPaperImage!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.error, color: Colors.red, size: 40),
                                SizedBox(height: 8),
                                Text('خطأ في تحميل الصورة'),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _removeImage,
                    icon: Icon(Icons.delete, color: Colors.red),
                    label:
                        Text("حذف الصورة", style: TextStyle(color: Colors.red)),
                    style: OutlinedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                  ),
                ],
              ),
            ],
            SizedBox(height: 8),
            Text(
              "يمكنك رفع صورة لورقة الامتحان (اختياري)",
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _isSubmitting ? null : _clearForm,
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 15),
              side: BorderSide(color: Colors.grey[300]!),
            ),
            child: Text(
              "مسح الكل",
              style: TextStyle(color: Colors.grey[700]),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _submitGrade,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 15),
            ),
            child: _isSubmitting
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text("حفظ الدرجة"),
          ),
        ),
      ],
    );
  }

  Widget _buildNotesSection() {
    return Container(
      margin: EdgeInsets.only(top: 20),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "معلومات مهمة:",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8),
          Text(
            "• جميع الحقول مطلوبة ماعدا ورقة الامتحان\n"
            "• سيتم حفظ الدرجة في سجل الطالب\n"
            "• يمكنك تعديل الدرجة لاحقاً من سجل الدرجات\n"
            "• الدرجة تحسب بالنسبة المئوية من 10% إلى 100%\n"
            "• البيانات يتم جلبها من قاعدة البيانات مباشرة\n"
            "• أنواع الاختبارات المسموحة: تجريبي، شهري، نهائي\n"
            "• يمكنك رفع صورة لورقة الامتحان (JPG, PNG - الحد الأقصى 2MB)",
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
