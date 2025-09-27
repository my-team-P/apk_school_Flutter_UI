import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:admin/screens/main/main_screen.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

// server AI
String ser = "http://192.168.1.101:8000/chat";

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;
  bool _isConnected = true;

  // موضوعات مقترحة للدردشة
  final List<Map<String, String>> _suggestedTopics = [
    {
      "title": "💡 مساعدة دراسية",
      "subtitle": "اسأل عن أي موضوع تعليمي"
    },
    {
      "title": "📚 شرح الدروس",
      "subtitle": "احصل على شرح مفصل للدروس"
    },
    {
      "title": "✍️ حل الواجبات",
      "subtitle": "مساعدة في حل التمارين"
    },
    {
      "title": "🧮 مسائل رياضية",
      "subtitle": "حل المسائل الرياضية خطوة بخطوة"
    },
    {
      "title": "🔬 تجارب علمية",
      "subtitle": "شرح التجارب العلمية"
    },
    {
      "title": "📖 نصائح دراسة",
      "subtitle": "تحسين طرق الدراسة"
    },
  ];

  Future<String> sendMessage(String text) async {
    try {
      final response = await http.post(
        Uri.parse(ser),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"text": text}),
      ).timeout(Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _isConnected = true;
        });
        return data["reply"];
      } else {
        setState(() {
          _isConnected = false;
        });
        return "⚠️ عذراً، حدث خطأ في السيرفر. الرجاء المحاولة لاحقاً.";
      }
    } catch (e) {
      setState(() {
        _isConnected = false;
      });
      return "⚠️ تعذر الاتصال بالسيرفر. تأكد من اتصال الشبكة.";
    }
  }

  void _send() async {
    if (_controller.text.isEmpty) return;

    final text = _controller.text.trim();

    // إضافة رسالة المستخدم
    setState(() {
      _messages.add({
        "role": "user",
        "text": text,
        "time": DateTime.now(),
        "status": "sent"
      });
      _isLoading = true;
    });
    
    _controller.clear();
    _scrollToBottom();

    // إرسال الرسالة إلى السيرفر
    final reply = await sendMessage(text);

    // إضافة الرد من الذكاء الاصطناعي
    setState(() {
      _messages.add({
        "role": "ai",
        "text": reply,
        "time": DateTime.now(),
        "status": "delivered"
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

  void _suggestTopic(String topic) {
    _controller.text = topic;
    _send();
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

  void _copyMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("تم نسخ الرسالة إلى الحافظة ✅"),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // دالة مساعدة لتنسيق الوقت
  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildMessageBubble(Map<String, dynamic> message, int index) {
    final isUser = message["role"] == "user";
    final time = _formatTime(message["time"] ?? DateTime.now());
    
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Color(0xFF667eea).withOpacity(0.1),
              child: Icon(Icons.smart_toy, size: 16, color: Color(0xFF667eea)),
            ),
            SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUser ? Color(0xFF667eea) : Colors.grey[100],
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomLeft: isUser ? Radius.circular(16) : Radius.circular(4),
                  bottomRight: isUser ? Radius.circular(4) : Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message["text"] ?? "",
                    style: TextStyle(
                      color: isUser ? Colors.white : Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        time,
                        style: TextStyle(
                          color: isUser ? Colors.white70 : Colors.grey[600],
                          fontSize: 10,
                        ),
                      ),
                      if (isUser) ...[
                        SizedBox(width: 8),
                        Icon(Icons.done_all, size: 12, color: Colors.white70),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isUser) ...[
            SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.blue.withOpacity(0.1),
              child: Icon(Icons.person, color: Colors.blue, size: 16),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSuggestedTopics() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "موضوعات مقترحة",
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
            children: _suggestedTopics.map((topic) {
              return ActionChip(
                avatar: Icon(Icons.lightbulb_outline, size: 16),
                label: Text(topic["title"]!),
                onPressed: () => _suggestTopic(topic["title"]!),
                backgroundColor: Color(0xFF667eea).withOpacity(0.1),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Color(0xFF667eea).withOpacity(0.1),
            child: Icon(Icons.smart_toy, size: 16, color: Color(0xFF667eea)),
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
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          "المساعد الذكي",
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
            icon: Icon(Icons.delete_outline, color: Colors.white),
            onPressed: _clearChat,
            tooltip: "مسح المحادثة",
          ),
          IconButton(
            icon: Icon(Icons.info_outline, color: Colors.white),
            onPressed: () {
              _showHelpDialog();
            },
            tooltip: "مساعدة",
          ),
        ],
      ),
      body: Column(
        children: [
          // حالة الاتصال
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: _isConnected ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isConnected ? Icons.wifi : Icons.wifi_off,
                  size: 16,
                  color: _isConnected ? Colors.green : Colors.orange,
                ),
                SizedBox(width: 4),
                Text(
                  _isConnected ? "متصل بالسيرفر" : "غير متصل",
                  style: TextStyle(
                    color: _isConnected ? Colors.green : Colors.orange,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.smart_toy,
                            size: 80,
                            color: Colors.grey[300],
                          ),
                          SizedBox(height: 20),
                          Text(
                            "مرحباً! أنا مساعدك الذكي",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "كيف يمكنني مساعدتك اليوم؟",
                            style: TextStyle(
                              color: Colors.grey[500],
                            ),
                          ),
                          SizedBox(height: 30),
                          _buildSuggestedTopics(),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.only(top: 16),
                    itemCount: _messages.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index < _messages.length) {
                        return _buildMessageBubble(_messages[index], index);
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
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            maxLines: null,
                            decoration: InputDecoration(
                              hintText: "اكتب رسالتك هنا...",
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            onSubmitted: (_) => _send(),
                          ),
                        ),
                        if (_controller.text.isNotEmpty)
                          IconButton(
                            icon: Icon(Icons.clear, size: 20),
                            onPressed: () => _controller.clear(),
                          ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Color(0xFF667eea),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(_isLoading ? Icons.hourglass_top : Icons.send),
                    color: Colors.white,
                    onPressed: _isLoading ? null : _send,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("مساعدة المساعد الذكي"),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("كيفية استخدام المساعد الذكي:"),
              SizedBox(height: 10),
              _buildHelpItem("• اسأل عن أي موضوع تعليمي"),
              _buildHelpItem("• اطلب شرحاً للدروس"),
              _buildHelpItem("• احصل على مساعدة في الواجبات"),
              _buildHelpItem("• استفسر عن المفاهيم العلمية"),
              SizedBox(height: 10),
              Text("نصائح:", style: TextStyle(fontWeight: FontWeight.bold)),
              _buildHelpItem("• كن محدداً في أسئلتك"),
              _buildHelpItem("• استخدم الموضوعات المقترحة للبدء"),
              _buildHelpItem("• تأكد من اتصال الشبكة"),
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
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}