import 'package:admin/screens/main/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'teacher_service.dart'; // تأكد من أن الملف في المسار الصحيح

class AddTeacherPage extends StatefulWidget {
  final String role; // إضافة متغير role
  const AddTeacherPage({super.key, required this.role});

  @override
  AddTeacherPageState createState() => AddTeacherPageState();
}

class AddTeacherPageState extends State<AddTeacherPage> {
  final _formKey = GlobalKey<FormState>();
  late TeacherService _teacherService;
  late ImagePicker _picker;

  // متغيرات الحالة
  File? _selectedImage;
  String _fullName = '';
  String _specialization = '';
  String _password = '';
  String _phone = '';
  String _email = '';
  String _hireDate = '';
  String _salary = '';
  String _qualification = '';
  bool _isActive = true;

  // قوائم الاختيار
  final List<String> _specializations = [
    'الرياضيات',
    'العلوم',
    'اللغة العربية',
    'اللغة الإنجليزية',
    'التاريخ',
    'الجغرافيا',
    'الفيزياء',
    'الكيمياء',
    'التربية الإسلامية',
    'الحاسب الآلي'
  ];

  final List<String> _qualifications = [
    'بكالوريوس',
    'ماجستير',
    'دكتوراه',
    'دبلوم'
  ];

  @override
  void initState() {
    super.initState();
    _teacherService = TeacherService();
    _picker = ImagePicker();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'إضافة معلم جديد',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue[700],
        elevation: 0,
        leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => MainScreen(role: widget.role)),
              );
            }),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTeacherPhoto(),
              SizedBox(height: 24),
              _buildFullNameField(),
              SizedBox(height: 16),
              _buildSpecializationField(),
              SizedBox(height: 16),
              _buildQualificationField(),
              SizedBox(height: 16),
              _buildEmailField(),
              SizedBox(height: 16),
              _buildPasswordField(),
              SizedBox(height: 16),
              _buildPhoneField(),
              SizedBox(height: 16),
              _buildHireDateField(),
              SizedBox(height: 16),
              _buildSalaryField(),
              SizedBox(height: 16),
              _buildActiveSwitch(),
              SizedBox(height: 32),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  // بقيّة الدوال تبقى كما هي مع تعديل navigator لاستخدام widget.role

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[700],
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text('حفظ بيانات المعلم',
            style: TextStyle(fontSize: 18, color: Colors.white)),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      _showLoadingDialog();

      try {
        Map<String, dynamic> teacherData = {
          'full_name': _fullName,
          'specialization': _specialization,
          'password': _password,
          'phone': _phone.isEmpty ? null : _phone,
          'email': _email,
          'hire_date': _hireDate.isEmpty ? null : _hireDate,
          'salary': _salary.isEmpty ? null : _salary,
          'qualification': _qualification.isEmpty ? null : _qualification,
          'is_active': _isActive ? 1 : 0,
        };

        bool success =
            await _teacherService.addTeacher(teacherData, _selectedImage);

        Navigator.pop(context);

        success
            ? _showSuccessDialog()
            : _showErrorDialog('فشل في إضافة المعلم. يرجى المحاولة مرة أخرى.');
      } catch (e) {
        Navigator.pop(context);
        _showErrorDialog('حدث خطأ: $e');
      }
    }
  }

  void _showSuccessDialog() => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text('تمت العملية', style: TextStyle(color: Colors.green)),
            ],
          ),
          content: Text('تم إضافة المعلم بنجاح'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MainScreen(role: widget.role)),
                );
              },
              child: Text('موافق', style: TextStyle(color: Colors.blue[700])),
            ),
          ],
        ),
      );

  void _showErrorDialog(String message) => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.error, color: Colors.red),
              SizedBox(width: 8),
              Text('خطأ', style: TextStyle(color: Colors.red)),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('موافق', style: TextStyle(color: Colors.blue[700])),
            ),
          ],
        ),
      );

  // باقي الدوال مثل _pickImage, _selectDate تبقى كما هي

  Widget _buildPasswordField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'كلمة المرور *',
        prefixIcon: Icon(Icons.lock, color: Colors.blue[700]),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue[700]!),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      obscureText: true,
      onSaved: (value) => _password = value ?? '',
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'يرجى إدخال كلمة المرور';
        }
        if (value.length < 6) {
          return 'كلمة المرور يجب أن تكون على الأقل 6 أحرف';
        }
        return null;
      },
    );
  }

  Widget _buildTeacherPhoto() {
    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.grey[300],
              backgroundImage:
                  _selectedImage != null ? FileImage(_selectedImage!) : null,
              child: _selectedImage == null
                  ? Icon(Icons.person, size: 50, color: Colors.grey[600])
                  : null,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue[700],
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(Icons.camera_alt, color: Colors.white, size: 20),
                  onPressed: _pickImage,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Text(
          'صورة المعلم',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildFullNameField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'الاسم الكامل *',
        prefixIcon: Icon(Icons.person, color: Colors.blue[700]),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
      onSaved: (value) => _fullName = value!,
      validator: (value) =>
          value == null || value.isEmpty ? 'يرجى إدخال الاسم الكامل' : null,
    );
  }

  Widget _buildSpecializationField() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'التخصص *',
        prefixIcon: Icon(Icons.school, color: Colors.blue[700]),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
      items: _specializations
          .map((String value) =>
              DropdownMenuItem<String>(value: value, child: Text(value)))
          .toList(),
      onChanged: (value) => setState(() => _specialization = value!),
      validator: (value) =>
          value == null || value.isEmpty ? 'يرجى اختيار التخصص' : null,
    );
  }

  Widget _buildQualificationField() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'المؤهل العلمي',
        prefixIcon: Icon(Icons.workspace_premium, color: Colors.blue[700]),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
      items: _qualifications
          .map((String value) =>
              DropdownMenuItem<String>(value: value, child: Text(value)))
          .toList(),
      onChanged: (value) => setState(() => _qualification = value!),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'البريد الإلكتروني *',
        prefixIcon: Icon(Icons.email, color: Colors.blue[700]),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
      keyboardType: TextInputType.emailAddress,
      onSaved: (value) => _email = value ?? '',
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'يرجى إدخال البريد الإلكتروني';
        }
        if (!value.contains('@')) {
          return 'يرجى إدخال بريد إلكتروني صحيح';
        }
        return null;
      },
    );
  }

  Widget _buildPhoneField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'رقم الهاتف (اختياري)',
        prefixIcon: Icon(Icons.phone, color: Colors.blue[700]),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
      keyboardType: TextInputType.phone,
      onSaved: (value) => _phone = value ?? '',
    );
  }

  Widget _buildHireDateField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'تاريخ التعيين (اختياري)',
        prefixIcon: Icon(Icons.calendar_today, color: Colors.blue[700]),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
      readOnly: true,
      onTap: _selectDate,
      controller: TextEditingController(text: _hireDate),
    );
  }

  Widget _buildSalaryField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'الراتب (اختياري)',
        prefixIcon: Icon(Icons.attach_money, color: Colors.blue[700]),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
      keyboardType: TextInputType.number,
      onSaved: (value) => _salary = value ?? '',
    );
  }

  Widget _buildActiveSwitch() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.blue[700]),
            SizedBox(width: 12),
            Text('المعلم نشط',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            Spacer(),
            Switch(
              value: _isActive,
              onChanged: (value) => setState(() => _isActive = value),
              activeColor: Colors.blue[700],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) setState(() => _selectedImage = File(image.path));
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _hireDate =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  void _showLoadingDialog() => showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Colors.blue[700]),
                SizedBox(width: 20),
                Text('جاري حفظ البيانات...'),
              ],
            ),
          ),
        ),
      );
}
