import 'package:admin/controllers/menu_app_controller.dart';
import 'package:admin/responsive.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Header extends StatelessWidget {
  const Header({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color.fromARGB(87, 255, 255, 255),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF8B7355).withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (!Responsive.isDesktop(context))
            Container(
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Color(0xFFF6E6CC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Color(0xFFD4C0A1)),
              ),
              child: IconButton(
                icon: Icon(Icons.menu, color: Color(0xFF5D4037)),
                onPressed: context.read<MenuAppController>().controlMenu,
              ),
            ),
          if (!Responsive.isMobile(context))
            Row(
              children: [
                Icon(Icons.school, color: Color(0xFF8B7355), size: 28),
                const SizedBox(width: 8),
                Text(
                  "لوحة التحكم المدرسية",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5D4037),
                    fontFamily: 'Tajawal',
                  ),
                ),
              ],
            ),
          if (!Responsive.isMobile(context))
            Spacer(flex: Responsive.isDesktop(context) ? 2 : 1),
          const Expanded(child: SearchField()),
          const SizedBox(width: 12),
          const ProfileCard()
        ],
      ),
    );
  }
}

class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      offset: Offset(0, 50),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      onSelected: (value) {
        // يمكنك حفظ المستخدم المختار في Provider أو State Management
      },
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          value: 'أحمد محمد',
          child: _buildUserItem(
              'أحمد محمد', 'مدير المدرسة', 'assets/images/profile_pic.png'),
        ),
        PopupMenuItem<String>(
          value: 'فاطمة عبدالله',
          child: _buildUserItem(
              'فاطمة عبدالله', 'نائب المدير', 'assets/images/profile_pic2.png'),
        ),
        PopupMenuItem<String>(
          value: 'خالد إبراهيم',
          child: _buildUserItem(
              'خالد إبراهيم', 'مرشد طلابي', 'assets/images/profile_pic3.png'),
        ),
        PopupMenuItem<String>(
          value: 'سارة أحمد',
          child: _buildUserItem(
              'سارة أحمد', 'معلمة', 'assets/images/profile_pic4.png'),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF6E6CC),
              Color(0xFFF8F0E5),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Color(0xFFD4C0A1).withOpacity(0.8),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF8B7355).withOpacity(0.15),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Color(0xFF8B7355).withOpacity(0.5),
                  width: 2,
                ),
              ),
              child: ClipOval(
                child: Image.asset(
                  "assets/images/profile_pic.png",
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Color(0xFFD4C0A1),
                      child: Icon(Icons.person,
                          color: Color(0xFF5D4037), size: 20),
                    );
                  },
                ),
              ),
            ),
            if (!Responsive.isMobile(context))
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  "أحمد محمد",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5D4037),
                    fontFamily: 'Tajawal',
                  ),
                ),
              ),
            Icon(Icons.school, color: Color(0xFF5D4037), size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildUserItem(String name, String role, String image) {
    return Container(
      width: 200,
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Color(0xFFD4C0A1)),
            ),
            child: ClipOval(
              child: Image.asset(
                image,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.person, color: Color(0xFF8B7355));
                },
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5D4037),
                    fontFamily: 'Tajawal',
                  ),
                ),
                Text(
                  role,
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF5D4037).withOpacity(0.7),
                    fontFamily: 'Tajawal',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SearchField extends StatelessWidget {
  const SearchField({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8),
      child: TextField(
        decoration: InputDecoration(
          hintText: "ابحث في النظام المدرسي...",
          hintStyle: TextStyle(
            color: Color(0xFF5D4037).withOpacity(0.5),
            fontFamily: 'Tajawal',
          ),
          fillColor: Color(0xFFF8F0E5),
          filled: true,
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFD4C0A1).withOpacity(0.5)),
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF8B7355)),
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          prefixIcon: Container(
            margin: EdgeInsets.only(left: 8),
            child: Icon(Icons.search, color: Color(0xFF8B7355)),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}
