import 'package:admin/responsive.dart';
import 'package:flutter/material.dart';
import '../../constants.dart';
import 'components/header.dart';
import 'components/storage_details.dart';
import 'components/my_files.dart';
import 'package:admin/sid/notification.blade.dart';
import 'package:admin/sid/setting.blade.dart';

class DashboardScreen extends StatelessWidget {
  final String role; // "teacher" أو "student"

  const DashboardScreen({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          primary: false,
          padding: const EdgeInsets.all(defaultPadding),
          child: Column(
            children: [
              const Header(),
              const SizedBox(height: defaultPadding),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 5,
                    child: Column(
                      children: [
                        // My Files Section
                        const MyFiles(),

                        // فاصل مع عنوان
                        _buildSectionDivider("الألبوم المدرسي"),

                        // Recent Files و Storage Details للموبايل
                        if (Responsive.isMobile(context))
                          Column(
                            children: [
                              const SchoolNews(),
                              const SizedBox(height: defaultPadding),
                            ],
                          ),
                      ],
                    ),
                  ),

                  if (!Responsive.isMobile(context))
                    const SizedBox(width: defaultPadding),

                  // School News Section for non-mobile
                  if (!Responsive.isMobile(context))
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          // فاصل عمودي أنيق
                          _buildVerticalDivider(),
                          const SizedBox(height: defaultPadding),

                          const SchoolNews(),
                        ],
                      ),
                    ),
                ],
              )
            ],
          ),
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  // شريط التنقل السفلي
  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
            spreadRadius: 2,
          ),
        ],
        border: Border.all(
          color: Color(0xFFD4C0A1).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // زر الانتقال إلى الشاشة الرئيسية
          _buildBottomNavItem(
            icon: Icons.home_rounded,
            label: "الرئيسية",
            isActive: true,
            onTap: () {
              _showFeedback(context);

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      DashboardScreen(role: role), // ✅ تمرير الدور
                ),
              );
            },
          ),

          // زر الاشعارات
          _buildBottomNavItem(
            icon: Icons.notifications_rounded,
            label: "الإشعارات",
            isActive: false,
            onTap: () {
              _showFeedback(context);

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      NotificationPage(role: role), // ✅ تمرير الدور
                ),
              );
            },
          ),

          // زر الواجبات
          _buildBottomNavItem(
            icon: Icons.assignment_rounded,
            label: "الواجبات",
            isActive: false,
            onTap: () {
              _showFeedback(context);
              // إضافة منطق الانتقال هنا إذا أردت
              // مثال:
              // Navigator.pushReplacement(
              //   context,
              //   MaterialPageRoute(builder: (context) => const HomeworkPage()),
              // );
            },
          ),

          // زر الإعدادات
          _buildBottomNavItem(
            icon: Icons.settings_rounded,
            label: "الإعدادات",
            isActive: false,
            onTap: () {
              _showFeedback(context);

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      SettingsPage(role: role), // ✅ تمرير الدور
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // عنصر زر في شريط التنقل
  Widget _buildBottomNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      splashColor: Color(0xFF5D4037).withOpacity(0.2),
      highlightColor: Color(0xFFD4C0A1).withOpacity(0.3),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive
              ? Color(0xFF5D4037).withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: isActive
              ? Border.all(
                  color: Color(0xFF5D4037).withOpacity(0.3),
                  width: 1,
                )
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isActive
                  ? Color(0xFF5D4037)
                  : Color(0xFF8B7355).withOpacity(0.7),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive
                    ? Color(0xFF5D4037)
                    : Color(0xFF8B7355).withOpacity(0.8),
                fontFamily: 'Tajawal',
              ),
            ),
          ],
        ),
      ),
    );
  }

  // تأثير الاهتزاز عند الضغط
  void _showFeedback(BuildContext context) {
    // تأثير اهتزاز بسيط
    _vibrate();

    // تأثير صوتي (اختياري)
    // يمكن إضافة صوت هنا إذا أردت

    // تأثير بصرية (تغيير لون مؤقت)
    _showVisualFeedback(context);
  }

  void _vibrate() {
    // يمكن استخدام HapticFeedback للاهتزاز
    // HapticFeedback.lightImpact();
  }

  void _showVisualFeedback(BuildContext context) {
    // يمكن إضافة تأثيرات بصرية إضافية هنا
  }

  // فاصل أفقي مع عنوان
  Widget _buildSectionDivider(String title) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: defaultPadding * 1.5),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Divider(
                  color: Color(0xFFD4C0A1).withOpacity(0.5),
                  thickness: 1,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  title,
                  style: TextStyle(
                    color: Color(0xFF5D4037),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Tajawal',
                  ),
                ),
              ),
              Expanded(
                child: Divider(
                  color: Color(0xFFD4C0A1).withOpacity(0.5),
                  thickness: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // فاصل عمودي
  Widget _buildVerticalDivider() {
    return Container(
      width: 1,
      height: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Color(0xFFD4C0A1).withOpacity(0.3),
            Color(0xFF8B7355).withOpacity(0.6),
            Color(0xFFD4C0A1).withOpacity(0.3),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}
