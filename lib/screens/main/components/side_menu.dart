import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:admin/login.blade.dart';
import 'package:admin/screens/main/components/My_prof.blade.dart';
import 'package:admin/sid/library.blade.dart';
import 'package:admin/sid/notification.blade.dart';
import 'package:admin/sid/setting.blade.dart';
import 'package:admin/sid/store.blade.dart';
import 'package:admin/sid/student.blade.dart';
import 'package:admin/sid/translation.blade.dart';
import 'package:admin/sid/chat.blade.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      elevation: 10,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF6E6CC), // اللون الأساسي من الشعار
              Color.fromARGB(255, 109, 94, 62), // درجة أفتح قليلاً
              Color.fromARGB(255, 204, 138, 14), // درجة أغمق قليلاً
              Color.fromARGB(255, 96, 95, 93), // درجة كريمية دافئة
            ],
          ),
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
        child: ListView(
          children: [
            // Header مع تصميم جميل
            Container(
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0.2),
                    Colors.white.withOpacity(0.1),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // الصورة مع تأثير دائري
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.5),
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        "assets/images/logo.png",
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFFff7e5f),
                                  Color(0xFFfeb47b),
                                ],
                              ),
                            ),
                            child: Icon(
                              Icons.school,
                              color: Colors.white,
                              size: 40,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  Text(
                    "المدرسة الذكية",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          blurRadius: 10,
                          color: Colors.black.withOpacity(0.3),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "نظام الإدارة المدرسية",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            // قائمة العناصر
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
              child: Column(
                children: [
                  _buildMenuTile(
                    title: "الطلاب",
                    svgSrc: "assets/icons/menu_dashboard.svg",
                    icon: Icons.people,
                    color: Color(0xFF4facfe),
                    press: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const StudentPreparationPage()),
                      );
                    },
                  ),
                  _buildMenuTile(
                    title: "الترجمة",
                    svgSrc: "assets/icons/menu_tran.svg",
                    icon: Icons.translate,
                    color: Color(0xFF43e97b),
                    press: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const TranslationPage()),
                      );
                    },
                  ),
                  _buildMenuTile(
                    title: "تسجيل الدخول",
                    svgSrc: "assets/icons/menu_tran.svg",
                    icon: Icons.login,
                    color: Color(0xFFff6b6b),
                    press: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginApp()),
                      );
                    },
                  ),
                  _buildMenuTile(
                    title: "الدردشة الذكية",
                    svgSrc: "assets/icons/menu_task.svg",
                    icon: Icons.chat,
                    color: Color(0xFFa8edea),
                    press: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ChatPage()),
                      );
                    },
                  ),
                  _buildMenuTile(
                    title: "المكتبة",
                    svgSrc: "assets/icons/menu_doc.svg",
                    icon: Icons.library_books,
                    color: Color(0xFFfbc2eb),
                    press: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LibraryPage()),
                      );
                    },
                  ),
                  _buildMenuTile(
                    title: "الاختبارات",
                    svgSrc: "assets/icons/menu_store.svg",
                    icon: Icons.store,
                    color: Color(0xFFffd1ff),
                    press: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const StorePage()),
                      );
                    },
                  ),
                  _buildMenuTile(
                    title: "الإشعارات",
                    svgSrc: "assets/icons/menu_notification.svg",
                    icon: Icons.notifications,
                    color: Color(0xFFfdcbf1),
                    press: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const NotificationPage()),
                      );
                    },
                  ),
                  _buildMenuTile(
                    title: "الملف الشخصي",
                    svgSrc: "assets/icons/menu_profile.svg",
                    icon: Icons.person,
                    color: Color(0xFFa6c0fe),
                    press: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ProfilePage()),
                      );
                    },
                  ),
                  _buildMenuTile(
                    title: "الإعدادات",
                    svgSrc: "assets/icons/menu_setting.svg",
                    icon: Icons.settings,
                    color: Color(0xFFf6d365),
                    press: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SettingsPage()),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Footer
            Container(
              margin: EdgeInsets.all(20),
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  Text(
                    "الإصدار 1.0.0",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "جميع الحقوق محفوظة",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuTile({
    required String title,
    required String svgSrc,
    required IconData icon,
    required Color color,
    required VoidCallback press,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: press,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  color.withOpacity(0.3),
                  color.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // الأيقونة
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        color,
                        color.withOpacity(0.7),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 5,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 20,
                  ),
                ),

                SizedBox(width: 15),

                // النص
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                // السهم
                Icon(
                  Icons.arrow_left,
                  color: Colors.white.withOpacity(0.7),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// بديل إذا كنت تريد استخدام SVG بدلاً من الأيقونات
class DrawerListTile extends StatelessWidget {
  const DrawerListTile({
    super.key,
    required this.title,
    required this.svgSrc,
    required this.press,
    required this.color,
  });

  final String title, svgSrc;
  final VoidCallback press;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: press,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white.withOpacity(0.1),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withOpacity(0.2),
                  ),
                  child: SvgPicture.asset(
                    svgSrc,
                    colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                    height: 20,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                Spacer(),
                Icon(
                  Icons.chevron_left,
                  color: Colors.white.withOpacity(0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
