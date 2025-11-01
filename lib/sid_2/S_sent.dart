import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SMSPage extends StatefulWidget {
  final String role;

  const SMSPage({super.key, required this.role});

  @override
  _SMSPageState createState() => _SMSPageState();
}

class _SMSPageState extends State<SMSPage> {
  final Map<int, String> _studentStatus = {};
  final Map<int, Timer?> _timers = {};
  List<dynamic> _students = [];
  List<dynamic> _classes = [];
  List<dynamic> _sections = [];
  bool _isLoading = false;

  int? _selectedClassId;
  int? _selectedSectionId;

  final Color _primaryColor = const Color(0xFF4361EE);
  final Color _successColor = const Color(0xFF4CAF50);
  final Color _warningColor = const Color(0xFFFF9800);
  final Color _errorColor = const Color(0xFFF44336);
  final Color _backgroundColor = const Color(0xFFF8F9FA);
  final Color _cardColor = Colors.white;
  final Color _textColor = const Color(0xFF2B2D42);

  @override
  void initState() {
    super.initState();
    _fetchClasses();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        backgroundColor: _primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Future<void> _fetchClasses() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.101:8000/api/classes'),
      );
      if (response.statusCode == 200) {
        setState(() {
          _classes = json.decode(response.body);
        });
      }
    } catch (e) {
      print('خطأ في جلب الفصول: $e');
    }
  }

  Future<void> _fetchSections(int classId) async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.101:8000/api/classes/$classId/sections'),
      );
      if (response.statusCode == 200) {
        setState(() {
          _sections = json.decode(response.body);
        });
      }
    } catch (e) {
      print('خطأ في جلب الشعب: $e');
    }
  }

  Future<void> _fetchStudents() async {
    if (_selectedClassId == null) return;

    setState(() => _isLoading = true);
    try {
      String url =
          'http://192.168.1.101:8000/api/students/filter?class_id=$_selectedClassId';
      if (_selectedSectionId != null) url += '&section_id=$_selectedSectionId';

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final studentsData = json.decode(response.body);

        final statusResponse = await http.get(
          Uri.parse(
            'http://192.168.1.101:8000/api/student-statuses?class_id=$_selectedClassId${_selectedSectionId != null ? '&section_id=$_selectedSectionId' : ''}',
          ),
        );

        final statusesData = statusResponse.statusCode == 200
            ? json.decode(statusResponse.body)['data']
            : [];

        Map<int, String> statusesMap = {};
        for (var s in statusesData) {
          statusesMap[s['student']['id']] = s['status'];
        }

        setState(() {
          _students = studentsData;
          _studentStatus.clear();
          for (var student in _students) {
            _studentStatus[student['id']] =
                statusesMap[student['id']] ?? 'idle';
          }
        });
      } else {
        print('فشل في جلب الطلاب: ${response.statusCode}');
      }
    } catch (e) {
      print('خطأ في جلب الطلاب: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _sendStudent(int studentId) {
    setState(() => _studentStatus[studentId] = 'sending');
    _showSnackBar('بدأ التحضير، انتظر 30 ثانية أو اضغط إلغاء');

    _timers[studentId]?.cancel();

    _timers[studentId] = Timer(const Duration(seconds: 30), () async {
      try {
        final response = await http.post(
          Uri.parse('http://192.168.1.101:8000/api/get-user-phone'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'student_id': studentId}),
        );

        if (response.statusCode == 200) {
          if (mounted) {
            setState(() => _studentStatus[studentId] = 'absent');
            _timers[studentId]?.cancel();
            _timers.remove(studentId);
            _saveStudentStatus(studentId, 'absent');
            _showSnackBar('تم التحضير بنجاح!');
          }
        } else {
          if (mounted) {
            setState(() => _studentStatus[studentId] = 'idle');
          }
        }
      } catch (e) {
        print('خطأ أثناء التحضير: $e');
        if (mounted) {
          setState(() => _studentStatus[studentId] = 'idle');
        }
      }
    });
  }

  void _cancelStudent(int studentId) {
    _timers[studentId]?.cancel();
    _timers.remove(studentId);
    setState(() => _studentStatus[studentId] = 'idle');
    _showSnackBar('تم الإلغاء');
  }

  Future<void> _saveStudentStatus(int studentId, String status) async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.101:8000/api/student-status'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'student_id': studentId, 'status': status}),
      );

      if (response.statusCode != 200) {
        _showSnackBar('فشل في حفظ الحالة على السيرفر');
      }
    } catch (e) {
      print('خطأ أثناء حفظ الحالة: $e');
    }
  }

  void _markAsPresent(int studentId) =>
      _updateStudentStatus(studentId, 'present');
  void _markAsVacation(int studentId) =>
      _updateStudentStatus(studentId, 'vacation');
  void _markAsAbsent(int studentId) =>
      _updateStudentStatus(studentId, 'absent');

  Future<void> _updateStudentStatus(int studentId, String status) async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.101:8000/api/student-status'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'student_id': studentId, 'status': status}),
      );

      if (response.statusCode == 200) {
        setState(() {
          _studentStatus[studentId] = status;
        });
        _showSnackBar('تم تحديث الحالة بنجاح!');
      } else {
        _showSnackBar('فشل في تحديث الحالة');
      }
    } catch (e) {
      print('خطأ: $e');
      _showSnackBar('حدث خطأ أثناء تحديث الحالة');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _backgroundColor,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'نظام إرسال الرسائل',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          backgroundColor: _primaryColor,
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
          ),
        ),
        body: Column(
          children: [
            // فلترة الفصل والشعبة
            Container(
              margin: EdgeInsets.all(isSmallScreen ? 12 : 16),
              padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
              decoration: BoxDecoration(
                color: _cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.filter_list_rounded, color: _primaryColor),
                      SizedBox(width: isSmallScreen ? 8 : 12),
                      Text(
                        'فلترة الطلاب',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 16 : 18,
                          fontWeight: FontWeight.bold,
                          color: _textColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isSmallScreen ? 12 : 16),
                  isSmallScreen
                      ? Column(
                          children: [
                            _buildClassDropdown(isSmallScreen),
                            SizedBox(height: 12),
                            _buildSectionDropdown(isSmallScreen),
                          ],
                        )
                      : Row(
                          children: [
                            Expanded(child: _buildClassDropdown(isSmallScreen)),
                            SizedBox(width: 12),
                            Expanded(
                                child: _buildSectionDropdown(isSmallScreen)),
                          ],
                        ),
                ],
              ),
            ),

            // عدد الطلاب أو مؤشر تحميل
            if (_selectedClassId != null)
              Container(
                margin: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 12 : 16,
                ),
                padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                decoration: BoxDecoration(
                  color: _cardColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: _isLoading
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(
                                _primaryColor,
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'جاري تحميل البيانات...',
                            style: TextStyle(
                              color: _textColor.withOpacity(0.7),
                              fontSize: isSmallScreen ? 14 : 16,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.people_alt_rounded,
                                color: _primaryColor,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'عدد الطلاب:',
                                style: TextStyle(
                                  color: _textColor.withOpacity(0.8),
                                  fontSize: isSmallScreen ? 14 : 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _primaryColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _students.length.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
              ),

            SizedBox(height: isSmallScreen ? 8 : 12),

            // قائمة الطلاب
            Expanded(
              child: _students.isEmpty && !_isLoading
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_outline_rounded,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: 16),
                          Text(
                            'لا توجد بيانات مطابقة',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: isSmallScreen ? 16 : 18,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'اختر الفصل والشعبة لعرض الطلاب',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: isSmallScreen ? 14 : 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 8 : 12,
                        vertical: 8,
                      ),
                      itemCount: _students.length,
                      itemBuilder: (context, index) {
                        var student = _students[index];
                        final status = _studentStatus[student['id']] ?? 'idle';

                        return Container(
                          margin: EdgeInsets.symmetric(
                            horizontal: isSmallScreen ? 4 : 8,
                            vertical: 4,
                          ),
                          child: Card(
                            elevation: 1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(
                                isSmallScreen ? 12 : 16,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: _primaryColor.withOpacity(
                                            0.1,
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.person_rounded,
                                          color: _primaryColor,
                                          size: 20,
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          student['name'] ?? 'بدون اسم',
                                          style: TextStyle(
                                            fontSize: isSmallScreen ? 16 : 17,
                                            fontWeight: FontWeight.bold,
                                            color: _textColor,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 12),
                                  _buildStatusButtons(
                                    student['id'],
                                    status,
                                    isSmallScreen,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassDropdown(bool isSmallScreen) {
    return Container(
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButton<int>(
        hint: Text(
          'اختر الفصل',
          style: TextStyle(
            color: _textColor.withOpacity(0.6),
            fontSize: isSmallScreen ? 14 : 16,
          ),
        ),
        value: _selectedClassId,
        isExpanded: true,
        underline: const SizedBox(),
        icon: Icon(Icons.arrow_drop_down_rounded, color: _primaryColor),
        items: _classes.map((cls) {
          return DropdownMenuItem<int>(
            value: cls['id'],
            child: Text(
              cls['grade_name'],
              style: TextStyle(
                color: _textColor,
                fontSize: isSmallScreen ? 14 : 16,
              ),
            ),
          );
        }).toList(),
        onChanged: (val) {
          setState(() {
            _selectedClassId = val;
            _selectedSectionId = null;
            _sections = [];
            _students = [];
          });
          if (val != null) {
            _fetchSections(val);
            _fetchStudents();
          }
        },
      ),
    );
  }

  Widget _buildSectionDropdown(bool isSmallScreen) {
    return Container(
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButton<int>(
        hint: Text(
          'اختر الشعبة',
          style: TextStyle(
            color: _textColor.withOpacity(0.6),
            fontSize: isSmallScreen ? 14 : 16,
          ),
        ),
        value: _selectedSectionId,
        isExpanded: true,
        underline: const SizedBox(),
        icon: Icon(Icons.arrow_drop_down_rounded, color: _primaryColor),
        items: _sections.map((sec) {
          return DropdownMenuItem<int>(
            value: sec['id'],
            child: Text(
              sec['section_name'],
              style: TextStyle(
                color: _textColor,
                fontSize: isSmallScreen ? 14 : 16,
              ),
            ),
          );
        }).toList(),
        onChanged: (val) {
          setState(() {
            _selectedSectionId = val;
          });
          _fetchStudents();
        },
      ),
    );
  }

  Widget _buildStatusButtons(int studentId, String status, bool isSmallScreen) {
    final buttonHeight = isSmallScreen ? 36.0 : 40.0;
    final buttonFontSize = isSmallScreen ? 12.0 : 13.0;

    if (status == 'idle' || status == 'absent') {
      return Row(
        children: [
          Expanded(
            child: SizedBox(
              height: buttonHeight,
              child: ElevatedButton.icon(
                onPressed: () => _markAsVacation(studentId),
                icon: Icon(Icons.beach_access_rounded, size: 16),
                label: Text(
                  'إجازة',
                  style: TextStyle(fontSize: buttonFontSize),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: SizedBox(
              height: buttonHeight,
              child: ElevatedButton.icon(
                onPressed: () => _markAsPresent(studentId),
                icon: Icon(Icons.check_circle_rounded, size: 16),
                label: Text('حاضر', style: TextStyle(fontSize: buttonFontSize)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _successColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: SizedBox(
              height: buttonHeight,
              child: ElevatedButton.icon(
                onPressed: () => _sendStudent(studentId),
                icon: Icon(Icons.person_off_rounded, size: 16),
                label: Text(
                  'تغييب',
                  style: TextStyle(fontSize: buttonFontSize),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    } else if (status == 'sending') {
      return Row(
        children: [
          Expanded(
            child: SizedBox(
              height: buttonHeight,
              child: ElevatedButton.icon(
                onPressed: () => _cancelStudent(studentId),
                icon: Icon(Icons.cancel_rounded, size: 16),
                label: Text(
                  'إلغاء التحضير',
                  style: TextStyle(fontSize: buttonFontSize),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _warningColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _warningColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _warningColor),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(_warningColor),
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'جاري التحضير...',
                    style: TextStyle(
                      color: _warningColor,
                      fontSize: buttonFontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    } else {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: _successColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _successColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_rounded, color: _successColor, size: 20),
            SizedBox(width: 8),
            Text(
              status == 'present'
                  ? 'تم التسجيل - حاضر'
                  : status == 'vacation'
                      ? 'تم التسجيل - إجازة'
                      : 'تم التغييب',
              style: TextStyle(
                color: _successColor,
                fontSize: isSmallScreen ? 14 : 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }
  }
}
