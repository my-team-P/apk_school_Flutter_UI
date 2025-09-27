import 'package:flutter/material.dart';
import 'package:admin/screens/main/main_screen.dart';

class TranslationPage extends StatefulWidget {
  const TranslationPage({super.key});

  @override
  State<TranslationPage> createState() => _TranslationPageState();
}

class _TranslationPageState extends State<TranslationPage> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _translatedController = TextEditingController();
  
  String _sourceLanguage = "الإنجليزية";
  String _targetLanguage = "العربية";
  bool _isTranslating = false;
  final List<Map<String, String>> _translationHistory = [];

  final List<String> _languages = [
    "العربية", "الإنجليزية", "الفرنسية", "الألمانية", "الإسبانية",
    "الإيطالية", "الصينية", "اليابانية", "الكورية", "الروسية"
  ];

  final Map<String, String> _languageCodes = {
    "العربية": "ar", "الإنجليزية": "en", "الفرنسية": "fr", "الألمانية": "de",
    "الإسبانية": "es", "الإيطالية": "it", "الصينية": "zh", "اليابانية": "ja",
    "الكورية": "ko", "الروسية": "ru"
  };

  void _translateText() {
    if (_textController.text.trim().isEmpty) return;

    setState(() {
      _isTranslating = true;
    });

    // محاكاة عملية الترجمة
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        _isTranslating = false;
        _translatedController.text = _getMockTranslation(_textController.text);
        
        // إضافة إلى السجل
        _translationHistory.insert(0, {
          "original": _textController.text,
          "translated": _translatedController.text,
          "source": _sourceLanguage,
          "target": _targetLanguage,
          "time": "${DateTime.now().hour}:${DateTime.now().minute}"
        });
        
        if (_translationHistory.length > 10) {
          _translationHistory.removeLast();
        }
      });
    });
  }

  String _getMockTranslation(String text) {
    // ترجمة افتراضية للمحاكاة
    Map<String, String> mockTranslations = {
      "Hello": "مرحباً",
      "Good morning": "صباح الخير",
      "How are you": "كيف حالك",
      "Thank you": "شكراً",
      "Goodbye": "مع السلامة",
      "I love programming": "أحب البرمجة",
      "Flutter is amazing": "فلاتر رائع",
      "Mobile development": "تطوير التطبيقات",
      "Artificial Intelligence": "الذكاء الاصطناعي",
      "Machine Learning": "التعلم الآلي"
    };
    
    return mockTranslations[text] ?? "الترجمة: $text";
  }

  void _swapLanguages() {
    setState(() {
      String temp = _sourceLanguage;
      _sourceLanguage = _targetLanguage;
      _targetLanguage = temp;
      
      // تبديل النصوص
      String tempText = _textController.text;
      _textController.text = _translatedController.text;
      _translatedController.text = tempText;
    });
  }

  void _copyToClipboard(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("تم نسخ النص إلى الحافظة ✅"),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _speakText(String text) {
    // محاكاة التحدث بالنص
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("جاري نطق النص..."),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _clearText() {
    setState(() {
      _textController.clear();
      _translatedController.clear();
    });
  }

  void _showTranslationHistory() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              "سجل الترجمات",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Expanded(
              child: _translationHistory.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.history, size: 60, color: Colors.grey[300]),
                          SizedBox(height: 10),
                          Text("لا توجد ترجمات سابقة"),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _translationHistory.length,
                      itemBuilder: (context, index) {
                        final item = _translationHistory[index];
                        return _buildHistoryItem(item, index);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(Map<String, String> item, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        // border: Border.all(color: Colors.grey[200]),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Color(0xFF667eea).withOpacity(0.1),
          child: Text("${index + 1}", style: TextStyle(color: Color(0xFF667eea))),
        ),
        title: Text(item["original"]!, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(item["translated"]!, maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: Text(item["time"]!, style: TextStyle(color: Colors.grey, fontSize: 12)),
        onTap: () {
          setState(() {
            _textController.text = item["original"]!;
            _translatedController.text = item["translated"]!;
            _sourceLanguage = item["source"]!;
            _targetLanguage = item["target"]!;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          "نظام الترجمة",
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
        actions: [
          IconButton(
            icon: Icon(Icons.history, color: Colors.white),
            onPressed: _showTranslationHistory,
            tooltip: "سجل الترجمات",
          ),
          IconButton(
            icon: Icon(Icons.help, color: Colors.white),
            onPressed: () {
              _showHelpDialog();
            },
            tooltip: "مساعدة",
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // بطاقة إحصائيات سريعة
            _buildStatsCard(),
            SizedBox(height: 20),

            // اختيار اللغات
            _buildLanguageSelection(),
            SizedBox(height: 20),

            // حقل النص المصدر
            _buildTextInputField(
              controller: _textController,
              label: "النص المراد ترجمته",
              hint: "اكتب النص هنا...",
              language: _sourceLanguage,
            ),
            SizedBox(height: 10),

            // زر التبديل
            _buildSwapButton(),
            SizedBox(height: 10),

            // حقل النص المترجم
            _buildTextInputField(
              controller: _translatedController,
              label: "النص المترجم",
              hint: "ستظهر الترجمة هنا...",
              language: _targetLanguage,
              isTranslated: true,
            ),
            SizedBox(height: 20),

            // أزرار التحكم
            _buildControlButtons(),
            SizedBox(height: 20),

            // الميزات الإضافية
            _buildAdditionalFeatures(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
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
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(Icons.translate, "${_translationHistory.length}", "ترجمة"),
            _buildStatItem(Icons.language, "${_languages.length}", "لغة"),
            _buildStatItem(Icons.auto_awesome, "98%", "دقة"),
            _buildStatItem(Icons.speed, "0.5s", "سرعة"),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 16),
        ),
        SizedBox(height: 5),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageSelection() {
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
          children: [
            Row(
              children: [
                Icon(Icons.language, color: Color(0xFF667eea)),
                SizedBox(width: 8),
                Text(
                  "اختر اللغات",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF667eea),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _sourceLanguage,
                    decoration: InputDecoration(
                      labelText: "اللغة المصدر",
                      border: OutlineInputBorder(),
                    ),
                    items: _languages.map((language) => DropdownMenuItem(
                      value: language,
                      child: Text(language),
                    )).toList(),
                    onChanged: (value) => setState(() => _sourceLanguage = value!),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _targetLanguage,
                    decoration: InputDecoration(
                      labelText: "اللغة الهدف",
                      border: OutlineInputBorder(),
                    ),
                    items: _languages.map((language) => DropdownMenuItem(
                      value: language,
                      child: Text(language),
                    )).toList(),
                    onChanged: (value) => setState(() => _targetLanguage = value!),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String language,
    bool isTranslated = false,
  }) {
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
                Text(
                  label,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Spacer(),
                Chip(
                  label: Text(language),
                  backgroundColor: Color(0xFF667eea).withOpacity(0.1),
                ),
              ],
            ),
            SizedBox(height: 10),
            TextField(
              controller: controller,
              maxLines: 4,
              enabled: !isTranslated,
              decoration: InputDecoration(
                hintText: hint,
                border: OutlineInputBorder(),
                suffixIcon: isTranslated && controller.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.volume_up, color: Color(0xFF667eea)),
                        onPressed: () => _speakText(controller.text),
                      )
                    : null,
              ),
            ),
            if (controller.text.isNotEmpty) SizedBox(height: 10),
            if (controller.text.isNotEmpty)
              Row(
                children: [
                  Text(
                    "عدد الكلمات: ${controller.text.split(' ').length}",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.content_copy, size: 18),
                    onPressed: () => _copyToClipboard(controller.text),
                    tooltip: "نسخ النص",
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwapButton() {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: IconButton(
          icon: Icon(Icons.swap_vert, color: Color(0xFF667eea)),
          onPressed: _swapLanguages,
          tooltip: "تبديل اللغات",
        ),
      ),
    );
  }

  Widget _buildControlButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isTranslating ? null : _translateText,
            icon: _isTranslating
                ? SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : Icon(Icons.translate),
            label: Text(_isTranslating ? "جاري الترجمة..." : "ترجمة النص"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF667eea),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        SizedBox(width: 10),
        IconButton(
          icon: Icon(Icons.clear, color: Colors.red),
          onPressed: _clearText,
          tooltip: "مسح الكل",
          style: IconButton.styleFrom(
            backgroundColor: Colors.red.withOpacity(0.1),
            padding: EdgeInsets.all(12),
          ),
        ),
      ],
    );
  }

  Widget _buildAdditionalFeatures() {
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
            Text(
              "ميزات إضافية",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF667eea),
              ),
            ),
            SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildFeatureChip("ترجمة الصور", Icons.image),
                _buildFeatureChip("ترجمة المحادثات", Icons.chat),
                _buildFeatureChip("النطق الصوتي", Icons.record_voice_over),
                _buildFeatureChip("الترجمة الفورية", Icons.flash_on),
                _buildFeatureChip("حفظ الترجمات", Icons.bookmark),
                _buildFeatureChip("المشاركة", Icons.share),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureChip(String label, IconData icon) {
    return ActionChip(
      avatar: Icon(icon, size: 16),
      label: Text(label, style: TextStyle(fontSize: 12)),
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("$label - قريباً")),
        );
      },
      backgroundColor: Color(0xFF667eea).withOpacity(0.1),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("مساعدة الترجمة"),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("كيفية استخدام نظام الترجمة:"),
              SizedBox(height: 10),
              _buildHelpItem("1. اختر اللغات المصدر والهدف"),
              _buildHelpItem("2. اكتب النص في الحقل العلوي"),
              _buildHelpItem("3. انقر على زر 'ترجمة النص'"),
              _buildHelpItem("4. استخدم الأزرار الإضافية للتحكم"),
              SizedBox(height: 10),
              Text("الميزات المتاحة:", style: TextStyle(fontWeight: FontWeight.bold)),
              _buildHelpItem("• نسخ النص المترجم"),
              _buildHelpItem("• الاستماع للنطق الصوتي"),
              _buildHelpItem("• سجل الترجمات السابقة"),
              _buildHelpItem("• تبديل اللغات بسرعة"),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("فهمت"),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpItem(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Text(text, style: TextStyle(fontSize: 14)),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _translatedController.dispose();
    super.dispose();
  }
}