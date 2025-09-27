import 'package:flutter/material.dart';
import 'package:admin/screens/main/main_screen.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // إعدادات المظهر
  bool _darkMode = false;
  bool _notifications = true;
  bool _soundEffects = true;
  bool _vibration = true;
  bool _autoSave = true;
  bool _biometricAuth = false;
  bool _syncData = true;

  // إعدادات التطبيق
  String _selectedLanguage = "العربية";
  String _selectedTheme = "افتراضي";
  String _fontSize = "متوسط";
  String _downloadQuality = "عالية";

  // بيانات التخزين
  final Map<String, double> _storageData = {
    "المستندات": 245.6,
    "الصور": 156.3,
    "الفيديوهات": 89.7,
    "التطبيق": 45.2,
    "ذاكرة التخزين المؤقت": 12.8,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          "الإعدادات",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFF667eea),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MainScreen()),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // بطاقة الملف الشخصي السريعة
            _buildProfileCard(),
            SizedBox(height: 20),

            // إعدادات المظهر
            _buildSettingsSection(
              "المظهر والإعدادات العامة",
              Icons.palette,
              [
                _buildSettingSwitch(
                  "الوضع الليلي",
                  Icons.dark_mode,
                  _darkMode,
                  (value) => setState(() => _darkMode = value),
                ),
                _buildSettingOption(
                  "اللغة",
                  Icons.language,
                  _selectedLanguage,
                  _showLanguageDialog,
                ),
                _buildSettingOption(
                  "السمة",
                  Icons.color_lens,
                  _selectedTheme,
                  _showThemeDialog,
                ),
                _buildSettingOption(
                  "حجم الخط",
                  Icons.text_fields,
                  _fontSize,
                  _showFontSizeDialog,
                ),
              ],
            ),
            SizedBox(height: 20),

            // إعدادات الإشعارات
            _buildSettingsSection(
              "الإشعارات والصوت",
              Icons.notifications,
              [
                _buildSettingSwitch(
                  "الإشعارات",
                  Icons.notifications,
                  _notifications,
                  (value) => setState(() => _notifications = value),
                ),
                _buildSettingSwitch(
                  "التأثيرات الصوتية",
                  Icons.volume_up,
                  _soundEffects,
                  (value) => setState(() => _soundEffects = value),
                ),
                _buildSettingSwitch(
                  "الاهتزاز",
                  Icons.vibration,
                  _vibration,
                  (value) => setState(() => _vibration = value),
                ),
              ],
            ),
            SizedBox(height: 20),

            // إعدادات الخصوصية والأمان
            _buildSettingsSection(
              "الخصوصية والأمان",
              Icons.security,
              [
                _buildSettingSwitch(
                  "المصادقة البيومترية",
                  Icons.fingerprint,
                  _biometricAuth,
                  (value) => setState(() => _biometricAuth = value),
                ),
                _buildSettingSwitch(
                  "المزامنة التلقائية",
                  Icons.cloud_sync,
                  _syncData,
                  (value) => setState(() => _syncData = value),
                ),
                _buildSettingSwitch(
                  "الحفظ التلقائي",
                  Icons.save,
                  _autoSave,
                  (value) => setState(() => _autoSave = value),
                ),
                _buildSettingAction(
                  "تغيير كلمة المرور",
                  Icons.lock,
                  Colors.blue,
                  _changePassword,
                ),
              ],
            ),
            SizedBox(height: 20),

            // إدارة التخزين
            _buildStorageSection(),
            SizedBox(height: 20),

            // إعدادات متقدمة
            _buildSettingsSection(
              "الإعدادات المتقدمة",
              Icons.settings,
              [
                _buildSettingOption(
                  "جودة التحميل",
                  Icons.download,
                  _downloadQuality,
                  _showDownloadQualityDialog,
                ),
                _buildSettingAction(
                  "مسح الذاكرة المؤقتة",
                  Icons.clear_all,
                  Colors.orange,
                  _clearCache,
                ),
                _buildSettingAction(
                  "تصدير البيانات",
                  Icons.backup,
                  Colors.green,
                  _exportData,
                ),
                _buildSettingAction(
                  "استيراد البيانات",
                  Icons.restore,
                  Colors.purple,
                  _importData,
                ),
              ],
            ),
            SizedBox(height: 20),

            // معلومات التطبيق
            _buildAppInfoSection(),
            SizedBox(height: 20),

            // أزرار التحكم
            _buildControlButtons(),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF667eea),
            Color(0xFF764ba2),
          ],
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundImage: AssetImage("assets/images/profile_pic.png"),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "علي محمد",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "معلم رياضيات",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.edit, color: Colors.white),
              onPressed: () {
                // الانتقال لصفحة الملف الشخصي
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection(
      String title, IconData icon, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: Color(0xFF667eea)),
                SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF667eea),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSettingSwitch(
      String title, IconData icon, bool value, Function(bool) onChanged) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(0xFF667eea).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Color(0xFF667eea), size: 20),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Color(0xFF667eea),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingOption(
      String title, IconData icon, String value, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Color(0xFF667eea).withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Color(0xFF667eea), size: 20),
      ),
      title: Text(title, style: TextStyle(fontSize: 14)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: TextStyle(color: Colors.grey[600])),
          SizedBox(width: 4),
          Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
        ],
      ),
      onTap: onTap,
    );
  }

  Widget _buildSettingAction(
      String title, IconData icon, Color color, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title, style: TextStyle(fontSize: 14)),
      trailing:
          Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
      onTap: onTap,
    );
  }

  Widget _buildStorageSection() {
    final totalStorage = _storageData.values.reduce((a, b) => a + b);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.storage, color: Color(0xFF667eea)),
                SizedBox(width: 8),
                Text(
                  "إدارة التخزين",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF667eea),
                  ),
                ),
                Spacer(),
                Text(
                  "${totalStorage.toStringAsFixed(1)} MB",
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            SizedBox(height: 10),
            LinearProgressIndicator(
              value: totalStorage / 1000, // افتراضي 1GB
              backgroundColor: Colors.grey[300],
              color: Color(0xFF667eea),
            ),
            SizedBox(height: 10),
            ..._storageData.entries
                .map((entry) => _buildStorageItem(entry.key, entry.value)),
            SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _clearAllStorage,
              icon: Icon(Icons.clear_all, size: 16),
              label: Text("مسح الكل"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 40),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStorageItem(String title, double size) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(title, style: TextStyle(fontSize: 12)),
          Spacer(),
          Text("${size.toStringAsFixed(1)} MB",
              style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildAppInfoSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info, color: Color(0xFF667eea)),
                SizedBox(width: 8),
                Text(
                  "معلومات التطبيق",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF667eea),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            _buildInfoRow("الإصدار", "2.1.0"),
            _buildInfoRow("تاريخ البناء", "2024-03-15"),
            _buildInfoRow("المطور", "فريق المدرسة الذكية"),
            _buildInfoRow("الدعم", "support@school.edu.sa"),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: _showAboutDialog,
                    icon: Icon(Icons.description, size: 16),
                    label: Text("شروط الخدمة"),
                  ),
                ),
                Expanded(
                  child: TextButton.icon(
                    onPressed: _showPrivacyPolicy,
                    icon: Icon(Icons.privacy_tip, size: 16),
                    label: Text("الخصوصية"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text("$label:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          SizedBox(width: 8),
          Text(value, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildControlButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _resetSettings,
            icon: Icon(Icons.restore),
            label: Text("استعادة الإعدادات"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 15),
            ),
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MainScreen()),
              );
            },
            icon: Icon(Icons.home),
            label: Text("الصفحة الرئيسية"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF667eea),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 15),
            ),
          ),
        ),
      ],
    );
  }

  // دوال الإعدادات
  void _showLanguageDialog() {
    _showSelectionDialog("اختر اللغة", ["العربية", "English", "Français"],
        (value) {
      setState(() => _selectedLanguage = value);
    });
  }

  void _showThemeDialog() {
    _showSelectionDialog("اختر السمة", ["افتراضي", "فاتح", "داكن", "أزرق"],
        (value) {
      setState(() => _selectedTheme = value);
    });
  }

  void _showFontSizeDialog() {
    _showSelectionDialog("حجم الخط", ["صغير", "متوسط", "كبير", "كبير جداً"],
        (value) {
      setState(() => _fontSize = value);
    });
  }

  void _showDownloadQualityDialog() {
    _showSelectionDialog("جودة التحميل", ["منخفضة", "متوسطة", "عالية", "أفضل"],
        (value) {
      setState(() => _downloadQuality = value);
    });
  }

  void _showSelectionDialog(
      String title, List<String> options, Function(String) onSelect) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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

  void _changePassword() {
    // تنفيذ تغيير كلمة المرور
  }

  void _clearCache() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("مسح الذاكرة المؤقتة"),
        content: Text("هل تريد مسح الذاكرة المؤقتة؟ هذا قد يحسن أداء التطبيق."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("إلغاء"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("تم مسح الذاكرة المؤقتة بنجاح")),
              );
            },
            child: Text("مسح"),
          ),
        ],
      ),
    );
  }

  void _clearAllStorage() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("مسح جميع البيانات"),
        content: Text(
            "هل أنت متأكد من أنك تريد مسح جميع البيانات؟ هذا الإجراء لا يمكن التراجع عنه."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("إلغاء"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("تم مسح جميع البيانات بنجاح")),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text("مسح الكل"),
          ),
        ],
      ),
    );
  }

  void _exportData() {
    // تنفيذ تصدير البيانات
  }

  void _importData() {
    // تنفيذ استيراد البيانات
  }

  void _resetSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("استعادة الإعدادات"),
        content: Text("هل تريد استعادة جميع الإعدادات إلى القيم الافتراضية؟"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("إلغاء"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _darkMode = false;
                _notifications = true;
                _soundEffects = true;
                _vibration = true;
                _autoSave = true;
                _biometricAuth = false;
                _syncData = true;
                _selectedLanguage = "العربية";
                _selectedTheme = "افتراضي";
                _fontSize = "متوسط";
                _downloadQuality = "عالية";
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("تم استعادة الإعدادات الافتراضية")),
              );
            },
            child: Text("استعادة"),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("شروط الخدمة"),
        content: SingleChildScrollView(
          child: Text("هذا التطبيق مخصص لإدارة المدرسة الذكية..."),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("موافق"),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("سياسة الخصوصية"),
        content: SingleChildScrollView(
          child: Text("نحن نحترم خصوصيتك ونحمي بياناتك..."),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("موافق"),
          ),
        ],
      ),
    );
  }
}
