import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:admin/screens/main/main_screen.dart';
import 'package:admin/ques_pass.blade.dart';
import 'package:admin/RegisterPage.dart';

class LoginApp extends StatelessWidget {
  const LoginApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login Page',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.indigo, fontFamily: 'Roboto'),
      home: const Directionality(
        textDirection: TextDirection.rtl,
        child: LoginPage(),
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;

  String? _usernameError;
  String? _emailError;
  String? _passwordError;

  static const Color topBackgroundColor = Color.fromARGB(255, 246, 230, 204);

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

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.102:8000/api/login'), // عدل حسب سيرفرك
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': username,
          'email': email,
          'password': password,
        }),
      );

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          // نجاح تسجيل الدخول → الانتقال للصفحة الرئيسية
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainScreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text(data['message'] ?? 'البريد أو كلمة المرور غير صحيحة')),
          );
        }
      } else {
        final error = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error['error'] ?? 'خطأ في تسجيل الدخول')),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر الاتصال بالسيرفر')),
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

                  // روابط نسيت كلمة المرور وإنشاء حساب
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const SecurityCheckPage()),
                          );
                        },
                        child: const Text('نسيت كلمة المرور؟'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const RegisterPage()),
                          );
                        },
                        child: const Text("انشاء حساب"),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

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
