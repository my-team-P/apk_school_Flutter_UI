import 'package:admin/res_pass.blade.dart';
import 'package:flutter/material.dart';

class SecurityCheckPage extends StatefulWidget {
  const SecurityCheckPage({super.key});

  @override
  State<SecurityCheckPage> createState() => _SecurityCheckPageState();
}

class _SecurityCheckPageState extends State<SecurityCheckPage> {
  final TextEditingController _answerController = TextEditingController();
  String? selectedQuestion;

  final List<String> securityQuestions = [
    "ما اسم أول حيوان أليف امتلكته؟",
    "ما اسم المدرسة الابتدائية؟",
    "ما هو لون سيارتك الأولى؟",
  ];

  void _verifyAnswer() {
    // منطق التحقق هنا، حالياً مجرد مثال
    if (_answerController.text.isEmpty || selectedQuestion == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("الرجاء اختيار السؤال وإدخال الإجابة")),
      );
      return;
    }

    // إذا تم التحقق بنجاح
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("تم التحقق بنجاح ✅")),
    );

    // الانتقال إلى صفحة إعادة تعيين كلمة المرور
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const ResetPasswordPage()),
    );
    // Navigator.push(context, MaterialPageRoute(builder: (_) => ResetPasswordPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf0f4ff),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 15,
                  offset: Offset(0, 8),
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // شعار أو أيقونة
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF667eea).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.security,
                    size: 48,
                    color: Color(0xFF667eea),
                  ),
                ),
                const SizedBox(height: 24),

                const Text(
                  "التحقق الأمني",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "الرجاء الإجابة على سؤال الأمان أو إجراء المصادقة الثنائية للتحقق من هويتك",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54, fontSize: 14),
                ),
                const SizedBox(height: 32),

                // قائمة الأسئلة
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: "اختر سؤال الأمان",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  value: selectedQuestion,
                  items: securityQuestions
                      .map((q) => DropdownMenuItem(value: q, child: Text(q)))
                      .toList(),
                  onChanged: (val) => setState(() => selectedQuestion = val),
                ),
                const SizedBox(height: 20),

                // حقل الإجابة
                TextField(
                  controller: _answerController,
                  decoration: InputDecoration(
                    labelText: "إجابة السؤال",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.lock_outline),
                  ),
                ),
                const SizedBox(height: 32),

                // زر التحقق
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _verifyAnswer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF667eea),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "تحقق من الهوية",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                TextButton(
                  onPressed: () {},
                  child: const Text(
                    "استخدام المصادقة الثنائية بدلاً من السؤال",
                    style: TextStyle(color: Color(0xFF667eea)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
