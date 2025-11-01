import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:file_picker/file_picker.dart';

class ParentComplaintPage extends StatefulWidget {
  
  final String role;
  const ParentComplaintPage({super.key, required this.role});


  @override
  _ParentComplaintPageState createState() => _ParentComplaintPageState();
}

class _ParentComplaintPageState extends State<ParentComplaintPage> {
  final TextEditingController _studentNameController = TextEditingController();
  final TextEditingController _studentIdController = TextEditingController();
  final TextEditingController _complaintController = TextEditingController();
  final TextEditingController _parentNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  
  File? _selectedFile;
  String? _selectedComplaintType;
  String? _selectedPriority;
  bool _isSubmitting = false;

  // ألوان متدرجة جميلة
  final Color _primaryColor = const Color(0xFF4361EE);
  final Color _secondaryColor = const Color(0xFF3A0CA3);
  final Color _accentColor = const Color(0xFF4CC9F0);
  final Color _successColor = const Color(0xFF4CAF50);
  final Color _warningColor = const Color(0xFFFF9800);
  final Color _errorColor = const Color(0xFFF44336);
  final Color _backgroundColor = const Color(0xFFF8F9FA);
  final Color _cardColor = Colors.white;
  final Color _textColor = const Color(0xFF2B2D42);

  // قائمة أنواع الشكاوى
  final List<String> _complaintTypes = [
    'مشكلة دراسية',
    'مشكلة سلوكية',
    'مشكلة مع المعلم',
    'مشكلة مع الطلاب',
    'مشكلة في المواصلات',
    'مشكلة صحية',
    'اقتراح',
    'شكوى أخرى'
  ];

  // قائمة أولويات الشكوى
  final List<String> _priorities = [
    'عادية',
    'متوسطة',
    'عاجلة'
  ];

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
      _showSnackBar('حدث خطأ أثناء اختيار الملف', _errorColor);
      print('FilePicker error: $e');
    }
  }

  Future<void> _submitComplaint() async {
    // التحقق من الحقول المطلوبة
    if (_studentNameController.text.isEmpty ||
        _studentIdController.text.isEmpty ||
        _complaintController.text.isEmpty ||
        _parentNameController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _selectedComplaintType == null) {
      _showSnackBar('يرجى ملء جميع الحقول المطلوبة', _warningColor);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://192.168.1.101:8000/api/parent-complaint'),
      );

      // بيانات الشكوى
      request.fields['student_name'] = _studentNameController.text;
      request.fields['student_id'] = _studentIdController.text;
      request.fields['complaint_type'] = _selectedComplaintType!;
      request.fields['complaint_text'] = _complaintController.text;
      request.fields['parent_name'] = _parentNameController.text;
      request.fields['phone'] = _phoneController.text;
      request.fields['priority'] = _selectedPriority ?? 'عادية';
      request.fields['submission_date'] = DateTime.now().toIso8601String();

      if (_selectedFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath('attachment', _selectedFile!.path),
        );
      }

      var response = await request.send();

      if (response.statusCode == 200) {
        _showSnackBar('تم إرسال الشكوى بنجاح', _successColor);
        _resetForm();
      } else {
        _showSnackBar('فشل في إرسال الشكوى', _errorColor);
      }
    } catch (e) {
      _showSnackBar('حدث خطأ أثناء الإرسال', _errorColor);
      print('Error: $e');
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  void _resetForm() {
    _studentNameController.clear();
    _studentIdController.clear();
    _complaintController.clear();
    _parentNameController.clear();
    _phoneController.clear();
    setState(() {
      _selectedFile = null;
      _selectedComplaintType = null;
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

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'عاجلة':
        return _errorColor;
      case 'متوسطة':
        return _warningColor;
      case 'عادية':
        return _successColor;
      default:
        return _primaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _backgroundColor,
        appBar: AppBar(
          title: const Text(
            'شكوى أولياء الأمور',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
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
                      Icons.contact_support_outlined,
                      color: Colors.white,
                      size: 40,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'نظام شكاوى أولياء الأمور',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'نرحب بملاحظاتكم ومقترحاتكم لتحسين تجربة أبنائنا التعليمية',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),

              // نموذج الشكوى
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
                    // معلومات الطالب
                    _buildFormSection(
                      icon: Icons.school_outlined,
                      title: 'معلومات الطالب',
                      children: [
                        _buildTextField(
                          controller: _studentNameController,
                          label: 'اسم الطالب *',
                          icon: Icons.person_outline,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _studentIdController,
                          label: 'رقم هوية الطالب *',
                          icon: Icons.badge_outlined,
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // معلومات ولي الأمر
                    _buildFormSection(
                      icon: Icons.family_restroom_outlined,
                      title: 'معلومات ولي الأمر',
                      children: [
                        _buildTextField(
                          controller: _parentNameController,
                          label: 'اسم ولي الأمر *',
                          icon: Icons.person_outlined,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _phoneController,
                          label: 'رقم الهاتف *',
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // نوع الشكوى
                    _buildFormSection(
                      icon: Icons.category_outlined,
                      title: 'نوع الشكوى',
                      children: [
                        DropdownButtonFormField<String>(
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
                            hintText: 'اختر نوع الشكوى *',
                          ),
                          value: _selectedComplaintType,
                          style: TextStyle(
                            color: _textColor,
                            fontSize: 16,
                          ),
                          dropdownColor: _cardColor,
                          icon: Icon(Icons.arrow_drop_down, color: _primaryColor),
                          items: _complaintTypes
                              .map(
                                (type) => DropdownMenuItem(
                                  value: type,
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.circle,
                                        color: _primaryColor,
                                        size: 8,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        type,
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
                              _selectedComplaintType = value;
                            });
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // أولوية الشكوى
                    _buildFormSection(
                      icon: Icons.flag_outlined,
                      title: 'أولوية الشكوى',
                      children: [
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: _priorities.map((priority) {
                            final isSelected = _selectedPriority == priority;
                            return ChoiceChip(
                              label: Text(
                                priority,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : _textColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedPriority = selected ? priority : null;
                                });
                              },
                              backgroundColor: _backgroundColor,
                              selectedColor: _getPriorityColor(priority),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // تفاصيل الشكوى
                    _buildFormSection(
                      icon: Icons.description_outlined,
                      title: 'تفاصيل الشكوى',
                      children: [
                        TextField(
                          controller: _complaintController,
                          maxLines: 5,
                          style: TextStyle(color: _textColor, fontSize: 16),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: _backgroundColor,
                            hintText: 'يرجى كتابة تفاصيل الشكوى أو الاقتراح هنا... *',
                            hintStyle: TextStyle(color: Colors.grey),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.all(16),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // إرفاق ملف
                    _buildFormSection(
                      icon: Icons.attach_file_outlined,
                      title: 'مرفق (اختياري)',
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
                        onPressed: _isSubmitting ? null : _submitComplaint,
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
                                  valueColor:
                                      AlwaysStoppedAnimation(Colors.white),
                                ),
                              )
                            else
                              Icon(
                                Icons.send_and_archive_rounded,
                                color: Colors.white,
                              ),
                            const SizedBox(width: 12),
                            Text(
                              _isSubmitting ? 'جاري الإرسال...' : 'إرسال الشكوى',
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
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: _primaryColor,
              size: 20,
            ),
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
        ...children,
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      style: TextStyle(color: _textColor, fontSize: 16),
      keyboardType: keyboardType,
      decoration: InputDecoration(
        filled: true,
        fillColor: _backgroundColor,
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey),
        prefixIcon: Icon(icon, color: _primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}