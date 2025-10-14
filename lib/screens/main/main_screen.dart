import 'package:admin/controllers/menu_app_controller.dart';
import 'package:admin/responsive.dart';
import 'package:admin/screens/dashboard/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'components/side_menu.dart';

class MainScreen extends StatelessWidget {
  final String role;

  const MainScreen({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: context.read<MenuAppController>().scaffoldKey,
      drawer: SideMenu(role: role),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.blueGrey[50],
        child: SafeArea(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (Responsive.isDesktop(context))
                Expanded(
                  child: Container(
                    color: Colors.blueGrey[900],
                    child: SideMenu(role: role),
                  ),
                ),
              Expanded(
                flex: 5,
                child: Column(
                  children: [
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
                    Expanded(
                      child: Container(
                        color: const Color(0xFFFFFFFF),
                        child:  DashboardScreen(role: role),
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
