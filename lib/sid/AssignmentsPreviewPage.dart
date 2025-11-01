import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:admin/provider/assignments_provider.dart';
import 'confirm_assignment_page.dart';

class AssignmentsPreviewPage extends ConsumerStatefulWidget {
  
  final String role; // "admin", "teacher", "student"

  const AssignmentsPreviewPage({super.key, required this.role});

  @override
  ConsumerState<AssignmentsPreviewPage> createState() => _AssignmentsPreviewPageState();
}

class _AssignmentsPreviewPageState extends ConsumerState<AssignmentsPreviewPage> {
  final FlutterTts _flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _setupTTS();
  }

  Future<void> _setupTTS() async {
    await _flutterTts.setLanguage("ar-SA"); // اللغة العربية (سعودي)
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.8);
  }

  Future<void> _speakAssignments() async {
    final assignments = ref.read(assignmentsProvider);
    if (assignments.isEmpty) {
      await _flutterTts.speak("لا توجد تكاليف حالياً");
    } else {
      String message = "التكاليف الحالية هي: ";
      for (var a in assignments) {
        message += "${a.title} لمادة ${a.subject} في الصف ${a.className}. ";
      }
      await _flutterTts.speak(message);
    }
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final assignments = ref.watch(assignmentsProvider);

    // عند كل تحديث (مثلاً عند تحميل بيانات جديدة)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _speakAssignments();
    });

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('التكاليف')),
        body: assignments.isEmpty
            ? const Center(child: Text('لا توجد تكاليف'))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: assignments.length,
                itemBuilder: (context, index) {
                  final a = assignments[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text(a.title),
                      subtitle: Text('${a.subject} • ${a.className}'),
                      trailing: a.isCompleted
                          ? const Text(
                              'مكتمل',
                              style: TextStyle(color: Colors.green),
                            )
                          : ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ConfirmAssignmentPage(
                                      assignment: a,
                                    ),
                                  ),
                                );
                              },
                              child: const Text('تسليم'),
                            ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
