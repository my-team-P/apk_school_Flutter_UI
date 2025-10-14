import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:admin/screens/main/main_screen.dart';

class ChatPage extends StatefulWidget {
  final String role; // <-- أضف هذا

  const ChatPage({super.key, required this.role});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;

  // خدمات الذكاء الاصطناعي المجانية
  final List<String> _aiServices = [
    "HuggingFace",
    "DeepAI",
    "OpenAssistant",
  ];
  int _currentServiceIndex = 0;

  Future<String> _sendToHuggingFace(String text) async {
    try {
      final response = await http
          .post(
            Uri.parse(
                "https://api-inference.huggingface.co/models/microsoft/DialoGPT-medium"),
            headers: {
              "Authorization":
                  "Bearer HUGGINGYOUR_FACE_TOKEN", // احصل على token مجاني من huggingface.co
              "Content-Type": "application/json",
            },
            body: jsonEncode({"inputs": text}),
          )
          .timeout(Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["generated_text"] ??
            "لم أستطع فهم سؤالك. يمكنك إعادة الصياغة؟";
      } else {
        return "⚠️ الخدمة مشغولة حالياً. جرب خدمة أخرى.";
      }
    } catch (e) {
      return "⚠️ تعذر الاتصال بالخدمة. جرب خدمة أخرى.";
    }
  }

  Future<String> _sendToDeepAI(String text) async {
    try {
      final response = await http.post(
        Uri.parse("https://api.deepai.org/api/text-generator"),
        headers: {
          "api-key":
              "3b4fb449-714c-4958-952b-c52674a98db2", // احصل على key مجاني من deepai.org
        },
        body: {
          "text": text,
        },
      ).timeout(Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["output"] ?? "أحتاج إلى مزيد من التوضيح.";
      } else {
        return "⚠️ الخدمة غير متاحة حالياً.";
      }
    } catch (e) {
      return "⚠️ فشل الاتصال بالخدمة.";
    }
  }

  Future<String> _sendToOpenAssistant(String text) async {
    try {
      final response = await http
          .post(
            Uri.parse("https://api.openassistant.ai/chat"),
            headers: {
              "Content-Type": "application/json",
            },
            body: jsonEncode({"message": text, "model": "oa-mini"}),
          )
          .timeout(Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["response"] ?? "يمكنك طرح سؤالك بطريقة أخرى.";
      } else {
        return "⚠️ الخدمة متوقفة حالياً.";
      }
    } catch (e) {
      return "⚠️ لا يمكن الوصول إلى الخدمة.";
    }
  }

  Future<String> _sendToFreeAI(String text) async {
    // محاولة الخدمات بالترتيب
    switch (_currentServiceIndex) {
      case 0: // HuggingFace
        final result = await _sendToHuggingFace(text);
        if (!result.contains("⚠️")) return result;
        break;
      case 1: // DeepAI
        final result = await _sendToDeepAI(text);
        if (!result.contains("⚠️")) return result;
        break;
      case 2: // OpenAssistant
        final result = await _sendToOpenAssistant(text);
        if (!result.contains("⚠️")) return result;
        break;
    }

    // إذا فشلت الخدمة الحالية، جرب الخدمة التالية
    _currentServiceIndex = (_currentServiceIndex + 1) % _aiServices.length;
    return await _sendToFreeAI(text); // إعادة المحاولة مع الخدمة التالية
  }

  Future<String> _getAIResponse(String text) async {
    // إذا كان السؤال بسيطاً، استخدم ردود مسبقة
    final lowerText = text.toLowerCase();

    Map<String, String> quickResponses = {
      "مرحبا": "مرحباً! كيف يمكنني مساعدتك اليوم؟ 😊",
      "اهلا": "أهلاً وسهلاً! أنا هنا لمساعدتك. 💫",
      "hello": "Hello! How can I help you today? 🌟",
      "hi": "Hi there! What can I do for you? ✨",
      "شكرا": "عفوًا! دائماً سعيد بمساعدتك. 🤗",
      "thank you": "You're welcome! Happy to help. ",
      "ما اسمك": "أنا المساعد الذكي! يمكنك مناداتي بأي اسم تريده. 🤖",
      "who are you": "I'm your AI assistant! Ready to help with anything. 💡",
      "كيف حالك": "أنا بخير، شكراً لسؤالك! كيف يمكنني مساعدتك؟ 🌸",
      "how are you": "I'm doing great! How can I assist you today? 🌼",
    };

    if (quickResponses.containsKey(lowerText)) {
      return quickResponses[lowerText]!;
    }

    // تحليل النص لتقديم ردود أكثر ذكاء
    if (lowerText.contains("درس") ||
        lowerText.contains("مادة") ||
        lowerText.contains("تعليم")) {
      return "يمكنني مساعدتك في المواضيع التعليمية! 📚\nما المادة أو الموضوع الذي تريد المساعدة فيه؟";
    }

    if (lowerText.contains("رياضيات") || lowerText.contains("math")) {
      return "الرياضيات رائعة! 🧮\nأخبرني بالسؤال الرياضي الذي تواجهه وسأحاول حله.";
    }

    if (lowerText.contains("علوم") || lowerText.contains("science")) {
      return "العلم مثير للاهتمام! 🔬\nما هو الاستفسار العلمي الذي لديك؟";
    }

    if (lowerText.contains("برمجة") || lowerText.contains("programming")) {
      return "البرمجة عالم رائع! 💻\nأي لغة برمجة أو مشكلة تواجهك؟";
    }

    // استخدام خدمة الذكاء الاصطناعي للردود المعقدة
    try {
      return await _sendToFreeAI(text);
    } catch (e) {
      return "أنا هنا لمساعدتك! 💫\nيمكنك سؤالي عن:\n• الدروس والمواد التعليمية\n• شرح المفاهيم\n• المساعدة في الواجبات\n• أي استفسار آخر";
    }
  }

  void _sendMessage() async {
    if (_controller.text.isEmpty) return;

    final text = _controller.text.trim();

    // إضافة رسالة المستخدم
    setState(() {
      _messages.add({
        "role": "user",
        "text": text,
        "time": DateTime.now(),
      });
      _isLoading = true;
    });

    _controller.clear();
    _scrollToBottom();

    // الحصول على الرد من الذكاء الاصطناعي
    final response = await _getAIResponse(text);

    // إضافة الرد
    setState(() {
      _messages.add({
        "role": "ai",
        "text": response,
        "time": DateTime.now(),
      });
      _isLoading = false;
    });

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _clearChat() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("مسح المحادثة"),
        content: Text("هل تريد مسح جميع الرسائل؟"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("إلغاء"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _messages.clear();
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text("مسح الكل"),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isUser = message["role"] == "user";
    final time = _formatTime(message["time"] ?? DateTime.now());

    return Container(
      margin: EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Color(0xFF667eea),
              child: Icon(Icons.smart_toy, size: 16, color: Colors.white),
            ),
            SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isUser ? Color(0xFF667eea) : Colors.grey[100],
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                      bottomLeft:
                          isUser ? Radius.circular(16) : Radius.circular(4),
                      bottomRight:
                          isUser ? Radius.circular(4) : Radius.circular(16),
                    ),
                  ),
                  child: Text(
                    message["text"] ?? "",
                    style: TextStyle(
                      color: isUser ? Colors.white : Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          if (isUser) ...[
            SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.blue,
              child: Icon(Icons.person, color: Colors.white, size: 16),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Color(0xFF667eea),
            child: Icon(Icons.smart_toy, size: 16, color: Colors.white),
          ),
          SizedBox(width: 8),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xFF667eea)),
                  ),
                ),
                SizedBox(width: 8),
                Text("جاري الكتابة...", style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickReplies() {
    final quickReplies = [
      "شرح درس الرياضيات",
      "مساعدة في الواجب",
      "ما هو الذكاء الاصطناعي؟",
      "كيف أتعلم البرمجة؟",
      "شرح درس العلوم",
    ];

    return Container(
      padding: EdgeInsets.all(16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: quickReplies.map((reply) {
          return ActionChip(
            label: Text(reply),
            onPressed: () {
              _controller.text = reply;
              _sendMessage();
            },
            backgroundColor: Color(0xFF667eea).withOpacity(0.1),
            labelStyle: TextStyle(color: Color(0xFF667eea)),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "المساعد الذكي المجاني",
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
              MaterialPageRoute(
                builder: (context) => MainScreen(role: widget.role), // <-- هنا
              ),
            );
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_outline, color: Colors.white),
            onPressed: _clearChat,
            tooltip: "مسح المحادثة",
          ),
        ],
      ),
      body: Column(
        children: [
          // معلومات الخدمة
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Color(0xFF667eea).withOpacity(0.1),
            child: Row(
              children: [
                Icon(Icons.info, size: 16, color: Color(0xFF667eea)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "دردشة ذكية مجانية - ${_aiServices[_currentServiceIndex]}",
                    style: TextStyle(
                      color: Color(0xFF667eea),
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.smart_toy,
                          size: 80,
                          color: Color(0xFF667eea),
                        ),
                        SizedBox(height: 20),
                        Text(
                          "مرحباً! أنا مساعدك الذكي المجاني",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "اسألني عن anything وسأحاول مساعدتك",
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 30),
                        _buildQuickReplies(),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.only(top: 16),
                    itemCount: _messages.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index < _messages.length) {
                        return _buildMessageBubble(_messages[index]);
                      } else {
                        return _buildTypingIndicator();
                      }
                    },
                  ),
          ),

          // حقل الإدخال
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: "اكتب رسالتك هنا...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: _isLoading ? Colors.grey : Color(0xFF667eea),
                  child: IconButton(
                    icon: Icon(_isLoading ? Icons.hourglass_top : Icons.send),
                    color: Colors.white,
                    onPressed: _isLoading ? null : _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
