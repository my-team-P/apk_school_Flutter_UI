import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:admin/a/settings_provider.dart';
import 'package:admin/screens/main/main_screen.dart';

class SettingsPage extends StatelessWidget {
  final String role; // <-- أضف هذا

  const SettingsPage({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);

    return Scaffold(
      backgroundColor: settings.darkMode ? Colors.grey[900] : Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Color(0xFF667eea),
        title: Text(
          settings.language == "English" ? "Settings" : "الإعدادات",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: settings.fontSizeValue,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => MainScreen(role: role), // ✅ تمرير الدور
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
            _buildProfileCard(context),
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
  Widget _buildProfileCard(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
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
          const CircleAvatar(
            radius: 25,
            backgroundImage: AssetImage("assets/images/profile_pic.png"),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  settings.language == "English" ? "Ali Mohammed" : "علي محمد",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: settings.fontSizeValue,
                  ),
                ),
                Text(
                  settings.language == "English"
                      ? "Math Teacher"
                      : "معلم رياضيات",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: settings.fontSizeValue - 2,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () {},
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

  // --------------------- مفاتيح التبديل ---------------------
  Widget _buildSettingSwitch(BuildContext context, String title, IconData icon,
      bool value, Function(bool) onChanged) {
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
                style: TextStyle(
                    fontSize:
                        Provider.of<SettingsProvider>(context).fontSizeValue)),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF667eea),
          ),
        ],
      ),
    );
  }

  // --------------------- خيارات الإعداد ---------------------
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

  // --------------------- التحكم في التخزين ---------------------
  Widget _buildStorageSection(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);

    final Map<String, double> storageData = {
      "المستندات": 245.6,
      "الصور": 156.3,
      "الفيديوهات": 89.7,
      "التطبيق": 45.2,
      "ذاكرة التخزين المؤقت": 12.8,
    };

    final totalStorage = storageData.values.reduce((a, b) => a + b);

    return Container(
      decoration: BoxDecoration(
        color: settings.darkMode ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.storage, color: Color(0xFF667eea)),
              const SizedBox(width: 8),
              Text(
                settings.language == "English"
                    ? "Storage Management"
                    : "إدارة التخزين",
                style: TextStyle(
                  fontSize: settings.fontSizeValue,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF667eea),
                ),
              ),
              const Spacer(),
              Text("${totalStorage.toStringAsFixed(1)} MB",
                  style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: settings.fontSizeValue)),
            ],
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: totalStorage / 1000,
            backgroundColor: Colors.grey[300],
            color: const Color(0xFF667eea),
          ),
          const SizedBox(height: 10),
          ...storageData.entries
              .map((e) => _buildStorageItem(context, e.key, e.value)),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: () => _clearAllStorage(context),
            icon: const Icon(Icons.clear_all, size: 16),
            label: const Text("مسح الكل"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 40),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStorageItem(BuildContext context, String title, double size) {
    final settings = Provider.of<SettingsProvider>(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(title, style: TextStyle(fontSize: settings.fontSizeValue - 2)),
          const Spacer(),
          Text("${size.toStringAsFixed(1)} MB",
              style: TextStyle(
                  fontSize: settings.fontSizeValue - 2,
                  color: Colors.grey[600])),
        ],
      ),
    );
  }

  // --------------------- أزرار التحكم ---------------------
  Widget _buildControlButtons(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _resetSettings(context),
            icon: const Icon(Icons.restore),
            label: const Text("استعادة الإعدادات"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => MainScreen(role: role), // ✅ تمرير الدور
                ),
              );
            },
            icon: const Icon(Icons.home),
            label: const Text("الصفحة الرئيسية"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF667eea),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
          ),
        ),
      ],
    );
  }

  // --------------------- مربعات الحوار ---------------------
  void _showLanguageDialog(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    _showSelectionDialog(
        context,
        settings.language == "English" ? "Choose Language" : "اختر اللغة",
        ["العربية", "English"],
        (value) => settings.setLanguage(value));
  }

  void _showFontSizeDialog(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    _showSelectionDialog(
        context,
        settings.language == "English" ? "Font Size" : "حجم الخط",
        ["صغير", "متوسط", "كبير", "كبير جداً"],
        (value) => settings.setFontSize(value));
  }

  void _showSelectionDialog(BuildContext context, String title,
      List<String> options, Function(String) onSelect) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: options
              .map((option) => ListTile(
                    title: Text(option),
                    onTap: () {
                      onSelect(option);
                      Navigator.pop(context);
                    },
                  ))
              .toList(),
        ),
      ),
    );
  }

  void _clearAllStorage(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("مسح جميع البيانات"),
        content: const Text(
            "هل أنت متأكد من أنك تريد مسح جميع البيانات؟ هذا الإجراء لا يمكن التراجع عنه."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("إلغاء")),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("تم مسح جميع البيانات بنجاح")));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("مسح الكل"),
          ),
        ],
      ),
    );
  }

  void _resetSettings(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    settings.toggleDarkMode(false);
    settings.setLanguage("العربية");
    settings.setFontSize("متوسط");
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("تم استعادة الإعدادات الافتراضية")));
  }
}
