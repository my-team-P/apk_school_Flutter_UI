import 'package:admin/controllers/menu_app_controller.dart';
import 'package:admin/responsive.dart';
import 'package:admin/screens/dashboard/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'components/side_menu.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: context.read<MenuAppController>().scaffoldKey,
      drawer: const SideMenu(),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.blueGrey[50], // خلفية رئيسية هادئة
        child: SafeArea(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // SideMenu ثابت في نسخة سطح المكتب
              if (Responsive.isDesktop(context))
                Expanded(
                  child: Container(
                    color: Colors.blueGrey[900], // لون رسمي للـSideMenu
                    child: const SideMenu(),
                  ),
                ),
              // المحتوى الرئيسي
              Expanded(
                flex: 5,
                child: Column(
                  children: [
                    // رأس الصفحة الرسمي
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                      color: Color.fromARGB(250, 67, 58, 12),
                      child: Row(
                        children: const [
                          Icon(Icons.school, color: Colors.white),
                          SizedBox(width: 10),
                          Text(
                            "لوحة التحكم المدرسية",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // محتوى Dashboard يملأ المساحة المتبقية
                    Expanded(
                      child: Container(
                        color: Color(0xFFF6E6CC), // اللون الأساسي من الشعار

                        child: const DashboardScreen(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
