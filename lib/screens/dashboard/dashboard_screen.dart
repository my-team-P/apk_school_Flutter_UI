import 'package:admin/responsive.dart';
import 'package:flutter/material.dart';
import '../../constants.dart';
import 'components/header.dart';
import 'components/storage_details.dart';
import 'components/my_files.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
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
    );
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
