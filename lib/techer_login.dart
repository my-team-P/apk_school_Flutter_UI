import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:admin/screens/main/main_screen.dart';
import 'package:shared_preferences/shared_preferences.dart'; // لحفظ الـ token والـ role

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
        child: LoginPage_T(),
      ),
    );
  }
}

class LoginPage_T extends StatefulWidget {
  const LoginPage_T({super.key});

  @override
  State<LoginPage_T> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage_T> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _emailError;
  String? _passwordError;

  static const Color topBackgroundColor = Color.fromARGB(255, 246, 230, 204);

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    bool hasError = false;

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
        Uri.parse(
            'http://192.168.1.107:8000/api/login/teacher'), // رابط تسجيل الدخول للمعلم
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        // استخراج التوكن والدور مباشرة
        final token = jsonResponse['access_token'];
        final role = jsonResponse['role'];

        // حفظ التوكن والدور
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', token);
        await prefs.setString('role', role);

        // الانتقال للصفحة الرئيسية وتمرير الدور
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MainScreen(role: role),
          ),
        );
      } else {
        final errorResponse = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorResponse['message'] ?? 'خطأ في تسجيل الدخول'),
          ),
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
          ClipPath(
            clipper: TopClipper(),
            child: Container(
              height: size.height * 0.4,
              width: double.infinity,
              color: topBackgroundColor,
            ),
          ),
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
                  // زر تسجيل الدخول كمدير
                  TextButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AdminLoginDialog(),
                      );
                    },
                    child: Text(
                      "تسجيل الدخول كمدير",
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
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

// Dialog لتسجيل دخول المدير
class AdminLoginDialog extends StatefulWidget {
  const AdminLoginDialog({super.key});

  @override
  State<AdminLoginDialog> createState() => _AdminLoginDialogState();
}

class _AdminLoginDialogState extends State<AdminLoginDialog> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _emailError;
  String? _passwordError;

  Future<void> _loginAdmin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    bool hasError = false;
    if (email.isEmpty) {
      _emailError = "يرجى إدخال البريد الإلكتروني";
      hasError = true;
    }
    if (password.isEmpty) {
      _passwordError = "يرجى إدخال كلمة المرور";
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
        Uri.parse("http://192.168.1.107:8000/api/login/admin"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        final token = jsonResponse['access_token'];
        final role = jsonResponse['role'] ?? jsonResponse['user']?['role'];

        if (token == null || role == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('خطأ في استجابة السيرفر')),
          );
          return;
        }

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', token);
        await prefs.setString('role', role);

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => MainScreen(role: role),
          ),
          (route) => false,
        );
      } else {
        print('Unexpected response: ${response.body}');
        final errorResponse = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorResponse['message'] ?? "خطأ")),
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
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("تسجيل الدخول كمدير",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 15),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: "البريد الإلكتروني",
                errorText: _emailError,
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "كلمة المرور",
                errorText: _passwordError,
              ),
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _loginAdmin,
                    child: Text("تسجيل الدخول"),
                  ),
          ],
        ),
      ),
    );
  }
}
