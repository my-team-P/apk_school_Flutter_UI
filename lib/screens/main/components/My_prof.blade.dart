import 'package:flutter/material.dart';
import 'package:admin/screens/main/main_screen.dart';
import 'package:admin/login.blade.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final Map<String, dynamic> _userData = {
    "name": "علي محمد أحمد",
    "email": "ali@school.edu.sa",
    "phone": "+966501234567",
    "role": "معلم",
    "subject": "الرياضيات",
    "grade": "الصف الثالث",
    "joinDate": "2023-09-01",
    "bio": "معلم رياضيات متخصص في تدريس المناهج الحديثة بخبرة 5 سنوات",
    "avatar": "assets/images/profile_pic.png",
  };

  bool _isEditing = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _nameController.text = _userData["name"];
    _emailController.text = _userData["email"];
    _phoneController.text = _userData["phone"];
    _bioController.text = _userData["bio"];
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        _saveChanges();
      }
    });
  }

  void _saveChanges() {
    setState(() {
      _userData["name"] = _nameController.text;
      _userData["email"] = _emailController.text;
      _userData["phone"] = _phoneController.text;
      _userData["bio"] = _bioController.text;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("تم حفظ التغييرات بنجاح ✅"),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("تسجيل الخروج"),
        content: Text("هل أنت متأكد من أنك تريد تسجيل الخروج؟"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("إلغاء"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _performLogout();
            },
            child: Text("تسجيل خروج", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _performLogout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginApp()),
    );
  }

  void _changePassword() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
              "تغيير كلمة المرور",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 15),
            TextFormField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: "كلمة المرور الحالية",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextFormField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: "كلمة المرور الجديدة",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextFormField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: "تأكيد كلمة المرور الجديدة",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("تم تغيير كلمة المرور بنجاح"),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                child: Text("تغيير كلمة المرور"),
              ),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          "الملف الشخصي",
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
              MaterialPageRoute(
                  builder: (context) =>
                      MainScreen(role: _userData["role"].toLowerCase())),
            );
          },
        ),
        actions: [
          IconButton(
            icon:
                Icon(_isEditing ? Icons.save : Icons.edit, color: Colors.white),
            onPressed: _toggleEdit,
            tooltip: _isEditing ? "حفظ التغييرات" : "تعديل الملف",
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            // بطاقة المعلومات الشخصية
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF667eea),
                    Color(0xFF764ba2),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 15,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: AssetImage(_userData["avatar"]),
                        ),
                        if (_isEditing)
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: Icon(Icons.camera_alt, size: 20),
                              onPressed: () {
                                // تغيير الصورة
                              },
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 15),
                    _isEditing
                        ? TextFormField(
                            controller: _nameController,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                          )
                        : Text(
                            _userData["name"],
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                    SizedBox(height: 5),
                    Text(
                      _userData["role"],
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    SizedBox(height: 10),
                    Chip(
                      label: Text(
                        _userData["subject"],
                        style: TextStyle(
                            color: const Color.fromARGB(255, 3, 38, 103)),
                      ),
                      backgroundColor: Colors.white.withOpacity(0.2),
                    ),
                  ],
                ),
              ),
            ),
            // باقي الصفحة بدون تغييرات
          ],
        ),
      ),
    );
  }
}
