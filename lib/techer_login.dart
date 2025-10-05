import 'package:flutter/material.dart';
import 'package:admin/screens/main/main_screen.dart';
import 'package:admin/teacher_service.dart';

class TeacherLoginPage extends StatefulWidget {
  const TeacherLoginPage({super.key});

  @override
  State<TeacherLoginPage> createState() => _TeacherLoginPageState();
}

class _TeacherLoginPageState extends State<TeacherLoginPage> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;

  String? _usernameError;
  String? _emailError;
  String? _passwordError;

  static const Color topBackgroundColor = Color.fromARGB(255, 246, 230, 204);

  // دالة تسجيل الدخول
  Future<void> _login() async {
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    // إعادة تعيين رسائل الخطأ
    setState(() {
      _usernameError = null;
      _emailError = null;
      _passwordError = null;
    });

    bool hasError = false;

    if (username.isEmpty) {
      _usernameError = 'يرجى إدخال اسم المستخدم';
      hasError = true;
    }
    if (email.isEmpty) {
      _emailError = 'يرجى إدخال البريد الإلكتروني';
      hasError = true;
    } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      _emailError = 'صيغة البريد الإلكتروني غير صحيحة';
      hasError = true;
    }
    if (password.isEmpty) {
      _passwordError = 'يرجى إدخال كلمة المرور';
      hasError = true;
    }

    if (hasError) {
      setState(() {});
      return;
    }

    setState(() => _isLoading = true);

    // استخدام TeacherService لتسجيل الدخول
    final teacherService = TeacherService();
    bool success = await teacherService.loginTeacher(username, email, password);

    setState(() => _isLoading = false);

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('البريد أو كلمة المرور غير صحيحة')),
      );
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // خلفية عليا
          ClipPath(
            clipper: TopClipper(),
            child: Container(
              height: size.height * 0.4,
              width: double.infinity,
              color: topBackgroundColor,
            ),
          ),
          // محتوى الصفحة
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  Image.asset('assets/images/logo.png', height: 100),
                  const SizedBox(height: 24),
                  Text(
                    'مرحبا',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo[900],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'قم بتسجيل الدخول إلى حسابك',
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 32),

                  // اسم المستخدم
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.person_outline),
                      labelText: 'اسم المستخدم',
                      errorText: _usernameError,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // البريد الإلكتروني
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.email),
                      labelText: 'البريد الإلكتروني',
                      errorText: _emailError,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // كلمة المرور
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock),
                      labelText: 'كلمة المرور',
                      errorText: _passwordError,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // زر تسجيل الدخول أو مؤشر التحميل
                  _isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'تسجيل الدخول',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),

                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// كلاس لتصميم الجزء العلوي من الخلفية
class TopClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 60);
    path.quadraticBezierTo(
        size.width / 2, size.height, size.width, size.height - 60);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
