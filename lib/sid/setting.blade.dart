import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:admin/a/settings_provider.dart';
import 'package:admin/screens/main/main_screen.dart';

class SettingsPage extends StatefulWidget {
  final String role;
  const SettingsPage({super.key, required this.role});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userJson = prefs.getString('userData');
    if (userJson != null) {
      setState(() {
        userData = json.decode(userJson);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);

    // استرجاع البيانات بشكل آمن
    final userName = userData?['name'] ?? "غير محدد";
    final userEmail = userData?['email'] ?? "غير محدد";
    final userRole = userData?['role'] ?? widget.role;
    final userImage = userData?['profile_image'];
    // final userClass = (userData != null && userData!['role'] == 'student')
    //     ? userData!['grade_name'] ?? "غير محدد"
    //     : null;
    final userClass = (userData != null && userData!['role'] == 'student')
        ? (userData!['grade_name']?.toString() ?? "غير محدد")
        : null;

    // يظهر الصف فقط للطلاب

    final roleText = userRole == 'teacher'
        ? (settings.language == "English" ? "Teacher" : "معلم")
        : userRole == 'student'
            ? (settings.language == "English" ? "Student" : "طالب")
            : (settings.language == "English" ? "Admin" : "مدير");

    return Scaffold(
      backgroundColor: settings.darkMode ? Colors.grey[900] : Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF667eea),
        title: Text(
          settings.language == "English" ? "Settings" : "الإعدادات",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: settings.fontSizeValue,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => MainScreen(role: userRole),
              ),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileCard(
                userName, userEmail, roleText, userImage, userClass),
            const SizedBox(height: 20),
            _buildSettingsSection(context),
            const SizedBox(height: 20),
            _buildStorageSection(context),
            const SizedBox(height: 20),
            _buildControlButtons(context),
          ],
        ),
      ),
    );
  }

  // --------------------- بطاقة الملف الشخصي ---------------------
  Widget _buildProfileCard(String userName, String email, String roleText,
      String? imageUrl, String? userClass) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: imageUrl != null
                ? NetworkImage(imageUrl)
                : const AssetImage("assets/images/17570498857827.png")
                    as ImageProvider,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize:
                        Provider.of<SettingsProvider>(context).fontSizeValue,
                  ),
                ),
                Text(
                  email,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize:
                        Provider.of<SettingsProvider>(context).fontSizeValue -
                            2,
                  ),
                ),
                Text(
                  roleText,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize:
                        Provider.of<SettingsProvider>(context).fontSizeValue -
                            2,
                  ),
                ),
                if (userClass != null) // يظهر الصف فقط للطلاب
                  Text(
                    "الصف: $userClass",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize:
                          Provider.of<SettingsProvider>(context).fontSizeValue -
                              2,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --------------------- قسم الإعدادات ---------------------
  Widget _buildSettingsSection(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    return Container(
      decoration: BoxDecoration(
        color: settings.darkMode ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.palette, color: Color(0xFF667eea)),
                const SizedBox(width: 8),
                Text(
                  settings.language == "English"
                      ? "Appearance & Settings"
                      : "المظهر والإعدادات العامة",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: settings.fontSizeValue,
                    color: const Color(0xFF667eea),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.grey),
          _buildSettingSwitch(
            context,
            settings.language == "English" ? "Dark Mode" : "الوضع الليلي",
            Icons.dark_mode,
            settings.darkMode,
            (value) => settings.toggleDarkMode(value),
          ),
          _buildSettingOption(
            context,
            settings.language == "English" ? "Language" : "اللغة",
            Icons.language,
            settings.language,
            _showLanguageDialog,
          ),
          _buildSettingOption(
            context,
            settings.language == "English" ? "Font Size" : "حجم الخط",
            Icons.text_fields,
            settings.fontSize,
            _showFontSizeDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingSwitch(BuildContext context, String title, IconData icon,
      bool value, Function(bool) onChanged) {
    final settings = Provider.of<SettingsProvider>(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF667eea).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF667eea), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
              child: Text(title,
                  style: TextStyle(fontSize: settings.fontSizeValue))),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF667eea),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingOption(BuildContext context, String title, IconData icon,
      String value, Function(BuildContext) onTap) {
    final settings = Provider.of<SettingsProvider>(context);
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF667eea).withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: const Color(0xFF667eea), size: 20),
      ),
      title: Text(title, style: TextStyle(fontSize: settings.fontSizeValue)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value,
              style: TextStyle(
                  color: Colors.grey[600], fontSize: settings.fontSizeValue)),
          const SizedBox(width: 4),
          Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
        ],
      ),
      onTap: () => onTap(context),
    );
  }

  // --------------------- باقي الأقسام ---------------------
  Widget _buildStorageSection(BuildContext context) => Container();
  Widget _buildControlButtons(BuildContext context) => Container();

  void _showLanguageDialog(BuildContext context) {}
  void _showFontSizeDialog(BuildContext context) {}
}
