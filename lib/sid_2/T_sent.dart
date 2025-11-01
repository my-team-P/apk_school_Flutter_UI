import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TeacherPreparationPage extends StatefulWidget {
  final String role;

  const TeacherPreparationPage({super.key, required this.role});

  @override
  _TeacherPreparationPageState createState() => _TeacherPreparationPageState();
}

class _TeacherPreparationPageState extends State<TeacherPreparationPage> {
  List<dynamic> _teachers = [];
  bool _isLoading = false;
  final Map<int, String> _teacherStatus = {}; // id -> status
  final Map<int, Timer?> _timers = {};
  Timer? _refreshTimer;

  final Color _primaryColor = const Color(0xFF4361EE);
  final Color _successColor = const Color(0xFF4CAF50);
  final Color _warningColor = const Color(0xFFFF9800);
  final Color _backgroundColor = const Color(0xFFF8F9FA);
  final Color _textColor = Colors.white;
  final Color _accentColor = const Color(0xFF4CC9F0);

  @override
  void initState() {
    super.initState();
    _fetchTeachers();

    // تحديث تلقائي كل 10 ثواني
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _fetchTeachers();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _timers.forEach((key, timer) => timer?.cancel());
    super.dispose();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        backgroundColor: _primaryColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // جلب المعلمين مع الحالة
  Future<void> _fetchTeachers() async {
    setState(() => _isLoading = true);
    try {
      // جلب كل المعلمين
      final teachersResponse = await http.get(
        Uri.parse('http://192.168.1.101:8000/api/teachers'),
      );
      final teachersData = json.decode(teachersResponse.body)['data'] ?? [];

      // جلب كل الحالات
      final statusResponse = await http.get(
        Uri.parse('http://192.168.1.101:8000/api/teacher-statuses'),
      );
      final statusesData = json.decode(statusResponse.body)['data'] ?? [];

      final Map<int, String> statusMap = {
        for (var s in statusesData) s['teacher']['id']: s['status'],
      };

      setState(() {
        _teachers = teachersData.map((teacher) {
          final id = teacher['id'];
          teacher['status'] = statusMap[id] ?? 'absent'; // الحالة الافتراضية
          _teacherStatus[id] = teacher['status'];
          return teacher;
        }).toList();
      });
    } catch (e) {
      print('خطأ في جلب المعلمين: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // تحديث حالة معلم في السيرفر
  Future<void> _saveTeacherStatus(int teacherId, String status) async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.101:8000/api/teacher-status'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'teacher_id': teacherId, 'status': status}),
      );

      if (response.statusCode != 200) {
        _showSnackBar('فشل في حفظ الحالة على السيرفر');
      }
    } catch (e) {
      print('خطأ أثناء حفظ الحالة: $e');
    }
  }

  void _markAsPresent(int teacherId) {
    setState(() => _teacherStatus[teacherId] = 'present');
    _saveTeacherStatus(teacherId, 'present');
    _showSnackBar('تم تعيين الحالة إلى حاضر');
  }

  void _markAsVacation(int teacherId) {
    setState(() => _teacherStatus[teacherId] = 'vacation');
    _saveTeacherStatus(teacherId, 'vacation');
    _showSnackBar('تم تعيين الحالة إلى إجازة');
  }

  void _sendTeacher(int teacherId) {
    setState(() => _teacherStatus[teacherId] = 'sending');
    _saveTeacherStatus(teacherId, 'sending');
    _showSnackBar('بدأ التحضير، انتظر 30 ثانية أو اضغط إلغاء');

    _timers[teacherId]?.cancel();
    _timers[teacherId] = Timer(const Duration(seconds: 30), () async {
      try {
        final response = await http.post(
          Uri.parse('http://192.168.1.101:8000/api/get-user-phone_T'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'teacher_id': teacherId}),
        );

        if (response.statusCode == 200) {
          if (mounted) {
            setState(() => _teacherStatus[teacherId] = 'absent');
            _timers[teacherId]?.cancel();
            _timers.remove(teacherId);
            _saveTeacherStatus(teacherId, 'absent');
            _showSnackBar('تم التحضير بنجاح!');
          }
        } else {
          if (mounted) {
            setState(() => _teacherStatus[teacherId] = 'absent');
            _saveTeacherStatus(teacherId, 'absent');
          }
        }
      } catch (e) {
        print('خطأ أثناء التحضير: $e');
        if (mounted) {
          setState(() => _teacherStatus[teacherId] = 'absent');
          _saveTeacherStatus(teacherId, 'absent');
        }
      }
    });
  }

  void _cancelTeacher(int teacherId) {
    _timers[teacherId]?.cancel();
    _timers.remove(teacherId);
    setState(() => _teacherStatus[teacherId] = 'absent');
    _saveTeacherStatus(teacherId, 'absent');
    _showSnackBar('تم الإلغاء');
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _backgroundColor,
        appBar: AppBar(
          title: const Text(
            'تحضير المعلمين',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: _primaryColor,
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _teachers.isEmpty
                ? Center(
                    child: Text(
                      'لا يوجد معلمون حالياً',
                      style: TextStyle(
                        fontSize: 18,
                        color: _textColor.withOpacity(0.5),
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: _teachers.length,
                    itemBuilder: (context, index) {
                      final teacher = _teachers[index];
                      final status = _teacherStatus[teacher['id']] ?? 'absent';

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // اسم المعلم
                              Row(
                                children: [
                                  Icon(
                                    Icons.person,
                                    color: _accentColor,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      teacher['full_name'] ?? 'بدون اسم',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),

                              // الأزرار
                              if (status == 'absent' || status == 'idle')
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    // إجازة
                                    SizedBox(
                                      height: 30,
                                      child: ElevatedButton(
                                        onPressed: () =>
                                            _markAsVacation(teacher['id']),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.orange,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                          ),
                                        ),
                                        child: const Text(
                                          'إجازة',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    // حاضر
                                    SizedBox(
                                      height: 30,
                                      child: ElevatedButton(
                                        onPressed: () =>
                                            _markAsPresent(teacher['id']),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: _successColor,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                          ),
                                        ),
                                        child: const Text(
                                          'حاضر',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    // تغييب (وظيفته مثل التحضير)
                                    SizedBox(
                                      height: 30,
                                      child: ElevatedButton(
                                        onPressed: () =>
                                            _sendTeacher(teacher['id']),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: _primaryColor,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                          ),
                                        ),
                                        child: const Text(
                                          'تغييب',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              else if (status == 'sending')
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: 30,
                                      child: ElevatedButton(
                                        onPressed: () =>
                                            _cancelTeacher(teacher['id']),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: _warningColor,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                          ),
                                        ),
                                        child: const Text(
                                          'إلغاء',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              else
                                Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      color: _successColor,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      status == 'present'
                                          ? 'تم - حاضر'
                                          : status == 'vacation'
                                              ? 'تم - إجازة'
                                              : 'تم التغييب',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: _successColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
