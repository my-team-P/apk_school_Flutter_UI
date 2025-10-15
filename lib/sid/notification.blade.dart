import 'package:flutter/material.dart';
import 'package:admin/screens/main/main_screen.dart';

class NotificationPage extends StatefulWidget {
  final String role;

  const NotificationPage({super.key, required this.role});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<Map<String, dynamic>> schedules = [];
  bool loading = false;

  // فلترة البيانات حسب الفصل
  String selectedClass = "الصف الأول";
  List<String> classes = [
    "الصف الأول",
    "الصف الثاني",
    "الصف الثالث",
    "الصف الرابع"
  ];

  @override
  void initState() {
    super.initState();
    // تحميل البيانات المحلية مباشرة
    loadLocalData();
  }

  void loadLocalData() {
    setState(() {
      // بيانات الحصص المحلية
      schedules = [
        // الصف الأول
        {
          'class': 'الصف الأول',
          'day': 'الأحد',
          'periods': [
            {
              'time': '8:00 - 9:00',
              'subject': 'الرياضيات',
              'teacher': 'أ. أحمد'
            },
            {
              'time': '9:00 - 10:00',
              'subject': 'اللغة العربية',
              'teacher': 'أ. فاطمة'
            },
            {'time': '10:00 - 10:30', 'subject': 'فسحة', 'teacher': ''},
            {
              'time': '10:30 - 11:30',
              'subject': 'العلوم',
              'teacher': 'أ. محمد'
            },
            {
              'time': '11:30 - 12:30',
              'subject': 'التربية الإسلامية',
              'teacher': 'أ. خالد'
            },
          ]
        },
        {
          'class': 'الصف الأول',
          'day': 'الإثنين',
          'periods': [
            {
              'time': '8:00 - 9:00',
              'subject': 'اللغة الإنجليزية',
              'teacher': 'أ. سارة'
            },
            {
              'time': '9:00 - 10:00',
              'subject': 'التربية الفنية',
              'teacher': 'أ. ليلى'
            },
            {'time': '10:00 - 10:30', 'subject': 'فسحة', 'teacher': ''},
            {
              'time': '10:30 - 11:30',
              'subject': 'الاجتماعيات',
              'teacher': 'أ. عمر'
            },
            {
              'time': '11:30 - 12:30',
              'subject': 'التربية البدنية',
              'teacher': 'أ. علي'
            },
          ]
        },
        {
          'class': 'الصف الأول',
          'day': 'الثلاثاء',
          'periods': [
            {
              'time': '8:00 - 9:00',
              'subject': 'الرياضيات',
              'teacher': 'أ. أحمد'
            },
            {'time': '9:00 - 10:00', 'subject': 'العلوم', 'teacher': 'أ. محمد'},
            {'time': '10:00 - 10:30', 'subject': 'فسحة', 'teacher': ''},
            {
              'time': '10:30 - 11:30',
              'subject': 'الحاسوب',
              'teacher': 'أ. حسن'
            },
            {
              'time': '11:30 - 12:30',
              'subject': 'اللغة العربية',
              'teacher': 'أ. فاطمة'
            },
          ]
        },

        // الصف الثاني
        {
          'class': 'الصف الثاني',
          'day': 'الأحد',
          'periods': [
            {
              'time': '8:00 - 9:00',
              'subject': 'اللغة العربية',
              'teacher': 'أ. منى'
            },
            {
              'time': '9:00 - 10:00',
              'subject': 'الرياضيات',
              'teacher': 'أ. ياسر'
            },
            {'time': '10:00 - 10:30', 'subject': 'فسحة', 'teacher': ''},
            {
              'time': '10:30 - 11:30',
              'subject': 'العلوم',
              'teacher': 'أ. نورة'
            },
            {
              'time': '11:30 - 12:30',
              'subject': 'اللغة الإنجليزية',
              'teacher': 'أ. جون'
            },
          ]
        },
        {
          'class': 'الصف الثاني',
          'day': 'الإثنين',
          'periods': [
            {
              'time': '8:00 - 9:00',
              'subject': 'الاجتماعيات',
              'teacher': 'أ. كمال'
            },
            {
              'time': '9:00 - 10:00',
              'subject': 'التربية الإسلامية',
              'teacher': 'أ. إبراهيم'
            },
            {'time': '10:00 - 10:30', 'subject': 'فسحة', 'teacher': ''},
            {
              'time': '10:30 - 11:30',
              'subject': 'التربية الفنية',
              'teacher': 'أ. داليا'
            },
            {
              'time': '11:30 - 12:30',
              'subject': 'الحاسوب',
              'teacher': 'أ. سامي'
            },
          ]
        },

        // الصف الثالث
        {
          'class': 'الصف الثالث',
          'day': 'الأحد',
          'periods': [
            {
              'time': '8:00 - 9:00',
              'subject': 'الفيزياء',
              'teacher': 'أ. محمود'
            },
            {
              'time': '9:00 - 10:00',
              'subject': 'الكيمياء',
              'teacher': 'أ. هدى'
            },
            {'time': '10:00 - 10:30', 'subject': 'فسحة', 'teacher': ''},
            {
              'time': '10:30 - 11:30',
              'subject': 'الرياضيات',
              'teacher': 'أ. ناصر'
            },
            {
              'time': '11:30 - 12:30',
              'subject': 'اللغة العربية',
              'teacher': 'أ. عائشة'
            },
          ]
        },
        {
          'class': 'الصف الثالث',
          'day': 'الثلاثاء',
          'periods': [
            {
              'time': '8:00 - 9:00',
              'subject': 'الأحياء',
              'teacher': 'أ. رانيا'
            },
            {
              'time': '9:00 - 10:00',
              'subject': 'اللغة الإنجليزية',
              'teacher': 'أ. مايك'
            },
            {'time': '10:00 - 10:30', 'subject': 'فسحة', 'teacher': ''},
            {
              'time': '10:30 - 11:30',
              'subject': 'التربية الإسلامية',
              'teacher': 'أ. عبدالله'
            },
            {
              'time': '11:30 - 12:30',
              'subject': 'الحاسوب',
              'teacher': 'أ. وائل'
            },
          ]
        },

        // الصف الرابع
        {
          'class': 'الصف الرابع',
          'day': 'الأحد',
          'periods': [
            {
              'time': '8:00 - 9:00',
              'subject': 'الرياضيات المتقدمة',
              'teacher': 'أ. خالد'
            },
            {
              'time': '9:00 - 10:00',
              'subject': 'الفيزياء',
              'teacher': 'أ. سعيد'
            },
            {'time': '10:00 - 10:30', 'subject': 'فسحة', 'teacher': ''},
            {
              'time': '10:30 - 11:30',
              'subject': 'الكيمياء',
              'teacher': 'أ. لمياء'
            },
            {
              'time': '11:30 - 12:30',
              'subject': 'اللغة العربية',
              'teacher': 'أ. مها'
            },
          ]
        },
        {
          'class': 'الصف الرابع',
          'day': 'الأربعاء',
          'periods': [
            {
              'time': '8:00 - 9:00',
              'subject': 'الأحياء',
              'teacher': 'أ. ياسمين'
            },
            {
              'time': '9:00 - 10:00',
              'subject': 'اللغة الإنجليزية',
              'teacher': 'أ. ديفيد'
            },
            {'time': '10:00 - 10:30', 'subject': 'فسحة', 'teacher': ''},
            {
              'time': '10:30 - 11:30',
              'subject': 'التربية الوطنية',
              'teacher': 'أ. فارس'
            },
            {
              'time': '11:30 - 12:30',
              'subject': 'التقنية',
              'teacher': 'أ. باسل'
            },
          ]
        },
      ];
    });
  }

  // دالة لتصفية الحصص حسب الفصل المحدد
  List<Map<String, dynamic>> _filterSchedulesByClass() {
    return schedules
        .where((schedule) => schedule['class'] == selectedClass)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredSchedules = _filterSchedulesByClass();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'جدول الحصص',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue[700],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => MainScreen(role: widget.role),
              ),
            );
          },
        ),
      ),
      body: Column(
        children: [
          // فلتر الفصول
          Container(
            padding: const EdgeInsets.all(16),
            child: Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    const Icon(Icons.class_, color: Colors.blue),
                    const SizedBox(width: 10),
                    const Text(
                      'الفصل:',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButton<String>(
                        value: selectedClass,
                        isExpanded: true,
                        items: classes.map((String classItem) {
                          return DropdownMenuItem<String>(
                            value: classItem,
                            child: Text(
                              classItem,
                              style: const TextStyle(fontSize: 16),
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedClass = newValue!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: filteredSchedules.isEmpty
                ? const Center(
                    child: Text(
                      "لا توجد حصص لهذا الفصل",
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredSchedules.length,
                    itemBuilder: (context, index) {
                      final schedule = filteredSchedules[index];
                      return _buildScheduleCard(schedule);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard(Map<String, dynamic> schedule) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // يوم الأسبوع
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                schedule['day'],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),

            // جدول الحصص
            Table(
              border: TableBorder.all(
                color: Colors.grey.shade300,
                width: 1,
                borderRadius: BorderRadius.circular(8),
              ),
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(3),
                2: FlexColumnWidth(2),
              },
              children: [
                // رأس الجدول
                TableRow(
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        'الوقت',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        'المادة',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        'المعلم',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),

                // بيانات الحصص
                ...schedule['periods'].map<TableRow>((period) {
                  final isBreak = period['subject'] == 'فسحة';
                  return TableRow(
                    decoration: BoxDecoration(
                      color: isBreak
                          ? Colors.orange[50]
                          : schedule['periods'].indexOf(period) % 2 == 0
                              ? Colors.white
                              : Colors.grey[50],
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          period['time'],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight:
                                isBreak ? FontWeight.bold : FontWeight.normal,
                            color: isBreak ? Colors.orange : Colors.black,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          period['subject'],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight:
                                isBreak ? FontWeight.bold : FontWeight.normal,
                            color: isBreak ? Colors.orange : Colors.black,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          period['teacher'],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight:
                                isBreak ? FontWeight.bold : FontWeight.normal,
                            color: isBreak ? Colors.orange : Colors.black,
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
