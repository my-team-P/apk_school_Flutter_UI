import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:file_picker/file_picker.dart';

class TeacherLeaveRequestPage extends StatefulWidget {
  final String role;
  const TeacherLeaveRequestPage({super.key, required this.role});
  @override
  _TeacherLeaveRequestPageState createState() =>
      _TeacherLeaveRequestPageState();
}

class _TeacherLeaveRequestPageState extends State<TeacherLeaveRequestPage> {
  final TextEditingController _detailsController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  DateTime? _selectedDate;
  File? _selectedFile;
  String? _selectedReason;
  bool _isSubmitting = false;

  // ألوان متدرجة جميلة
  final Color _primaryColor = const Color(0xFF4361EE);
  final Color _secondaryColor = const Color(0xFF3A0CA3);
  final Color _accentColor = const Color(0xFF4CC9F0);
  final Color _successColor = const Color(0xFF4CAF50);
  final Color _backgroundColor = const Color(0xFFF8F9FA);
  final Color _cardColor = Colors.white;
  final Color _textColor = const Color(0xFF2B2D42);

  // قائمة الأسباب الجاهزة
  final List<String> _reasons = ['مرض', 'ظرف عائلي', 'مهمة رسمية', 'أخرى'];

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
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
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
      );
      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
        });
        _showSnackBar('تم اختيار الملف بنجاح', _successColor);
      }
    } catch (e) {
      _showSnackBar('حدث خطأ أثناء اختيار الملف', Colors.red);
      print('FilePicker error: $e');
    }
  }

  Future<void> _submitRequest() async {
    if (_selectedReason == null || _selectedDate == null) {
      _showSnackBar('يرجى اختيار السبب والتاريخ', Colors.orange);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://192.168.1.101:8000/api/absence-request'),
      );

      // بيانات الطلب
      request.fields['name'] = _nameController.text;
      request.fields['date'] = _selectedDate!.toIso8601String();
      request.fields['reason'] = _selectedReason!;
      request.fields['details'] = _detailsController.text;

      if (_selectedFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath('attachment', _selectedFile!.path),
        );
      }

      var response = await request.send();

      if (response.statusCode == 200) {
        _showSnackBar('تم إرسال الطلب بنجاح', _successColor);
        _resetForm();
      } else {
        _showSnackBar('فشل في إرسال الطلب', Colors.red);
      }
    } catch (e) {
      _showSnackBar('حدث خطأ أثناء الإرسال', Colors.red);
      print('Error: $e');
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  void _resetForm() {
    _detailsController.clear();
    setState(() {
      _selectedDate = null;
      _selectedFile = null;
      _selectedReason = null;
    });
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _backgroundColor,
        appBar: AppBar(
          title: const Text(
            'طلب إذن غياب',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
          ),
          centerTitle: true,
          backgroundColor: _primaryColor,
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // بطاقة الترحيب
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                margin: const EdgeInsets.only(bottom: 24),
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
                      Icons.person_search_outlined,
                      color: Colors.white,
                      size: 40,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'طلب إذن غياب',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'يرجى تعبئة البيانات أدناه لإرسال طلب الإذن',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),

              // نموذج الطلب
              Container(
                padding: const EdgeInsets.all(24),
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
                    // حقل الاسم
                    _buildFormSection(
                      icon: Icons.person,
                      title: 'الاسم الكامل',
                      child: TextField(
                        controller: _nameController,
                        style: TextStyle(color: _textColor, fontSize: 16),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: _backgroundColor,
                          hintText: 'اكتب اسمك الكامل هنا...',
                          hintStyle: TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.all(16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // اختيار التاريخ
                    _buildFormSection(
                      icon: Icons.calendar_today_rounded,
                      title: 'تاريخ الغياب',
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _backgroundColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _selectedDate == null
                                  ? 'اختر تاريخ الغياب'
                                  : _selectedDate!
                                      .toLocal()
                                      .toString()
                                      .split(' ')[0],
                              style: TextStyle(
                                color: _selectedDate == null
                                    ? Colors.grey
                                    : _textColor,
                                fontSize: 16,
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.calendar_month,
                                color: _primaryColor,
                                size: 24,
                              ),
                              onPressed: _pickDate,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // اختيار السبب
                    _buildFormSection(
                      icon: Icons.assignment_outlined,
                      title: 'سبب الغياب',
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: _backgroundColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        value: _selectedReason,
                        style: TextStyle(color: _textColor, fontSize: 16),
                        dropdownColor: _cardColor,
                        icon: Icon(Icons.arrow_drop_down, color: _primaryColor),
                        items: _reasons
                            .map(
                              (reason) => DropdownMenuItem(
                                value: reason,
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.circle,
                                      color: _primaryColor,
                                      size: 8,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      reason,
                                      style: TextStyle(
                                        color: _textColor,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedReason = value;
                          });
                        },
                        hint: Text(
                          'اختر سبب الغياب',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // التفاصيل الإضافية
                    _buildFormSection(
                      icon: Icons.description_outlined,
                      title: 'تفاصيل إضافية',
                      child: TextField(
                        controller: _detailsController,
                        maxLines: 4,
                        style: TextStyle(color: _textColor, fontSize: 16),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: _backgroundColor,
                          hintText: 'اكتب تفاصيل إضافية حول سبب الغياب...',
                          hintStyle: TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.all(16),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // إرفاق ملف
                    _buildFormSection(
                      icon: Icons.attach_file_outlined,
                      title: 'مرفق (اختياري)',
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: _backgroundColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.insert_drive_file_outlined,
                                  color: _primaryColor,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _selectedFile == null
                                        ? 'لم يتم اختيار ملف'
                                        : _selectedFile!.path.split('/').last,
                                    style: TextStyle(
                                      color: _selectedFile == null
                                          ? Colors.grey
                                          : _textColor,
                                      fontSize: 14,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                ElevatedButton(
                                  onPressed: _pickFile,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _primaryColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                  ),
                                  child: const Text(
                                    'اختر ملف',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (_selectedFile != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              'تم اختيار الملف بنجاح',
                              style: TextStyle(
                                color: _successColor,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // زر الإرسال
                    Container(
                      width: double.infinity,
                      height: 56,
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
                        onPressed: _isSubmitting ? null : _submitRequest,
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
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation(
                                    Colors.white,
                                  ),
                                ),
                              )
                            else
                              Icon(Icons.send_rounded, color: Colors.white),
                            const SizedBox(width: 12),
                            Text(
                              _isSubmitting ? 'جاري الإرسال...' : 'إرسال الطلب',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
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
        ),
      ),
    );
  }

  Widget _buildFormSection({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: _primaryColor, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: _textColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}
