import 'package:flutter/material.dart';
import 'package:admin/sid_2/S_sent.dart';
import 'package:admin/sid_2/T_sent.dart';

class UserTypeSelectionAppAdmin extends StatelessWidget {
  // final String role;
  const UserTypeSelectionAppAdmin({
    super.key,
    //  required this.role
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        fontFamily: 'Tajawal',
        useMaterial3: true,
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
  final TextEditingController _teacherPasswordController =
      TextEditingController();
  bool _isLoading = false;

  // نظام ألوان تعليمي
  static const Color _primaryColor = Color(0xFF2563EB);
  static const Color _secondaryColor = Color(0xFF7C3AED);
  static const Color _studentColor = Color(0xFF059669);
  static const Color _teacherColor = Color(0xFFDC2626);
  static const Color _accentColor = Color(0xFFF59E0B);
  static const Color _backgroundColor = Color(0xFFF8FAFC);
  static const Color _surfaceColor = Colors.white;

  void _selectUserType(String userType) {
    if (userType == 'student') {
      _navigateToStudentLogin();
    } else if (userType == 'teacher') {
      _navigateToTeacherLogin();
    }
  }

  void _navigateToStudentLogin() {
    setState(() {
      _isLoading = true;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _isLoading = false;
      });
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const SMSPage(
                  role: 'admin',
                )),
      );
    });
  }

  void _navigateToTeacherLogin() {
    setState(() {
      _isLoading = true;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _isLoading = false;
      });
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const TeacherPreparationPage(
                  role: 'admin',
                )),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Directionality(
        textDirection: TextDirection.rtl, // 👈 من اليمين إلى اليسار
        child: Scaffold(
          backgroundColor: _backgroundColor,
          body: Stack(
            children: [
              // خلفية تعليمية متدرجة
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFE0F2FE),
                      Color(0xFFF0FDF4),
                      _backgroundColor,
                    ],
                  ),
                ),
              ),

              // عناصر ديكورية تعليمية
              _buildEducationalElements(),

              // المحتوى الرئيسي
              SafeArea(
                child: Column(
                  children: [
                    // الهيدر
                    _buildHeader(size),

                    // البطاقات
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 32,
                        ),
                        child: Column(
                          children: [
                            _buildStudentCard(),
                            const SizedBox(height: 24),
                            _buildTeacherCard(),
                            const SizedBox(height: 32),
                            _buildWelcomeMessage(),
                          ],
                        ),
                      ),
                    ),
                  ],
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
        ));
  }

  Widget _buildHeader(Size size) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        children: [
          // شعار تعليمي
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
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
            child: const Icon(
              Icons.school_rounded,
              color: Colors.white,
              size: 40,
            ),
          ),

          const SizedBox(height: 20),

          // النصوص الترحيبية
          Column(
            children: [
              Text(
                'نظام التحضير الإلكتروني',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _primaryColor,
                  height: 1.3,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCard() {
    return _buildUserTypeCard(
      icon: Icons.school_rounded,
      title: 'طلاب',
      subtitle: 'تحضير الطلاب ',
      onTap: () => _selectUserType('student'),
      gradient: const [Color(0xFF059669), Color(0xFF10B981)],
      iconBackground: const Color(0xFFD1FAE5),
      badgeIcon: Icons.auto_awesome_rounded,
      badgeColor: Colors.white,
    );
  }

  Widget _buildTeacherCard() {
    return _buildUserTypeCard(
      icon: Icons.person_rounded,
      title: 'معلمين',
      subtitle: 'تحضير المعلمين',
      onTap: () => _selectUserType('teacher'),
      gradient: const [Color(0xFFDC2626), Color(0xFFEF4444)],
      iconBackground: const Color(0xFFFEE2E2),
      badgeIcon: Icons.verified_rounded,
      badgeColor: Colors.white,
    );
  }

  Widget _buildUserTypeCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required List<Color> gradient,
    required Color iconBackground,
    required IconData badgeIcon,
    required Color badgeColor,
  }) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradient[0].withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // المحتوى الرئيسي
              Container(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    // الأيقونة مع شارة
                    Stack(
                      children: [
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: iconBackground.withOpacity(0.95),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(icon, size: 32, color: gradient[0]),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: badgeColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: gradient[0], width: 2),
                            ),
                            child: Icon(
                              badgeIcon,
                              color: gradient[0],
                              size: 12,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(width: 16),

                    // النصوص
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.95),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),

                    // سهم التنقل
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),

              // زخرفة زاوية
              Positioned(
                top: 0,
                left: 0,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      bottomRight: Radius.circular(40),
                    ),
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeMessage() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(Icons.lightbulb_rounded, color: _accentColor, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مرحباً بك في منصة مدرستي بين يدي التعليمية',
                  style: TextStyle(
                    color: _primaryColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'نسعى لتوفير أفضل تجربة تعليمية تفاعلية للطلاب والمعلمين و اولياء الامور',
                  style: TextStyle(color: Colors.grey[700], fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEducationalElements() {
    return Stack(
      children: [
        // كتب مبعثرة
        Positioned(
          top: 50,
          left: 30,
          child: _buildBookIcon(Icons.menu_book_rounded, _studentColor),
        ),
        Positioned(
          top: 120,
          right: 40,
          child: _buildBookIcon(Icons.auto_stories_rounded, _teacherColor),
        ),

        // أقلام
        Positioned(bottom: 150, left: 50, child: _buildPenIcon()),

        // شكل هندسي تعليمي
        Positioned(
          bottom: 80,
          right: 30,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: _primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBookIcon(IconData icon, Color color) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }

  Widget _buildPenIcon() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: _accentColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(Icons.edit_rounded, color: _accentColor, size: 20),
    );
  }

  @override
  void dispose() {
    _teacherPasswordController.dispose();
    super.dispose();
  }
}
