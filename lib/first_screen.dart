import 'package:flutter/material.dart';
import 'package:admin/login.blade.dart';
import 'package:admin/techer_login.dart';

class UserTypeSelectionApp extends StatelessWidget {
  const UserTypeSelectionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'اختيار نوع المستخدم',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        fontFamily: 'Roboto',
      ),
      home: const Directionality(
        textDirection: TextDirection.rtl,
        child: UserTypeSelectionPage(),
      ),
    );
  }
}

class UserTypeSelectionPage extends StatefulWidget {
  const UserTypeSelectionPage({super.key});

  @override
  State<UserTypeSelectionPage> createState() => _UserTypeSelectionPageState();
}

class _UserTypeSelectionPageState extends State<UserTypeSelectionPage> {
  //لقراءة/تعديل النص المدخل
  final TextEditingController _teacherPasswordController = TextEditingController();
  //عرض/إخفاء حقل كلمة المرور
  bool _showPasswordField = false;
  //عرض مؤشر تحميل بدل الزر
  bool _isLoading = false;

  static const Color topBackgroundColor = Color.fromARGB(255, 246, 230, 204);
  static const String teacherPassword = 'A+123456';

  void _selectUserType(String userType) {
    if (userType == 'student') {
      // الانتقال مباشرة إلى صفحة تسجيل الدخول للطالب
      _navigateToStudentLogin();
    } else if (userType == 'teacher') {
      // طلب كلمة مرور المعلم
      setState(() {
        _showPasswordField = true;
      });
    }
  }

//يتحقق من كلمة المرور
  void _verifyTeacherPassword() {
    final enteredPassword = _teacherPasswordController.text.trim();
    
    if (enteredPassword.isEmpty) {
      _showErrorDialog('يرجى إدخال كلمة المرور');
      return;
    }

    if (enteredPassword == teacherPassword) {
      // كلمة المرور صحيحة - الانتقال إلى صفحة تسجيل الدخول للمعلم
      _navigateToTeacherLogin();
    } else {
      _showErrorDialog('كلمة المرور غير صحيحة');
    }
  }

//الانتقال الى صفحة الطالب
  void _navigateToStudentLogin() {
    setState(() {
      _isLoading = true;
    });

    // محاكاة عملية تحميل
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _isLoading = false;
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage_S()),
      );
    });
  }
//الانتقال الى صفحة الطالب
  void _navigateToTeacherLogin() {
    setState(() {
      _isLoading = true;
    });

    // محاكاة عملية تحميل
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _isLoading = false;
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage_T()),
      );
    });
  }
//خطا في كلمة المرور
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('خطأ'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }
//تنظيف حقل الادخال
  void _resetSelection() {
    setState(() {
      _showPasswordField = false;
      _teacherPasswordController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // خلفية عليا بنفس التصميم
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),

                  // الشعار الكبير جداً
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.indigo[50],
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.indigo.withOpacity(0.3),
                        width: 4,
                      ),
                    ),
                    child: Image(image: AssetImage('assets/images/logo.png'))
                   
                  ),

                  const SizedBox(height: 40),

                  // العنوان الرئيسي
                  Text(
                    'مرحباً في نظام المدرسة',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo[900],
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 8),

                  // النص التوضيحي
                  Text(
                    'اختر نوع حسابك للمتابعة',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),

                  const SizedBox(height: 40),

                  if (!_showPasswordField) ...[
                    // خيارات نوع المستخدم
                    _buildUserTypeCard(
                      icon: Icons.school,
                      title: 'طالب',
                      subtitle: 'الدخول إلى حساب الطالب',
                      onTap: () => _selectUserType('student'),
                      color: Colors.green,
                    ),

                    const SizedBox(height: 20),

                    _buildUserTypeCard(
                      icon: Icons.person,
                      title: 'معلم',
                      subtitle: 'الدخول إلى حساب المعلم',
                      onTap: () => _selectUserType('teacher'),
                      color: Colors.orange,
                    ),
                  ],

                  if (_showPasswordField) ...[
                    // حقل كلمة مرور المعلم
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Icon(
                              Icons.security,
                              size: 60,
                              color: Colors.orange[800],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'كلمة مرور المعلم',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.indigo[900],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'يرجى إدخال كلمة المرور للمتابعة',
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            TextField(
                              controller: _teacherPasswordController,
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
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: _resetSelection,
                                    style: OutlinedButton.styleFrom(
                                      minimumSize: const Size(0, 50),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text('رجوع'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: _verifyTeacherPassword,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange,
                                      minimumSize: const Size(0, 50),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text(
                                      'متابعة',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),

          // مؤشر التحميل
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUserTypeCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(24),
          width: double.infinity,
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 30,
                  color: color,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo[900],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[400],
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _teacherPasswordController.dispose();
    super.dispose();
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