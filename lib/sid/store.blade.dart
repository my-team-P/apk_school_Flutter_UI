import 'package:flutter/material.dart';
import 'package:admin/screens/main/main_screen.dart';

class StorePage extends StatefulWidget {
  const StorePage({super.key});

  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  // بيانات الاختبارات
  final List<Map<String, dynamic>> _allExams = [
    {
      "id": "1",
      "subject": "الرياضيات",
      "teacher": "أحمد محمد",
      "date": "2024-03-20",
      "time": "09:00 ص",
      "duration": "90 دقيقة",
      "class": "الصف العاشر",
      "section": "أ",
      "type": "فصلي",
      "room": "القاعة 101",
      "status": "قادم",
      "importance": "عالية",
      "syllabus": "الفصول 1-4",
      "notes": "يسمح باستخدام الآلة الحاسبة"
    },
    {
      "id": "2",
      "subject": "اللغة العربية",
      "teacher": "فاطمة عبدالله",
      "date": "2024-03-22",
      "time": "10:30 ص",
      "duration": "120 دقيقة",
      "class": "الصف التاسع",
      "section": "ب",
      "type": "بسيط",
      "room": "القاعة 203",
      "status": "قادم",
      "importance": "متوسطة",
      "syllabus": "النصوص الأدبية",
      "notes": "اختبار كتابي فقط"
    },
    {
      "id": "3",
      "subject": "العلوم",
      "teacher": "خالد إبراهيم",
      "date": "2024-03-18",
      "time": "08:00 ص",
      "duration": "60 دقيقة",
      "class": "الصف الثامن",
      "section": "ج",
      "type": "عملي",
      "room": "المختبر 1",
      "status": "منتهي",
      "importance": "عالية",
      "syllabus": "التفاعلات الكيميائية",
      "notes": "يرجى إحضار معطف المختبر"
    },
    {
      "id": "4",
      "subject": "اللغة الإنجليزية",
      "teacher": "سارة سميث",
      "date": "2024-03-25",
      "time": "11:00 ص",
      "duration": "90 دقيقة",
      "class": "الصف العاشر",
      "section": "أ",
      "type": "استماع ومحادثة",
      "room": "معمل اللغات",
      "status": "قادم",
      "importance": "عالية",
      "syllabus": "Unit 5-6",
      "notes": "سيتم اختبار المحادثة"
    },
    {
      "id": "5",
      "subject": "التربية الإسلامية",
      "teacher": "محمد علي",
      "date": "2024-03-19",
      "time": "01:30 م",
      "duration": "45 دقيقة",
      "class": "الصف السابع",
      "section": "أ",
      "type": "تحريري",
      "room": "القاعة 105",
      "status": "منتهي",
      "importance": "منخفضة",
      "syllabus": "سورة البقرة",
      "notes": "أسئلة موضوعية"
    },
    {
      "id": "6",
      "subject": "الحاسب الآلي",
      "teacher": "علي حسن",
      "date": "2024-03-27",
      "time": "02:00 م",
      "duration": "120 دقيقة",
      "class": "الصف الحادي عشر",
      "section": "ب",
      "type": "عملي",
      "room": "معمل الحاسوب 2",
      "status": "قادم",
      "importance": "عالية",
      "syllabus": "برمجة Python",
      "notes": "اختبار عملي على الحاسوب"
    },
  ];

  // عوامل التصفية
  String? _selectedSubject;
  String? _selectedClass;
  String? _selectedStatus;
  String? _selectedImportance;
  DateTime? _selectedDate;
  String _searchQuery = '';

  final List<String> _subjects = [
    "الرياضيات",
    "اللغة العربية",
    "العلوم",
    "اللغة الإنجليزية",
    "التربية الإسلامية",
    "الحاسب الآلي",
    "الدراسات الاجتماعية",
    "التربية الفنية"
  ];

  final List<String> _classes = [
    "الصف السابع",
    "الصف الثامن",
    "الصف التاسع",
    "الصف العاشر",
    "الصف الحادي عشر",
    "الصف الثاني عشر"
  ];

  final List<String> _statuses = ["قادم", "منتهي", "ملغى"];
  final List<String> _importanceLevels = ["عالية", "متوسطة", "منخفضة"];

  // الحصول على الاختبارات المصفاة
  List<Map<String, dynamic>> get _filteredExams {
    return _allExams.where((exam) {
      final matchesSubject =
          _selectedSubject == null || exam["subject"] == _selectedSubject;
      final matchesClass =
          _selectedClass == null || exam["class"] == _selectedClass;
      final matchesStatus =
          _selectedStatus == null || exam["status"] == _selectedStatus;
      final matchesImportance = _selectedImportance == null ||
          exam["importance"] == _selectedImportance;
      final matchesDate = _selectedDate == null ||
          _isSameDay(_parseDate(exam["date"]), _selectedDate!);
      final matchesSearch = _searchQuery.isEmpty ||
          exam["subject"].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          exam["teacher"].toLowerCase().contains(_searchQuery.toLowerCase());

      return matchesSubject &&
          matchesClass &&
          matchesStatus &&
          matchesImportance &&
          matchesDate &&
          matchesSearch;
    }).toList();
  }

  DateTime _parseDate(String dateString) {
    try {
      final parts = dateString.split('-');
      if (parts.length == 3) {
        return DateTime(
            int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
      }
    } catch (e) {
      print('Error parsing date: $dateString, error: $e');
    }
    return DateTime.now();
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  // دالة تنسيق التاريخ المحسنة
  String _formatDate(String dateString) {
    try {
      final date = _parseDate(dateString);
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }

  String _formatDateTime(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
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

  void _showExamDetails(Map<String, dynamic> exam) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
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
                _buildSubjectIcon(exam["subject"]),
                SizedBox(width: 15),
                Expanded(
                  child: Text(
                    exam["subject"],
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                _buildStatusChip(exam["status"]),
              ],
            ),
            SizedBox(height: 20),
            _buildDetailRow("المعلم", exam["teacher"], Icons.person),
            _buildDetailRow(
                "الصف", "${exam["class"]} - ${exam["section"]}", Icons.school),
            _buildDetailRow(
                "التاريخ", _formatDate(exam["date"]), Icons.calendar_today),
            _buildDetailRow("الوقت", exam["time"], Icons.access_time),
            _buildDetailRow("المدة", exam["duration"], Icons.timer),
            _buildDetailRow("القاعة", exam["room"], Icons.room),
            _buildDetailRow("نوع الاختبار", exam["type"], Icons.assignment),
            _buildDetailRow("الأهمية", exam["importance"], Icons.flag),
            SizedBox(height: 15),
            Text("المقرر:", style: TextStyle(fontWeight: FontWeight.bold)),
            Text(exam["syllabus"], style: TextStyle(color: Colors.grey[700])),
            SizedBox(height: 10),
            Text("ملاحظات:", style: TextStyle(fontWeight: FontWeight.bold)),
            Text(exam["notes"], style: TextStyle(color: Colors.grey[700])),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _setReminder(exam);
                    },
                    icon: Icon(Icons.notifications),
                    label: Text("تذكير"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _shareExam(exam);
                    },
                    icon: Icon(Icons.share),
                    label: Text("مشاركة"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
          ],
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
          Text(value),
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
      case "ملغى":
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

  void _setReminder(Map<String, dynamic> exam) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("تم ضبط تذكير لاختبار ${exam["subject"]}"),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _shareExam(Map<String, dynamic> exam) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("تم مشاركة تفاصيل الاختبار"),
        backgroundColor: Colors.blue,
      ),
    );
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
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
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
          if (activeFiltersCount > 0)
            Badge(
              label: Text(activeFiltersCount.toString()),
              child: IconButton(
                icon: Icon(Icons.filter_alt, color: Colors.white),
                onPressed: _clearFilters,
                tooltip: "مسح الفلاتر",
              ),
            ),
          IconButton(
            icon: Icon(Icons.calendar_today, color: Colors.white),
            onPressed: () {
              _showCalendarView();
            },
            tooltip: "عرض التقويم",
          ),
        ],
      ),
      body: Column(
        children: [
          // شريط البحث
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.white,
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: "ابحث باسم المادة أو المعلم...",
                prefixIcon: Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () => setState(() => _searchQuery = ''),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          // الفلاتر
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedSubject,
                        decoration: InputDecoration(
                          labelText: "المادة",
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        items: _subjects
                            .map((subject) => DropdownMenuItem(
                                  value: subject,
                                  child: Text(subject),
                                ))
                            .toList(),
                        onChanged: (value) =>
                            setState(() => _selectedSubject = value),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedClass,
                        decoration: InputDecoration(
                          labelText: "الصف",
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        items: _classes
                            .map((cls) => DropdownMenuItem(
                                  value: cls,
                                  child: Text(cls),
                                ))
                            .toList(),
                        onChanged: (value) =>
                            setState(() => _selectedClass = value),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedStatus,
                        decoration: InputDecoration(
                          labelText: "الحالة",
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        items: _statuses
                            .map((status) => DropdownMenuItem(
                                  value: status,
                                  child: Text(status),
                                ))
                            .toList(),
                        onChanged: (value) =>
                            setState(() => _selectedStatus = value),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedImportance,
                        decoration: InputDecoration(
                          labelText: "الأهمية",
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        items: _importanceLevels
                            .map((importance) => DropdownMenuItem(
                                  value: importance,
                                  child: Text(importance),
                                ))
                            .toList(),
                        onChanged: (value) =>
                            setState(() => _selectedImportance = value),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: () => _selectDate(context),
                  icon: Icon(Icons.calendar_today),
                  label: Text(_selectedDate == null
                      ? "اختر تاريخ"
                      : _formatDateTime(_selectedDate!)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    minimumSize: Size(double.infinity, 50),
                  ),
                ),
              ],
            ),
          ),

          // إحصائيات سريعة
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.grey[50],
            child: Row(
              children: [
                Text(
                  "عرض ${filteredExams.length} من ${_allExams.length} اختبار",
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                Spacer(),
                if (activeFiltersCount > 0)
                  Text(
                    "$activeFiltersCount فلتر نشط",
                    style: TextStyle(color: Colors.blue, fontSize: 12),
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
                          "لا توجد اختبارات مطابقة",
                          style:
                              TextStyle(fontSize: 18, color: Colors.grey[600]),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "جرب تغيير عوامل التصفية",
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                        SizedBox(height: 20),
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

  Widget _buildExamCard(Map<String, dynamic> exam) {
    final isPast = exam["status"] == "منتهي";

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 3,
      child: ListTile(
        leading: _buildSubjectIcon(exam["subject"]),
        title: Text(
          exam["subject"],
          style: TextStyle(
            fontWeight: FontWeight.bold,
            decoration: isPast ? TextDecoration.lineThrough : null,
            color: isPast ? Colors.grey : Colors.black,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("${exam["class"]} - ${exam["teacher"]}"),
            Text("${exam["date"]} - ${exam["time"]}"),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildStatusChip(exam["status"]),
            SizedBox(height: 4),
            Text(exam["duration"], style: TextStyle(fontSize: 12)),
          ],
        ),
        onTap: () => _showExamDetails(exam),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _showCalendarView() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("عرض التقويم - قريباً")),
    );
  }
}
