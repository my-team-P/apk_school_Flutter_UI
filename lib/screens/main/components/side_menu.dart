import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// صفحات عامة
import 'package:admin/sid/library.blade.dart';
import 'package:admin/sid/notification.blade.dart';
import 'package:admin/sid/setting.blade.dart';
import 'package:admin/sid/store.blade.dart';
import 'package:admin/sid/student.blade.dart';
import 'package:admin/sid/translation.blade.dart';
import 'package:admin/sid/chat.blade.dart';
import 'package:admin/degree.dart';
import 'package:admin/show/deg.dart';
import 'package:admin/first_screen.dart';
import 'package:admin/add_teacher.dart';
import 'package:admin/show/show.dart';
import 'package:admin/show/lib.dart';
import 'package:admin/sid/exam.dart';

class SideMenu extends StatelessWidget {
  final String role; // "admin", "teacher", "student"

  const SideMenu({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    final isAdmin = role == 'admin';
    final isTeacher = role == 'teacher';
    final isStudent = role == 'student';

    return Drawer(
      elevation: 8,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF6E6CC),
              Color(0xFF6D5E3E),
              Color(0xFFCC8A0E),
              Color(0xFF605F5D),
            ],
          ),
        ),
        child: ListView(
          children: [
            _buildHeader(),
            const SizedBox(height: 10),

            // --- الصفحات العامة للجميع ---
            _buildMenuTile(
                context, "الإعدادات", Icons.settings, Color(0xFFf6d365), () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) => SettingsPage(role: role)));
            }),
            _buildMenuTile(
                context, "الحصص", Icons.notifications, Color(0xFFfdcbf1), () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (_) => NotificationPage(role: role)));
            }),
            _buildMenuTile(
                context, "الدردشة الذكية", Icons.chat, Color(0xFFa8edea), () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) => ChatPage(role: role)));
            }),
            _buildMenuTile(
                context, "الترجمة", Icons.translate, Color(0xFF43e97b), () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (_) => TranslationPage(role: role)));
            }),
            _buildMenuTile(
                context, "المكتبة", Icons.library_books, Color(0xFFfbc2eb), () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => LibraryPage(
                      role: role), //  استخدم الـ Widget وليس الـ State
                ),
              );
            }),
            _buildMenuTile(
                context, "معاينة الدرجات", Icons.show_chart, Color(0xFF121111),
                () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (_) => ViewGradesPage(role: role)));
            }),

            // --- الصفحات الخاصة بالمدير ---
            if (isAdmin) ...[
              const Divider(color: Colors.white54),
              _sectionTitle("صفحات المدير"),

              _buildMenuTile(context, " عرض المعلمين والطلاب", Icons.person,
                  Color(0xFF43e97b), () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) => PeoplePage(role: role)));
              }),
              _buildMenuTile(
                  context, "إضافة معلم", Icons.person_add, Color(0xFFff9a9e),
                  () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (_) => AddTeacherPage(role: role)));
              }),
              _buildMenuTile(context, "رفع الى المكتبة", Icons.library_books,
                  Color(0xFFfbc2eb), () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (_) => SimpleLibraryPage(role: role)));
              }),

              // _buildMenuTile(
              //     context, "إدارة المواد", Icons.book, Color(0xFFa18cd1), () {
              //   Navigator.pushReplacement(context,
              //       MaterialPageRoute(builder: (_) => ManageSubjectsPage()));
              // }),
              // _buildMenuTile(
              //     context, "إدارة الأقسام", Icons.class_, Color(0xFFfbc2eb),
              //     () {
              //   Navigator.pushReplacement(context,
              //       MaterialPageRoute(builder: (_) => ManageSectionsPage()));
              // }),
            ],

            // --- صفحات المعلم ---
            if (isTeacher || isAdmin) ...[
              const Divider(color: Colors.white54),
              _sectionTitle("صفحات المعلم"),
              _buildMenuTile(
                  context, "التحضير", Icons.people, Color(0xFF4facfe), () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (_) => StudentPreparationPage(role: role)));
              }),
              _buildMenuTile(
                  context, "إضافة درجات", Icons.add, Color(0xFFB0A7A7), () {
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (_) => AddGradePage()));
              }),
              _buildMenuTile(context, "رفع الى المكتبة", Icons.library_books,
                  Color(0xFFfbc2eb), () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (_) => SimpleLibraryPage(role: role)));
              }),
              _buildMenuTile(
                  context, "الاختبارات", Icons.store, Color(0xFFffd1ff), () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) => StorePage(role: role)));
              }),
              _buildMenuTile(
                  context, "رفع امتحان", Icons.library_books, Color(0xFFfbc2eb),
                  () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SimpleExamsPage(
                        role: role), //  استخدم الـ Widget وليس الـ State
                  ),
                );
              }),
            ],

            // --- صفحات الطالب ---
            if (isStudent || isAdmin) ...[
              const Divider(color: Colors.white54),
              _sectionTitle("صفحات الطالب"),
              _buildMenuTile(
                  context, "الاختبارات", Icons.store, Color(0xFFffd1ff), () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) => StorePage(role: role)));
              }),
            ],

            const Divider(color: Colors.white54),

            // --- تسجيل الخروج ---
            _buildMenuTile(
                context, "تسجيل الخروج", Icons.logout, Colors.redAccent,
                () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => UserTypeSelectionPage()),
                (route) => false,
              );
            }),

            const SizedBox(height: 20),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() => Container(
        height: 180,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CircleAvatar(
              radius: 40,
              backgroundImage: AssetImage("assets/images/logo.png"),
            ),
            SizedBox(height: 10),
            Text("المدرسة الذكية",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      );

  Widget _buildMenuTile(BuildContext context, String title, IconData icon,
      Color color, VoidCallback press) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        tileColor: color.withOpacity(0.15),
        leading: Icon(icon, color: Colors.white),
        title: Text(title,
            style: const TextStyle(color: Colors.white, fontSize: 16)),
        trailing:
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white70),
        onTap: press,
      ),
    );
  }

  Widget _sectionTitle(String title) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        child: Text(title,
            style: const TextStyle(
                color: Colors.white70, fontWeight: FontWeight.bold)),
      );

  Widget _buildFooter() => Center(
        child: Column(
          children: const [
            Text("الإصدار 1.0.0",
                style: TextStyle(color: Colors.white70, fontSize: 12)),
            Text("© جميع الحقوق محفوظة",
                style: TextStyle(color: Colors.white60, fontSize: 11)),
          ],
        ),
      );
}
