import 'package:flutter/material.dart';
import 'package:admin/login.blade.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // الخلفية المتدرجة
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // الجسم
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // أيقونة جذابة
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock_reset,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "إعادة تعيين كلمة المرور",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "قم بإنشاء كلمة مرور جديدة لحسابك.",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // النموذج
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // كلمة المرور الجديدة
                        _buildPasswordField(
                          controller: _passwordController,
                          label: "كلمة المرور الجديدة",
                          obscureText: _obscurePassword,
                          toggleObscure: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        // تأكيد كلمة المرور
                        _buildPasswordField(
                          controller: _confirmController,
                          label: "تأكيد كلمة المرور",
                          obscureText: _obscureConfirm,
                          toggleObscure: () {
                            setState(() {
                              _obscureConfirm = !_obscureConfirm;
                            });
                          },
                        ),
                        const SizedBox(height: 32),
                        // زر الإرسال
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF667eea),
                            elevation: 5,
                          ),
                          onPressed: _submit,
                          child: const Text(
                            "إعادة التعيين",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // رابط العودة
                        //   TextButton(
                        //     onPressed: () {},
                        //    child: const Text(
                        //      "العودة لتسجيل الدخول",
                        //      style: TextStyle(color: Colors.white70),
                        //    ),
                        //  ),
                      ],
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

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required VoidCallback toggleObscure,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withOpacity(0.15),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          border: InputBorder.none,
          prefixIcon: const Icon(Icons.lock, color: Colors.white70),
          suffixIcon: IconButton(
            icon: Icon(
              obscureText ? Icons.visibility_off : Icons.visibility,
              color: Colors.white70,
            ),
            onPressed: toggleObscure,
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "الرجاء إدخال كلمة المرور";
          }
          if (value.length < 6) {
            return "يجب أن تكون كلمة المرور 6 أحرف على الأقل";
          }
          if (controller == _confirmController &&
              value != _passwordController.text) {
            return "كلمة المرور غير متطابقة";
          }
          return null;
        },
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("تم إعادة تعيين كلمة المرور بنجاح ✅")),
      );
      //Navigator.pop(context); // العودة لتسجيل الدخول
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginApp()),
      );
    }
  }
}
