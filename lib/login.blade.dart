import 'package:flutter/material.dart';
import 'package:admin/screens/main/main_screen.dart';
import 'package:admin/ques_pass.blade.dart';
import 'dart:async';

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
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _showFirstCat = true;
  Timer? _typingTimer;

  static const Color topBackgroundColor = Color.fromARGB(255, 246, 230, 204);

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_handlePasswordTyping);
  }

  void _handlePasswordTyping() {
    if (_showFirstCat) {
      setState(() {
        _showFirstCat = false;
      });
    }

    _typingTimer?.cancel();

    _typingTimer = Timer(const Duration(seconds: 3), () {
      setState(() {
        _showFirstCat = true;
      });
    });
  }

  void _login() {
    final name = _emailController.text;
    final password = _passwordController.text;

    if (name == "alerwi" && password == "123") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("البيانات غير صحيحة")),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _typingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 🎨 خلفية مائلة في الأعلى
          ClipPath(
            clipper: TopClipper(),
            child: Container(
              height: size.height * 0.4,
              width: double.infinity,
              color: topBackgroundColor,
            ),
          ),

          // 🧾 محتوى الشاشة
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 60),

                  // 🖼 الشعار
                  Image.asset('assets/images/logo.png', height: 100),

                  const SizedBox(height: 24),

                  // 📝 نص الترحيب
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

                  // 📧 حقل اسم المستخدم
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.person),
                      labelText: 'أســــم الــمـــســتـخـدم',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 🔒 حقل كلمة المرور
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock),
                      labelText: 'كلمة المرور',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SecurityCheckPage()),
                        );
                        // تنفيذ عند نسيان كلمة المرور
                      },
                      child: const Text('نسيت كلمة المرور؟'),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 🔘 زر تسجيل الدخول
                  ElevatedButton(
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

          // 🐱 صورة القط في الأسفل
          Positioned(
            bottom: 20,
            left: MediaQuery.of(context).size.width / 2 - 40,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _showFirstCat
                  ? Image.asset(
                      'assets/images/as1.png',
                      key: const ValueKey('as1'),
                      height: 50,
                      width: 80,
                    )
                  : Image.asset(
                      'assets/images/as2.png',
                      key: const ValueKey('as2'),
                      height: 50,
                      width: 80,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// 🎨 ClipPath لعمل الجزء العلوي مائل
class TopClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    path.lineTo(0, size.height - 60);
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height - 60,
    );
    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
