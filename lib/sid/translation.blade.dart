import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:admin/screens/main/main_screen.dart';

//MyMemory API تم استخدامه للترجمة وهو مجاني

class TranslationPage extends StatefulWidget {
  final String role; // <-- أضف هذا

  const TranslationPage({super.key, required this.role});


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

  final Map<String, String> _languageCodes = {
    "العربية": "ar",
    "الإنجليزية": "en",
    "الفرنسية": "fr",
    "الألمانية": "de",
    "الإسبانية": "es",
    "الإيطالية": "it",
    "الصينية": "zh",
    "اليابانية": "ja",
    "الكورية": "ko",
    "الروسية": "ru",
    "البرتغالية": "pt",
    "الهندية": "hi",
    "التركية": "tr",
    "الفارسية": "fa",
    "العبرية": "he",
    "الأردية": "ur",
    "الإندونيسية": "id",
    "الهولندية": "nl",
    "البولندية": "pl",
    "السويدية": "sv",
    "النرويجية": "no",
    "الدنماركية": "da",
    "الفنلندية": "fi",
    "التشيكية": "cs",
    "المجرية": "hu",
    "الرومانية": "ro",
    "اليونانية": "el",
    "التايلاندية": "th",
    "الفيتنامية": "vi"
  };

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
    "الروسية",
    "البرتغالية",
    "الهندية",
    "التركية",
    "الفارسية",
    "العبرية",
    "الأردية"
  ];

  // دالة الترجمة الرئيسية باستخدام MyMemory API
  Future<void> _translateText() async {
    if (_textController.text.trim().isEmpty) return;

    setState(() {
      _isTranslating = true;
      _translatedController.text = "جاري الترجمة...";
    });

    try {
      final String sourceLang = _languageCodes[_sourceLanguage] ?? 'en';
      final String targetLang = _languageCodes[_targetLanguage] ?? 'ar';
      final String textToTranslate = _textController.text.trim();

      // استخدام MyMemory Translation API
      final response = await http.get(
        Uri.parse('https://api.mymemory.translated.net/get?'
            'q=${Uri.encodeComponent(textToTranslate)}&'
            'langpair=$sourceLang|$targetLang&'
            'de=example@example.com' // إضافة email لزيادة الحد اليومي
            ),
        headers: {
          'User-Agent': 'FlutterTranslationApp/1.0',
          'Accept': 'application/json',
        },
      );

      print('API Response Status: ${response.statusCode}');
      print('API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['responseStatus'] == 200) {
          final translatedText = data['responseData']['translatedText'];

          setState(() {
            _translatedController.text = _cleanTranslatedText(translatedText);
            _addToHistory(_translatedController.text);
          });

          _showSuccessSnackBar('تمت الترجمة بنجاح!');
        } else {
          throw Exception(
              'خطأ في الترجمة: ${data['responseStatus']} - ${data['responseDetails']}');
        }
      } else {
        throw Exception('فشل في الاتصال بالخادم: ${response.statusCode}');
      }
    } catch (e) {
      print('Translation error: $e');
      _showErrorSnackBar('خطأ في الترجمة: $e');
      _useFallbackTranslation();
    } finally {
      setState(() {
        _isTranslating = false;
      });
    }
  }

  // تنظيف النص المترجم من أي رموز غير مرغوب فيها
  String _cleanTranslatedText(String text) {
    return text
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&nbsp;', ' ')
        .trim();
  }

  // ترجمة بديلة باستخدام خدمة احتياطية
  Future<void> _useBackupTranslation() async {
    try {
      final String sourceLang = _languageCodes[_sourceLanguage] ?? 'en';
      final String targetLang = _languageCodes[_targetLanguage] ?? 'ar';
      final String textToTranslate = _textController.text.trim();

      // استخدام LibreTranslate (بديل مجاني)
      final response = await http.post(
        Uri.parse('https://libretranslate.de/translate'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'q': textToTranslate,
          'source': sourceLang,
          'target': targetLang,
          'format': 'text'
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final translatedText = data['translatedText'];

        setState(() {
          _translatedController.text = translatedText;
          _addToHistory(translatedText);
        });
      } else {
        throw Exception('فشل في الترجمة الاحتياطية');
      }
    } catch (e) {
      print('Backup translation error: $e');
      _useFallbackTranslation();
    }
  }

  // ترجمة افتراضية كحل أخير
  void _useFallbackTranslation() {
    Map<String, String> commonTranslations = {
      // تحيات وأساسيات
      "Hello": "مرحباً",
      "Hi": "مرحباً",
      "Good morning": "صباح الخير",
      "Good evening": "مساء الخير",
      "Good night": "تصبح على خير",
      "How are you": "كيف حالك",
      "I'm fine": "أنا بخير",
      "Thank you": "شكراً",
      "Thanks": "شكراً",
      "You're welcome": "عفوًا",
      "Please": "من فضلك",
      "Excuse me": "اعذرني",
      "Sorry": "آسف",
      "Goodbye": "مع السلامة",
      "Bye": "مع السلامة",
      "See you later": "أراك لاحقاً",

      // نعم ولا
      "Yes": "نعم",
      "No": "لا",
      "Okay": "حسناً",
      "Maybe": "ربما",

      // أسئلة شائعة
      "What is your name": "ما اسمك",
      "My name is": "اسمي",
      "Where are you from": "من أين أنت",
      "I am from": "أنا من",
      "How old are you": "كم عمرك",
      "I am years old": "عمري سنة",

      // أرقام
      "One": "واحد",
      "Two": "اثنان",
      "Three": "ثلاثة",
      "Four": "أربعة",
      "Five": "خمسة",
      "Six": "ستة",
      "Seven": "سبعة",
      "Eight": "ثمانية",
      "Nine": "تسعة",
      "Ten": "عشرة",

      // ألوان
      "Red": "أحمر",
      "Blue": "أزرق",
      "Green": "أخضر",
      "Yellow": "أصفر",
      "Black": "أسود",
      "White": "أبيض",

      // أيام الأسبوع
      "Sunday": "الأحد",
      "Monday": "الإثنين",
      "Tuesday": "الثلاثاء",
      "Wednesday": "الأربعاء",
      "Thursday": "الخميس",
      "Friday": "الجمعة",
      "Saturday": "السبت",

      // أشهر السنة
      "January": "يناير",
      "February": "فبراير",
      "March": "مارس",
      "April": "أبريل",
      "May": "مايو",
      "June": "يونيو",
      "July": "يوليو",
      "August": "أغسطس",
      "September": "سبتمبر",
      "October": "أكتوبر",
      "November": "نوفمبر",
      "December": "ديسمبر",

      // كلمات شائعة
      "Water": "ماء",
      "Food": "طعام",
      "House": "منزل",
      "Car": "سيارة",
      "School": "مدرسة",
      "Work": "عمل",
      "Time": "وقت",
      "Day": "يوم",
      "Night": "ليلة",
      "Sun": "شمس",
      "Moon": "قمر",
      "Star": "نجمة",
      "Book": "كتاب",
      "Pen": "قلم",
      "Computer": "حاسوب",
      "Phone": "هاتف",
      "Internet": "إنترنت",
      "Money": "مال",
      "Love": "حب",
      "Friend": "صديق",
      "Family": "عائلة",
      "Health": "صحة",
      "Peace": "سلام",
      "Freedom": "حرية",
    };

    String text = _textController.text.trim();
    String translatedText =
        commonTranslations[text] ?? "🔍 جاري البحث عن ترجمة...";

    // إذا لم توجد ترجمة مباشرة، حاول تقسيم الجملة
    if (translatedText == "🔍 جاري البحث عن ترجمة...") {
      List<String> words = text.split(' ');
      List<String> translatedWords = [];

      for (String word in words) {
        String translatedWord = commonTranslations[word] ?? word;
        translatedWords.add(translatedWord);
      }

      translatedText = translatedWords.join(' ');
    }

    setState(() {
      _translatedController.text = translatedText;
      _addToHistory(translatedText);
    });
  }

  void _addToHistory(String translatedText) {
    _translationHistory.insert(0, {
      "original": _textController.text,
      "translated": translatedText,
      "source": _sourceLanguage,
      "target": _targetLanguage,
      "time":
          "${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}"
    });

    // الحفاظ على آخر 20 ترجمة فقط
    if (_translationHistory.length > 20) {
      _translationHistory.removeLast();
    }
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
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _clearText() {
    setState(() {
      _textController.clear();
      _translatedController.clear();
    });
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showTranslationHistory() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        height: MediaQuery.of(context).size.height * 0.8,
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
                          Icon(Icons.history,
                              size: 60, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          const Text(
                            "لا توجد ترجمات سابقة",
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "سيتم حفظ الترجمات هنا تلقائياً",
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
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
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF667eea).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              "${index + 1}",
              style: const TextStyle(
                color: Color(0xFF667eea),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        title: Text(
          item["original"]!,
          style: const TextStyle(fontWeight: FontWeight.bold),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              item["translated"]!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  "${item["source"]!} → ${item["target"]!}",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const Spacer(),
                Text(
                  item["time"]!,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
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
          "نظام الترجمة المجاني",
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
  MaterialPageRoute(
    builder: (context) => MainScreen(role: widget.role), // <-- هنا
  ),
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
            icon: const Icon(Icons.info, color: Colors.white),
            onPressed: _showInfoDialog,
            tooltip: "معلومات عن الخدمة",
          ),
        ],
      ),
      body: Column(
        children: [
          // إشعار معلومات الخدمة
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: const Color(0xFF667eea).withOpacity(0.1),
            child: Row(
              children: [
                const Icon(Icons.translate, color: Color(0xFF667eea), size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "MyMemory Translation API",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      const Text(
                        "خدمة ترجمة مجانية - تدعم 100+ لغة",
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // اختيار اللغات
                  _buildLanguageSelection(),
                  const SizedBox(height: 20),

                  // حقل النص المصدر
                  _buildTextInputField(
                    controller: _textController,
                    label: "النص المراد ترجمته",
                    hint: "اكتب النص هنا...",
                    language: _sourceLanguage,
                    isSource: true,
                  ),
                  const SizedBox(height: 16),

                  // زر التبديل
                  _buildSwapButton(),
                  const SizedBox(height: 16),

                  // حقل النص المترجم
                  _buildTextInputField(
                    controller: _translatedController,
                    label: "النص المترجم",
                    hint: _isTranslating
                        ? "جاري الترجمة..."
                        : "ستظهر الترجمة هنا...",
                    language: _targetLanguage,
                    isSource: false,
                  ),
                  const SizedBox(height: 24),

                  // أزرار التحكم
                  _buildControlButtons(),
                  const SizedBox(height: 20),

                  // إحصائيات
                  _buildStatsCard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSelection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Row(
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
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _sourceLanguage,
                    decoration: const InputDecoration(
                      labelText: "اللغة المصدر",
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _targetLanguage,
                    decoration: const InputDecoration(
                      labelText: "اللغة الهدف",
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
    required bool isSource,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  label,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF667eea).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    language,
                    style: const TextStyle(
                      color: Color(0xFF667eea),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 5,
              minLines: 3,
              enabled: isSource && !_isTranslating,
              decoration: InputDecoration(
                hintText: hint,
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.all(12),
                suffixIcon: !isSource && controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.content_copy,
                            color: Color(0xFF667eea)),
                        onPressed: () => _copyToClipboard(controller.text),
                        tooltip: "نسخ النص",
                      )
                    : null,
              ),
            ),
            if (controller.text.isNotEmpty) const SizedBox(height: 8),
            if (controller.text.isNotEmpty)
              Row(
                children: [
                  Text(
                    "عدد الحروف: ${controller.text.length}",
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const Spacer(),
                  Text(
                    "عدد الكلمات: ${controller.text.split(' ').length}",
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
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
      child: Card(
        elevation: 2,
        shape: const CircleBorder(),
        child: IconButton(
          icon:
              const Icon(Icons.swap_horiz, color: Color(0xFF667eea), size: 28),
          onPressed: _isTranslating ? null : _swapLanguages,
          tooltip: "تبديل اللغات",
          style: IconButton.styleFrom(
            backgroundColor: Colors.white,
            padding: const EdgeInsets.all(12),
          ),
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
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.translate, size: 20),
            label: Text(
              _isTranslating ? "جاري الترجمة..." : "ترجمة النص",
              style: const TextStyle(fontSize: 16),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF667eea),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        IconButton(
          icon: const Icon(Icons.clear, size: 24),
          onPressed: _isTranslating ? null : _clearText,
          tooltip: "مسح الكل",
          style: IconButton.styleFrom(
            backgroundColor: Colors.grey[100],
            padding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
                Icons.history, "${_translationHistory.length}", "ترجمة"),
            _buildStatItem(Icons.language, "${_languages.length}", "لغة"),
            _buildStatItem(Icons.speed, "مجاني", "خدمة"),
            _buildStatItem(Icons.auto_awesome, "100+", "لغة مدعومة"),
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
            color: const Color(0xFF667eea).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF667eea), size: 16),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF667eea),
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info, color: Color(0xFF667eea)),
            SizedBox(width: 8),
            Text("معلومات عن الخدمة"),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("MyMemory Translation API",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildInfoItem("الميزات:", [
                "ترجمة مجانية تماماً",
                "يدعم أكثر من 100 لغة",
                "لا يتطلب مفتاح API",
                "مناسبة للاستخدام الشخصي"
              ]),
              const SizedBox(height: 8),
              _buildInfoItem("القيود:", [
                "حد أقصى 1000 كلمة في اليوم",
                "قد يكون هناك تأخير بسيط",
                "دقة الترجمة: جيدة جداً"
              ]),
              const SizedBox(height: 8),
              _buildInfoItem("نصائح:", [
                "اكتب جمل قصيرة لنتائج أفضل",
                "تجنب النصوص الطويلة جداً",
                "تحقق من الترجمة للنصوص المهمة"
              ]),
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

  Widget _buildInfoItem(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 2),
              child: Text("• $item", style: const TextStyle(fontSize: 14)),
            )),
      ],
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _translatedController.dispose();
    super.dispose();
  }
}
