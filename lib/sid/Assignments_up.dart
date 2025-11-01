import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:file_picker/file_picker.dart';

class AssignmentUploadPage extends StatefulWidget {
  final String role; // "admin", "teacher", "student"

  const AssignmentUploadPage({super.key, required this.role});
  @override
  _AssignmentUploadPageState createState() => _AssignmentUploadPageState();
}

class _AssignmentUploadPageState extends State<AssignmentUploadPage> {
  final TextEditingController _assignmentTitleController =
      TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _teacherNameController = TextEditingController();

  DateTime? _selectedDate;
  DateTime? _selectedDueDate;
  File? _selectedFile;
  String? _selectedClass;
  String? _selectedSection;
  String? _selectedSubject;
  String? _selectedPriority;
  bool _isSubmitting = false;

  // ألوان متدرجة جميلة
  final Color _primaryColor = const Color.fromARGB(255, 195, 101, 14);
  final Color _secondaryColor = const Color.fromARGB(255, 160, 125, 10);
  final Color _accentColor = const Color(0xFF4CC9F0);
  final Color _successColor = const Color(0xFF4CAF50);
  final Color _warningColor = const Color(0xFFFF9800);
  final Color _errorColor = const Color(0xFFF44336);
  final Color _backgroundColor = const Color(0xFFF8F9FA);
  final Color _cardColor = Colors.white;
  final Color _textColor = const Color(0xFF2B2D42);

  // قوائم البيانات
  final List<String> _classes = [
    'الصف الأول',
    'الصف الثاني',
    'الصف الثالث',
    'الصف الرابع',
    'الصف الخامس',
    'الصف السادس',
  ];
  final List<String> _sections = ['أ', 'ب', 'ج', 'د', 'هـ'];
  final List<String> _subjects = [
    'اللغة العربية',
    'اللغة الإنجليزية',
    'الرياضيات',
    'العلوم',
    'الدراسات الاجتماعية',
    'التربية الإسلامية',
    'الحاسب الآلي',
    'التربية الفنية',
  ];

  // قائمة مستويات الأولوية
  final List<String> _priorities = ['عاجل', 'متوسط', 'منخفض'];

  // ألوان لكل مستوى أولوية
  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'عاجل':
        return _errorColor;
      case 'متوسط':
        return _warningColor;
      case 'منخفض':
        return _successColor;
      default:
        return _primaryColor;
    }
  }

  // أيقونة لكل مستوى أولوية
  IconData _getPriorityIcon(String priority) {
    switch (priority) {
      case 'عاجل':
        return Icons.warning_amber_rounded;
      case 'متوسط':
        return Icons.info_outline;
      case 'منخفض':
        return Icons.check_circle_outline;
      default:
        return Icons.flag_outlined;
    }
  }

  Future<void> _pickDate(String type) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: _primaryColor,
            colorScheme: ColorScheme.light(primary: _primaryColor),
            buttonTheme: const ButtonThemeData(
              textTheme: ButtonTextTheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (type == 'assignment') {
          _selectedDate = picked;
        } else {
          _selectedDueDate = picked;
        }
      });
    }
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: [
          'pdf',
          'doc',
          'docx',
          'jpg',
          'jpeg',
          'png',
          'ppt',
          'pptx',
        ],
      );
      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
        });
        _showSnackBar('تم اختيار الملف بنجاح', _successColor);
      }
    } catch (e) {
      _showSnackBar('حدث خطأ أثناء اختيار الملف', _errorColor);
      print('FilePicker error: $e');
    }
  }

  Future<void> _submitAssignment() async {
    if (_assignmentTitleController.text.isEmpty ||
        _teacherNameController.text.isEmpty ||
        _selectedClass == null ||
        _selectedSection == null ||
        _selectedSubject == null ||
        _selectedDate == null) {
      _showSnackBar('يرجى ملء جميع الحقول المطلوبة', _warningColor);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://192.168.1.101:8000/api/upload-assignment'),
      );

      request.fields['title'] = _assignmentTitleController.text;
      request.fields['teacher_name'] = _teacherNameController.text;
      request.fields['class_name'] = _selectedClass!;
      request.fields['section'] = _selectedSection!;
      request.fields['subject'] = _selectedSubject!;
      request.fields['priority'] = _selectedPriority ?? 'متوسط';
      request.fields['assignment_date'] = _selectedDate!.toIso8601String();
      request.fields['due_date'] = _selectedDueDate?.toIso8601String() ?? '';
      request.fields['description'] = _descriptionController.text;
      request.fields['upload_time'] = DateTime.now().toIso8601String();

      if (_selectedFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'assignment_file',
            _selectedFile!.path,
          ),
        );
      }

      var response = await request.send();

      if (response.statusCode == 200) {
        _showSnackBar('تم رفع التكليف بنجاح', _successColor);
        _resetForm();
      } else {
        _showSnackBar('فشل في رفع التكليف', _errorColor);
      }
    } catch (e) {
      _showSnackBar('حدث خطأ أثناء الرفع', _errorColor);
      print('Error: $e');
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  void _resetForm() {
    _assignmentTitleController.clear();
    _descriptionController.clear();
    _teacherNameController.clear();
    setState(() {
      _selectedDate = null;
      _selectedDueDate = null;
      _selectedFile = null;
      _selectedClass = null;
      _selectedSection = null;
      _selectedSubject = null;
      _selectedPriority = null;
    });
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              color == _successColor ? Icons.check_circle : Icons.error,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        duration: const Duration(seconds: 3),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  String _getFileIcon(String? fileName) {
    if (fileName == null) return '📄';
    final ext = fileName.toLowerCase().split('.').last;
    switch (ext) {
      case 'pdf':
        return '📕';
      case 'doc':
      case 'docx':
        return '📘';
      case 'jpg':
      case 'jpeg':
      case 'png':
        return '🖼️';
      case 'ppt':
      case 'pptx':
        return '📊';
      default:
        return '📄';
    }
  }

  @override
  Widget build(BuildContext context) {
    // استخدام MediaQuery لمعرفة حجم الشاشة
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 600;
    final isLargeScreen = screenWidth > 900;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _backgroundColor,
        appBar: AppBar(
          title: Text(
            'رفع تكليف دراسي',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isSmallScreen ? 18 : 22,
            ),
          ),
          centerTitle: true,
          backgroundColor: _primaryColor,
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
          ),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: isSmallScreen ? 20 : 24,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.all(isSmallScreen ? 12 : 20),
              child: Column(
                children: [
                  // بطاقة الترحيب - تتغير حسب حجم الشاشة
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
                    margin: EdgeInsets.only(bottom: isSmallScreen ? 16 : 24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [_primaryColor, _secondaryColor],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: _primaryColor.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.assignment_outlined,
                          color: Colors.white,
                          size: isSmallScreen ? 32 : 40,
                        ),
                        SizedBox(height: isSmallScreen ? 8 : 12),
                        Text(
                          'نظام رفع التكليفات',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isSmallScreen ? 20 : 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 4 : 8),
                        Text(
                          'قم برفع التكليف الدراسي للطلاب مع تحديد الفصل والشعبة والمادة',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: isSmallScreen ? 14 : 16,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // نموذج رفع التكليف
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
                    decoration: BoxDecoration(
                      color: _cardColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // المعلومات الأساسية
                        _buildFormSection(
                          icon: Icons.info_outline,
                          title: 'المعلومات الأساسية',
                          isSmallScreen: isSmallScreen,
                          children: [
                            _buildTextField(
                              controller: _assignmentTitleController,
                              label: 'عنوان التكليف *',
                              icon: Icons.title,
                              isSmallScreen: isSmallScreen,
                            ),
                            SizedBox(height: isSmallScreen ? 12 : 16),
                            _buildTextField(
                              controller: _teacherNameController,
                              label: 'اسم الأستاذ *',
                              icon: Icons.person_outline,
                              isSmallScreen: isSmallScreen,
                            ),
                          ],
                        ),

                        SizedBox(height: isSmallScreen ? 16 : 24),

                        // الفصل والشعبة والمادة
                        _buildFormSection(
                          icon: Icons.school_outlined,
                          title: 'التصنيف',
                          isSmallScreen: isSmallScreen,
                          children: [
                            isSmallScreen
                                ? Column(
                                    children: [
                                      _buildDropdown(
                                        value: _selectedClass,
                                        items: _classes,
                                        hint: 'اختر الفصل *',
                                        icon: Icons.class_outlined,
                                        isSmallScreen: isSmallScreen,
                                      ),
                                      SizedBox(height: 12),
                                      _buildDropdown(
                                        value: _selectedSection,
                                        items: _sections,
                                        hint: 'اختر الشعبة *',
                                        icon: Icons.groups_outlined,
                                        isSmallScreen: isSmallScreen,
                                      ),
                                    ],
                                  )
                                : Row(
                                    children: [
                                      Expanded(
                                        child: _buildDropdown(
                                          value: _selectedClass,
                                          items: _classes,
                                          hint: 'اختر الفصل *',
                                          icon: Icons.class_outlined,
                                          isSmallScreen: isSmallScreen,
                                        ),
                                      ),
                                      SizedBox(width: isSmallScreen ? 8 : 12),
                                      Expanded(
                                        child: _buildDropdown(
                                          value: _selectedSection,
                                          items: _sections,
                                          hint: 'اختر الشعبة *',
                                          icon: Icons.groups_outlined,
                                          isSmallScreen: isSmallScreen,
                                        ),
                                      ),
                                    ],
                                  ),
                            SizedBox(height: isSmallScreen ? 12 : 16),
                            _buildDropdown(
                              value: _selectedSubject,
                              items: _subjects,
                              hint: 'اختر المادة *',
                              icon: Icons.menu_book_outlined,
                              isSmallScreen: isSmallScreen,
                            ),
                          ],
                        ),

                        SizedBox(height: isSmallScreen ? 16 : 24),

                        // مستوى الأولوية
                        _buildFormSection(
                          icon: Icons.flag_outlined,
                          title: 'مستوى الأولوية',
                          isSmallScreen: isSmallScreen,
                          children: [
                            Wrap(
                              spacing: isSmallScreen ? 8 : 12,
                              runSpacing: isSmallScreen ? 8 : 12,
                              children: _priorities.map((priority) {
                                final isSelected =
                                    _selectedPriority == priority;
                                return ChoiceChip(
                                  label: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _getPriorityIcon(priority),
                                        color: isSelected
                                            ? Colors.white
                                            : _getPriorityColor(
                                                priority,
                                              ),
                                        size: isSmallScreen ? 16 : 18,
                                      ),
                                      SizedBox(
                                        width: isSmallScreen ? 4 : 6,
                                      ),
                                      Text(
                                        priority,
                                        style: TextStyle(
                                          color: isSelected
                                              ? Colors.white
                                              : _getPriorityColor(
                                                  priority,
                                                ),
                                          fontSize: isSmallScreen ? 12 : 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    setState(() {
                                      _selectedPriority =
                                          selected ? priority : null;
                                    });
                                  },
                                  backgroundColor: _backgroundColor,
                                  selectedColor: _getPriorityColor(
                                    priority,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    side: BorderSide(
                                      color: _getPriorityColor(priority),
                                      width: 2,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            SizedBox(height: isSmallScreen ? 8 : 12),
                            if (_selectedPriority != null)
                              Container(
                                padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
                                decoration: BoxDecoration(
                                  color: _getPriorityColor(
                                    _selectedPriority!,
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _getPriorityColor(
                                      _selectedPriority!,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      _getPriorityIcon(_selectedPriority!),
                                      color: _getPriorityColor(
                                        _selectedPriority!,
                                      ),
                                      size: isSmallScreen ? 16 : 20,
                                    ),
                                    SizedBox(width: isSmallScreen ? 8 : 12),
                                    Expanded(
                                      child: Text(
                                        _selectedPriority == 'عاجل'
                                            ? 'هذا التكليف عاجل ويتطلب انتباه فوري'
                                            : _selectedPriority == 'متوسط'
                                                ? 'هذا التكليف متوسط الأهمية'
                                                : 'هذا التكليف منخفض الأهمية',
                                        style: TextStyle(
                                          color: _getPriorityColor(
                                            _selectedPriority!,
                                          ),
                                          fontSize: isSmallScreen ? 12 : 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),

                        SizedBox(height: isSmallScreen ? 16 : 24),

                        // التواريخ
                        _buildFormSection(
                          icon: Icons.date_range_outlined,
                          title: 'التواريخ',
                          isSmallScreen: isSmallScreen,
                          children: [
                            isSmallScreen
                                ? Column(
                                    children: [
                                      _buildDateField(
                                        date: _selectedDate,
                                        label: 'تاريخ التكليف *',
                                        onTap: () => _pickDate('assignment'),
                                        isSmallScreen: isSmallScreen,
                                      ),
                                      SizedBox(height: 12),
                                      _buildDateField(
                                        date: _selectedDueDate,
                                        label: 'تاريخ التسليم',
                                        onTap: () => _pickDate('due'),
                                        isSmallScreen: isSmallScreen,
                                      ),
                                    ],
                                  )
                                : Row(
                                    children: [
                                      Expanded(
                                        child: _buildDateField(
                                          date: _selectedDate,
                                          label: 'تاريخ التكليف *',
                                          onTap: () => _pickDate('assignment'),
                                          isSmallScreen: isSmallScreen,
                                        ),
                                      ),
                                      SizedBox(width: isSmallScreen ? 8 : 12),
                                      Expanded(
                                        child: _buildDateField(
                                          date: _selectedDueDate,
                                          label: 'تاريخ التسليم',
                                          onTap: () => _pickDate('due'),
                                          isSmallScreen: isSmallScreen,
                                        ),
                                      ),
                                    ],
                                  ),
                          ],
                        ),

                        SizedBox(height: isSmallScreen ? 16 : 24),

                        // وصف التكليف
                        _buildFormSection(
                          icon: Icons.description_outlined,
                          title: 'وصف التكليف',
                          isSmallScreen: isSmallScreen,
                          children: [
                            TextField(
                              controller: _descriptionController,
                              maxLines: isSmallScreen ? 3 : 4,
                              style: TextStyle(
                                color: _textColor,
                                fontSize: isSmallScreen ? 14 : 16,
                              ),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: _backgroundColor,
                                hintText:
                                    'اكتب وصفاً مفصلاً للتكليف والمطلوب من الطلاب...',
                                hintStyle: TextStyle(
                                  color: Colors.grey,
                                  fontSize: isSmallScreen ? 14 : 16,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: EdgeInsets.all(
                                  isSmallScreen ? 12 : 16,
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: isSmallScreen ? 16 : 24),

                        // رفع الملف
                        _buildFormSection(
                          icon: Icons.attach_file_outlined,
                          title: 'ملف التكليف',
                          isSmallScreen: isSmallScreen,
                          children: [
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                              decoration: BoxDecoration(
                                color: _backgroundColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _selectedFile != null
                                      ? _successColor
                                      : Colors.grey.shade300,
                                  width: _selectedFile != null ? 2 : 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        _getFileIcon(
                                          _selectedFile?.path.split('/').last,
                                        ),
                                        style: TextStyle(
                                          fontSize: isSmallScreen ? 20 : 24,
                                        ),
                                      ),
                                      SizedBox(width: isSmallScreen ? 8 : 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              _selectedFile == null
                                                  ? 'لم يتم اختيار ملف'
                                                  : _selectedFile!.path
                                                      .split('/')
                                                      .last,
                                              style: TextStyle(
                                                color: _selectedFile == null
                                                    ? Colors.grey
                                                    : _textColor,
                                                fontSize:
                                                    isSmallScreen ? 12 : 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            if (_selectedFile != null)
                                              Text(
                                                '${(_selectedFile!.lengthSync() / 1024).toStringAsFixed(1)} KB',
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize:
                                                      isSmallScreen ? 10 : 12,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: isSmallScreen ? 8 : 12),
                                      ElevatedButton(
                                        onPressed: _pickFile,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: _primaryColor,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          padding: EdgeInsets.symmetric(
                                            horizontal: isSmallScreen ? 12 : 16,
                                            vertical: isSmallScreen ? 6 : 8,
                                          ),
                                        ),
                                        child: Text(
                                          'اختر ملف',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: isSmallScreen ? 12 : 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (_selectedFile != null) ...[
                                    SizedBox(height: isSmallScreen ? 6 : 8),
                                    LinearProgressIndicator(
                                      value: 1.0,
                                      backgroundColor: _backgroundColor,
                                      valueColor: AlwaysStoppedAnimation(
                                        _successColor,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            SizedBox(height: isSmallScreen ? 6 : 8),
                            Text(
                              'يمكن رفع ملفات: PDF, Word, PowerPoint, الصور',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: isSmallScreen ? 10 : 12,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: isSmallScreen ? 20 : 30),

                        // زر الرفع
                        Container(
                          width: double.infinity,
                          height: isSmallScreen ? 48 : 56,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: _isSubmitting
                                  ? [Colors.grey, Colors.grey.shade600]
                                  : [_primaryColor, _secondaryColor],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: _isSubmitting
                                ? []
                                : [
                                    BoxShadow(
                                      color: _primaryColor.withOpacity(0.3),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                          ),
                          child: ElevatedButton(
                            onPressed: _isSubmitting ? null : _submitAssignment,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (_isSubmitting)
                                  SizedBox(
                                    width: isSmallScreen ? 16 : 20,
                                    height: isSmallScreen ? 16 : 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                else
                                  Icon(
                                    Icons.cloud_upload_outlined,
                                    color: Colors.white,
                                    size: isSmallScreen ? 18 : 24,
                                  ),
                                SizedBox(width: isSmallScreen ? 8 : 12),
                                Text(
                                  _isSubmitting
                                      ? 'جاري الرفع...'
                                      : 'رفع التكليف',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: isSmallScreen ? 16 : 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFormSection({
    required IconData icon,
    required String title,
    required bool isSmallScreen,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: _primaryColor, size: isSmallScreen ? 16 : 20),
            SizedBox(width: isSmallScreen ? 6 : 8),
            Text(
              title,
              style: TextStyle(
                color: _textColor,
                fontSize: isSmallScreen ? 14 : 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: isSmallScreen ? 8 : 12),
        ...children,
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isSmallScreen,
  }) {
    return TextField(
      controller: controller,
      style: TextStyle(color: _textColor, fontSize: isSmallScreen ? 14 : 16),
      decoration: InputDecoration(
        filled: true,
        fillColor: _backgroundColor,
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.grey,
          fontSize: isSmallScreen ? 14 : 16,
        ),
        prefixIcon: Icon(
          icon,
          color: _primaryColor,
          size: isSmallScreen ? 18 : 24,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 12 : 16,
          vertical: isSmallScreen ? 10 : 12,
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required List<String> items,
    required String hint,
    required IconData icon,
    required bool isSmallScreen,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          filled: true,
          fillColor: _backgroundColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 12 : 16,
            vertical: isSmallScreen ? 10 : 12,
          ),
          prefixIcon: Icon(
            icon,
            color: _primaryColor,
            size: isSmallScreen ? 18 : 24,
          ),
        ),
        value: value,
        style: TextStyle(color: _textColor, fontSize: isSmallScreen ? 14 : 16),
        dropdownColor: _cardColor,
        icon: Icon(
          Icons.arrow_drop_down,
          color: _primaryColor,
          size: isSmallScreen ? 20 : 24,
        ),
        items: items
            .map(
              (item) => DropdownMenuItem(
                value: item,
                child: Text(
                  item,
                  style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
                ),
              ),
            )
            .toList(),
        onChanged: (value) {
          setState(() {
            if (hint.contains('الفصل')) {
              _selectedClass = value;
            } else if (hint.contains('الشعبة')) {
              _selectedSection = value;
            } else if (hint.contains('المادة')) {
              _selectedSubject = value;
            }
          });
        },
        hint: Text(
          hint,
          style: TextStyle(
            color: Colors.grey,
            fontSize: isSmallScreen ? 14 : 16,
          ),
        ),
      ),
    );
  }

  Widget _buildDateField({
    required DateTime? date,
    required String label,
    required VoidCallback onTap,
    required bool isSmallScreen,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
        decoration: BoxDecoration(
          color: _backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              color: _primaryColor,
              size: isSmallScreen ? 16 : 20,
            ),
            SizedBox(width: isSmallScreen ? 8 : 12),
            Expanded(
              child: Text(
                date == null ? label : date.toLocal().toString().split(' ')[0],
                style: TextStyle(
                  color: date == null ? Colors.grey : _textColor,
                  fontSize: isSmallScreen ? 14 : 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
