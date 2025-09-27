import 'package:admin/screens/main/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StudentPreparationPage extends StatefulWidget {
  const StudentPreparationPage({super.key});

  @override
  State<StudentPreparationPage> createState() => _StudentPreparationPageState();
}

class _StudentPreparationPageState extends State<StudentPreparationPage> {
  final List<Map<String, dynamic>> _students = [
    {
      "id": "1",
      "first": "أحمد",
      "second": "محمد",
      "third": "علي",
      "fourth": "صالح",
      "class": "1",
      "section": "أ",
      "subject": "رياضيات",
      "phone": "0512345678",
      "email": "ahmed@school.com"
    },
    {
      "id": "2",
      "first": "ليلى",
      "second": "عبدالله",
      "third": "أحمد",
      "fourth": "خالد",
      "class": "1",
      "section": "ب",
      "subject": "علوم",
      "phone": "0512345679",
      "email": "layla@school.com"
    },
    {
      "id": "3",
      "first": "سارة",
      "second": "خالد",
      "third": "أحمد",
      "fourth": "علي",
      "class": "2",
      "section": "أ",
      "subject": "لغة عربية",
      "phone": "0512345680",
      "email": "sara@school.com"
    },
    {
      "id": "4",
      "first": "محمد",
      "second": "علي",
      "third": "حسن",
      "fourth": "إبراهيم",
      "class": "2",
      "section": "ب",
      "subject": "رياضيات",
      "phone": "0512345681",
      "email": "mohammed@school.com"
    },
    {
      "id": "5",
      "first": "فاطمة",
      "second": "عمر",
      "third": "سعيد",
      "fourth": "عبدالرحمن",
      "class": "3",
      "section": "أ",
      "subject": "علوم",
      "phone": "0512345682",
      "email": "fatima@school.com"
    },
  ];

  final Map<String, String> classNames = {
    "1": "الصف الأول",
    "2": "الصف الثاني",
    "3": "الصف الثالث",
    "4": "الصف الرابع",
    "5": "الصف الخامس",
    "6": "الصف السادس",
  };

  final Map<String, Map<String, String>> _attendanceRecords = {};
  final Map<String, String> _notes = {};
  final Map<String, String> _grades = {};

  String? selectedSubject;
  String? selectedClass;
  String? selectedSection;
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // إحصائيات الحضور
  Map<String, int> get attendanceStats {
    final filtered = _getFilteredStudents();
    int present = 0;
    int absent = 0;
    int notSet = 0;

    for (final student in filtered) {
      final status = _attendanceRecords[student['id']]?['status'];
      if (status == 'حاضر') {
        present++;
      } else if (status == 'غائب') {
        absent++;
      } else {
        notSet++;
      }
    }

    return {
      'total': filtered.length,
      'present': present,
      'absent': absent,
      'notSet': notSet,
    };
  }

  List<Map<String, dynamic>> _getFilteredStudents() {
    return _students.where((student) {
      final matchesSubject =
          selectedSubject == null || student['subject'] == selectedSubject;
      final matchesClass =
          selectedClass == null || student['class'] == selectedClass;
      final matchesSection =
          selectedSection == null || student['section'] == selectedSection;
      final matchesSearch = searchQuery.isEmpty ||
          '${student['first']} ${student['second']} ${student['third']} ${student['fourth']}'
              .toLowerCase()
              .contains(searchQuery.toLowerCase());

      return matchesSubject && matchesClass && matchesSection && matchesSearch;
    }).toList();
  }

  void _savePreparation() {
    final filteredStudents = _getFilteredStudents();
    final stats = attendanceStats;

    if (stats['notSet']! > 0) {
      _showConfirmationDialog(filteredStudents);
      return;
    }

    _performSave(filteredStudents);
  }

  void _performSave(List<Map<String, dynamic>> students) {
    final now = DateTime.now();
    final date = DateFormat("yyyy-MM-dd HH:mm").format(now);

    for (final student in students) {
      final status = _attendanceRecords[student['id']]?['status'] ?? 'غير محدد';
      final note = _notes[student['id']] ?? '';
      final grade = _grades[student['id']] ?? '';

      print('''
=== سجل التحضير ===
الطالب: ${student['first']} ${student['second']} ${student['third']} ${student['fourth']}
الصف: ${classNames[student['class']]} - الشعبة: ${student['section']}
المادة: ${student['subject']}
الحضور: $status
التقييم: $grade
ملاحظات: $note
التاريخ: $date
==================
''');
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("تم حفظ تحضير ${students.length} طالب بنجاح ✅"),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showConfirmationDialog(List<Map<String, dynamic>> students) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("تأكيد الحفظ"),
        content: Text(
            "هناك ${attendanceStats['notSet']} طالب لم يتم تحديد حضورهم. هل تريد المتابعة؟"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("إلغاء"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _performSave(students);
            },
            child: Text("متابعة", style: TextStyle(color: Colors.orange)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _performSave(students);
            },
            child: Text("حفظ"),
          ),
        ],
      ),
    );
  }

  void _showStudentDetails(Map<String, dynamic> student) {
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
            Text(
              "معلومات الطالب",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 15),
            _buildDetailRow("الاسم الكامل",
                "${student['first']} ${student['second']} ${student['third']} ${student['fourth']}"),
            _buildDetailRow("الصف",
                "${classNames[student['class']]} - الشعبة ${student['section']}"),
            _buildDetailRow("المادة", student['subject']),
            _buildDetailRow("الهاتف", student['phone']),
            _buildDetailRow("البريد الإلكتروني", student['email']),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // إرسال رسالة للطالب
                    },
                    child: Text("إرسال رسالة"),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // الاتصال بالطالب
                    },
                    child: Text("الاتصال"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
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

  void _markAllAsPresent() {
    final filteredStudents = _getFilteredStudents();
    setState(() {
      for (final student in filteredStudents) {
        _attendanceRecords[student['id']] = {
          'status': 'حاضر',
          'time': DateFormat("HH:mm").format(DateTime.now()),
        };
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("تم تسجيل حضور جميع الطلاب")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredStudents = _getFilteredStudents();
    final stats = attendanceStats;
    final today = DateFormat("yyyy-MM-dd").format(DateTime.now());

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          "نظام التحضير",
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
            icon: Icon(Icons.bar_chart, color: Colors.white),
            onPressed: () {
              _showAttendanceStats();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // إحصائيات سريعة
          Container(
            padding: EdgeInsets.all(16),
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
                _buildStatItem(Icons.people, "${stats['total']}", "إجمالي"),
                _buildStatItem(
                    Icons.check_circle, "${stats['present']}", "حاضر"),
                _buildStatItem(Icons.cancel, "${stats['absent']}", "غائب"),
                _buildStatItem(
                    Icons.schedule, "${stats['notSet']}", "لم يُحدد"),
              ],
            ),
          ),

          // شريط البحث والفلاتر
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                // شريط البحث
                TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => searchQuery = value),
                  decoration: InputDecoration(
                    hintText: "ابحث عن طالب...",
                    prefixIcon: Icon(Icons.search),
                    suffixIcon: searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => searchQuery = '');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                // الفلاتر
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedSubject,
                        decoration: InputDecoration(
                          labelText: "المادة",
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          DropdownMenuItem(
                              value: null, child: Text("جميع المواد")),
                          ...['رياضيات', 'علوم', 'لغة عربية'].map((subject) =>
                              DropdownMenuItem(
                                  value: subject, child: Text(subject))),
                        ],
                        onChanged: (value) =>
                            setState(() => selectedSubject = value),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedClass,
                        decoration: InputDecoration(
                          labelText: "الصف",
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          DropdownMenuItem(
                              value: null, child: Text("جميع الصفوف")),
                          ...['1', '2', '3'].map((cls) => DropdownMenuItem(
                              value: cls, child: Text(classNames[cls]!))),
                        ],
                        onChanged: (value) =>
                            setState(() => selectedClass = value),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedSection,
                        decoration: InputDecoration(
                          labelText: "الشعبة",
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          DropdownMenuItem(
                              value: null, child: Text("جميع الشعب")),
                          ...['أ', 'ب'].map((section) => DropdownMenuItem(
                              value: section, child: Text(section))),
                        ],
                        onChanged: (value) =>
                            setState(() => selectedSection = value),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // معلومات الجلسة
          Container(
            padding: EdgeInsets.all(12),
            color: Colors.grey[100],
            child: Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                SizedBox(width: 8),
                Text("تاريخ اليوم: $today",
                    style: TextStyle(color: Colors.grey[600])),
                Spacer(),
                if (filteredStudents.isNotEmpty)
                  ElevatedButton.icon(
                    onPressed: _markAllAsPresent,
                    icon: Icon(Icons.check, size: 16),
                    label: Text("تسجيل الكل حاضر"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
              ],
            ),
          ),

          // قائمة الطلاب
          Expanded(
            child: filteredStudents.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off,
                            size: 80, color: Colors.grey[300]),
                        SizedBox(height: 20),
                        Text(
                          "لا توجد نتائج",
                          style:
                              TextStyle(fontSize: 18, color: Colors.grey[600]),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "جرب تغيير عوامل التصفية أو البحث",
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: filteredStudents.length,
                    itemBuilder: (context, index) {
                      final student = filteredStudents[index];
                      return _buildStudentCard(student, index);
                    },
                  ),
          ),

          // أزرار التحكم
          if (filteredStudents.isNotEmpty)
            Container(
              padding: EdgeInsets.all(16),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _savePreparation,
                      icon: Icon(Icons.save),
                      label: Text("حفظ التحضير"),
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
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const MainScreen()),
                        );
                      },
                      icon: Icon(Icons.home),
                      label: Text("الرئيسية"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  ),
                ],
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
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 16),
        ),
        SizedBox(height: 4),
        Text(
          count,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
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

  Widget _buildStudentCard(Map<String, dynamic> student, int index) {
    final attendance = _attendanceRecords[student['id']];
    final status = attendance?['status'];
    final note = _notes[student['id']] ?? '';
    final grade = _grades[student['id']] ?? '';

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
          onTap: () => _showStudentDetails(student),
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: _getStatusColor(status),
                      child: Text(
                        student['first'][0],
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${student['first']} ${student['second']} ${student['third']} ${student['fourth']}",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "${classNames[student['class']]} - الشعبة ${student['section']}",
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusIndicator(status),
                  ],
                ),
                SizedBox(height: 12),
                // عناصر التحكم
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: status,
                        decoration: InputDecoration(
                          labelText: "الحضور",
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 8),
                        ),
                        items: [
                          DropdownMenuItem(
                              value: null, child: Text("اختر الحضور")),
                          DropdownMenuItem(value: "حاضر", child: Text("حاضر")),
                          DropdownMenuItem(value: "غائب", child: Text("غائب")),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _attendanceRecords[student['id']] = {
                              'status': value!,
                              'time':
                                  DateFormat("HH:mm").format(DateTime.now()),
                            };
                          });
                        },
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: grade.isNotEmpty ? grade : null,
                        decoration: InputDecoration(
                          labelText: "التقييم",
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 8),
                        ),
                        items: [
                          DropdownMenuItem(value: null, child: Text("التقييم")),
                          DropdownMenuItem(
                              value: "ممتاز", child: Text("ممتاز")),
                          DropdownMenuItem(
                              value: "جيد جداً", child: Text("جيد جداً")),
                          DropdownMenuItem(value: "جيد", child: Text("جيد")),
                          DropdownMenuItem(
                              value: "مقبول", child: Text("مقبول")),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _grades[student['id']] = value ?? '';
                          });
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                TextFormField(
                  initialValue: note,
                  onChanged: (value) => _notes[student['id']] = value,
                  decoration: InputDecoration(
                    labelText: "ملاحظات",
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(String? status) {
    Color color;
    String text;

    switch (status) {
      case 'حاضر':
        color = Colors.green;
        text = 'حاضر';
        break;
      case 'غائب':
        color = Colors.red;
        text = 'غائب';
        break;
      default:
        color = Colors.orange;
        text = 'لم يُحدد';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style:
            TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'حاضر':
        return Colors.green;
      case 'غائب':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  void _showAttendanceStats() {
    final stats = attendanceStats;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("إحصائيات الحضور"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatItemDialog(
                Icons.people, "إجمالي الطلاب", "${stats['total']}"),
            _buildStatItemDialog(
                Icons.check_circle, "الحضور", "${stats['present']}"),
            _buildStatItemDialog(Icons.cancel, "الغياب", "${stats['absent']}"),
            _buildStatItemDialog(
                Icons.schedule, "لم يُحدد", "${stats['notSet']}"),
            SizedBox(height: 10),
            LinearProgressIndicator(
              value:
                  stats['total']! > 0 ? stats['present']! / stats['total']! : 0,
              backgroundColor: Colors.grey[300],
              color: Colors.green,
            ),
            SizedBox(height: 5),
            Text(
              "نسبة الحضور: ${stats['total']! > 0 ? ((stats['present']! / stats['total']!) * 100).toStringAsFixed(1) : 0}%",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("إغلاق"),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItemDialog(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon, color: Color(0xFF667eea)),
      title: Text(label),
      trailing: Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}
