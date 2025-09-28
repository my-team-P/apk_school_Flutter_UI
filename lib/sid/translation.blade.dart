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
    "العربية",
    "الإنجليزية",
    "الفرنسية",
    "الألمانية",
    "الإسبانية",
    "الإيطالية",
    "الصينية",
    "اليابانية",
    "الكورية",
    "الروسية"
  ];

  void _translateText() {
    if (_textController.text.trim().isEmpty) return;

    setState(() {
      _isTranslating = true;
    });

    // محاكاة عملية الترجمة
    Future.delayed(const Duration(seconds: 2), () {
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
      const SnackBar(
        content: Text("تم نسخ النص إلى الحافظة ✅"),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _speakText(String text) {
    // محاكاة التحدث بالنص
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
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
            const SizedBox(height: 20),
            const Text(
              "سجل الترجمات",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _translationHistory.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.history, size: 60, color: Colors.grey),
                          const SizedBox(height: 10),
                          const Text("لا توجد ترجمات سابقة"),
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
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF667eea).withOpacity(0.1),
          child: Text("${index + 1}",
              style: const TextStyle(color: Color(0xFF667eea))),
        ),
        title: Text(item["original"]!,
            maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(item["translated"]!,
            maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: Text(item["time"]!,
            style: const TextStyle(color: Colors.grey, fontSize: 12)),
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
        title: const Text(
          "نظام الترجمة",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF667eea),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MainScreen()),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            onPressed: _showTranslationHistory,
            tooltip: "سجل الترجمات",
          ),
          IconButton(
            icon: const Icon(Icons.help, color: Colors.white),
            onPressed: () {
              _showHelpDialog();
            },
            tooltip: "مساعدة",
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // بطاقة إحصائيات سريعة
            _buildStatsCard(),
            const SizedBox(height: 20),

            // اختيار اللغات
            _buildLanguageSelection(),
            const SizedBox(height: 20),

            // حقل النص المصدر
            _buildTextInputField(
              controller: _textController,
              label: "النص المراد ترجمته",
              hint: "اكتب النص هنا...",
              language: _sourceLanguage,
            ),
            const SizedBox(height: 10),

            // زر التبديل
            _buildSwapButton(),
            const SizedBox(height: 10),

            // حقل النص المترجم
            _buildTextInputField(
              controller: _translatedController,
              label: "النص المترجم",
              hint: "ستظهر الترجمة هنا...",
              language: _targetLanguage,
              isTranslated: true,
            ),
            const SizedBox(height: 20),

            // أزرار التحكم
            _buildControlButtons(),
            const SizedBox(height: 20),

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
        gradient: const LinearGradient(
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
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
                Icons.translate, "${_translationHistory.length}", "ترجمة"),
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
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 16),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
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
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.language, color: Color(0xFF667eea)),
                const SizedBox(width: 8),
                Text(
                  "اختر اللغات",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF667eea),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _sourceLanguage,
                    decoration: const InputDecoration(
                      labelText: "اللغة المصدر",
                      border: OutlineInputBorder(),
                    ),
                    items: _languages
                        .map((language) => DropdownMenuItem(
                              value: language,
                              child: Text(language),
                            ))
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _sourceLanguage = value!),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _targetLanguage,
                    decoration: const InputDecoration(
                      labelText: "اللغة الهدف",
                      border: OutlineInputBorder(),
                    ),
                    items: _languages
                        .map((language) => DropdownMenuItem(
                              value: language,
                              child: Text(language),
                            ))
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _targetLanguage = value!),
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
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Chip(
                  label: Text(language),
                  backgroundColor: const Color(0xFF667eea).withOpacity(0.1),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: controller,
              maxLines: 4,
              enabled: !isTranslated,
              decoration: InputDecoration(
                hintText: hint,
                border: const OutlineInputBorder(),
                suffixIcon: isTranslated && controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.volume_up,
                            color: Color(0xFF667eea)),
                        onPressed: () => _speakText(controller.text),
                      )
                    : null,
              ),
            ),
            if (controller.text.isNotEmpty) const SizedBox(height: 10),
            if (controller.text.isNotEmpty)
              Row(
                children: [
                  Text(
                    "عدد الكلمات: ${controller.text.split(' ').length}",
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.content_copy, size: 18),
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
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: IconButton(
          icon: const Icon(Icons.swap_vert, color: Color(0xFF667eea)),
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
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.translate),
            label: Text(_isTranslating ? "جاري الترجمة..." : "ترجمة النص"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF667eea),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        IconButton(
          icon: const Icon(Icons.clear, color: Colors.red),
          onPressed: _clearText,
          tooltip: "مسح الكل",
          style: IconButton.styleFrom(
            backgroundColor: Colors.red.withOpacity(0.1),
            padding: const EdgeInsets.all(12),
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
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: const Padding(
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
            Text(
              "هذه الصفحة للعرض فقط. لاستخدام نظام الترجمة الفعلي، "
              "يجب دمجها مع خدمة ترجمة مثل Google Translate API.",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("مساعدة الترجمة"),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("هذه نسخة تجريبية من نظام الترجمة."),
              const SizedBox(height: 10),
              const Text("الترجمة الفعلية تتطلب:"),
              _buildHelpItem("• خدمة ترجمة API (مثل Google Translate)"),
              _buildHelpItem("• مفتاح API ساري"),
              _buildHelpItem("• اتصال بالإنترنت"),
              _buildHelpItem("• تكوين الخادم المناسب"),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("فهمت"),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(text, style: const TextStyle(fontSize: 14)),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _translatedController.dispose();
    super.dispose();
  }
}
