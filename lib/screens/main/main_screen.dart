import 'package:flutter/material.dart';
import 'components/side_menu.dart';

class MainScreen extends StatelessWidget {
  final String role;

  const MainScreen({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'مدرستي',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.indigo, fontFamily: 'Roboto'),
      locale: const Locale('ar'), // تعيين اللغة العربية
      home: HomePage(role: role),
    );
  }
}

class HomePage extends StatefulWidget {
  final String role;

  const HomePage({super.key, required this.role});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // بيانات الطالب
  final Map<String, dynamic> studentData = {
    'name': 'أحمد محمد',
    'grade': 'الصف العاشر - أ',
    'studentId': '202300123',
    'school': 'مدرسة النخبة الثانوية',
    'image': 'assets/images/student_avatar.png',
    'attendance': '98%',
    'average': '92.5',
  };

  // صور المدارس من النت
  final List<String> schoolImages = [
    'https://images.unsplash.com/photo-1523050854058-8df90110c9f1?w=500&h=300&fit=crop',
    'https://images.unsplash.com/photo-1562774053-701939374585?w=500&h=300&fit=crop',
    'https://images.unsplash.com/photo-1546410531-bb4caa6b424d?w=500&h=300&fit=crop',
    'https://images.unsplash.com/photo-1588072432836-e10032774350?w=500&h=300&fit=crop',
  ];

  // أخبار المدرسة
  final List<Map<String, dynamic>> schoolNews = [
    {
      'title': 'تفوق طلاب المدرسة في مسابقة الروبوت',
      'content': 'حقق طلاب المدرسة المركز الأول في مسابقة الروبوت الوطنية',
      'date': 'منذ 2 ساعة',
      'type': 'achievement',
    },
    {
      'title': 'بدء التسجيل في النشاط الصيفي',
      'content': 'تعلن المدرسة عن فتح باب التسجيل في الأنشطة الصيفية',
      'date': 'منذ 6 ساعات',
      'type': 'announcement',
    },
    {
      'title': 'تطوير مختبر العلوم',
      'content': 'تم تجهيز مختبر العلوم بأحدث الأجهزة والتقنيات',
      'date': 'منذ يوم',
      'type': 'development',
    },
  ];

  final List<Map<String, dynamic>> quickActions = [
    {'icon': Icons.schedule, 'title': 'الجدول', 'page': 'schedule'},
    {'icon': Icons.assignment, 'title': 'الواجبات', 'page': 'assignments'},
    {'icon': Icons.grade, 'title': 'الدرجات', 'page': 'grades'},
    {'icon': Icons.library_books, 'title': 'المقررات', 'page': 'courses'},
    {'icon': Icons.attach_money, 'title': 'الرسوم', 'page': 'fees'},
    {'icon': Icons.quiz, 'title': 'الاختبارات', 'page': 'exams'},
  ];

  final List<Map<String, dynamic>> upcomingEvents = [
    {
      'title': 'اختبار الرياضيات',
      'date': '2023-10-15',
      'time': '09:00 ص',
      'type': 'exam',
      'course': 'الرياضيات',
    },
    {
      'title': 'رحلة علمية',
      'date': '2023-10-18',
      'time': '08:00 ص',
      'type': 'event',
      'course': 'العلوم',
    },
    {
      'title': 'تسليم بحث العلوم',
      'date': '2023-10-20',
      'time': '11:59 م',
      'type': 'assignment',
      'course': 'العلوم',
    },
  ];

  // عناصر القائمة الجانبية
  final List<Map<String, dynamic>> drawerItems = [
    {'icon': Icons.person, 'title': 'الملف الشخصي', 'page': 'profile'},
    {'icon': Icons.schedule, 'title': 'الجدول الدراسي', 'page': 'schedule'},
    {'icon': Icons.assignment, 'title': 'الواجبات', 'page': 'assignments'},
    {'icon': Icons.grade, 'title': 'الدرجات', 'page': 'grades'},
    {'icon': Icons.library_books, 'title': 'المقررات', 'page': 'courses'},
    {'icon': Icons.attach_money, 'title': 'الرسوم', 'page': 'fees'},
    {'icon': Icons.event, 'title': 'الفعاليات', 'page': 'events'},
    {'icon': Icons.settings, 'title': 'الإعدادات', 'page': 'settings'},
    {'icon': Icons.help, 'title': 'المساعدة', 'page': 'help'},
    {'icon': Icons.logout, 'title': 'تسجيل الخروج', 'page': 'logout'},
  ];

  static const Color topBackgroundColor = Color.fromARGB(255, 246, 230, 204);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      key: _scaffoldKey,
      drawer: SideMenu(role: widget.role),

      backgroundColor: Colors.white,
      // drawer: _buildDrawer(),
      body: Stack(
        children: [
          ClipPath(
            clipper: TopClipper(),
            child: Container(
              height: size.height * 0.25,
              width: double.infinity,
              color: topBackgroundColor,
            ),
          ),

          // محتوى الصفحة
          Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      _buildSchoolImages(),
                      const SizedBox(height: 24),
                      _buildSchoolNews(),
                      const SizedBox(height: 24),
                      _buildUpcomingEvents(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: _buildCustomBottomNavigationBar(),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.only(top: 40, right: 16, left: 16, bottom: 10),
      color: Colors.transparent,
      child: Row(
        children: [
          // زر القائمة الجانبية
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white, size: 28),
            onPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
          const SizedBox(width: 8),
          // الشعار
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.indigo[50],
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.indigo.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: const Icon(Icons.school, color: Colors.indigo),
          ),
          const SizedBox(width: 12),
          // معلومات الطالب
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مرحباً، ${studentData['name']}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  studentData['grade'],
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ),
          // زر الإشعارات
          Stack(
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.notifications_none,
                    color: Colors.white,
                  ),
                  onPressed: _navigateToNotifications,
                ),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: const Text(
                    '3',
                    style: TextStyle(color: Colors.white, fontSize: 10),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    IconData icon,
    String title,
    String value,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(title, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  Widget _buildSchoolImages() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            'معرض المدارس',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.indigo,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: schoolImages.length,
            itemBuilder: (context, index) {
              return Container(
                width: 300,
                margin: const EdgeInsets.only(left: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: NetworkImage(schoolImages[index]),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.6),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: const Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Text(
                        'مدرسة النخبة',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard(Map<String, dynamic> action) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _navigateToPage(action['page']),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(action['icon'], color: Colors.indigo, size: 28),
              const SizedBox(height: 8),
              Text(
                action['title'],
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSchoolNews() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            'أخبار المدرسة',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.indigo,
            ),
          ),
        ),
        const SizedBox(height: 16),
        ...schoolNews.map((news) => _buildNewsItem(news)),
      ],
    );
  }

  Widget _buildNewsItem(Map<String, dynamic> news) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showNewsDetails(news),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _getNewsColor(news['type']),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getNewsIcon(news['type']),
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      news['title'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      news['content'],
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      news['date'],
                      style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUpcomingEvents() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            'الأحداث القادمة',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.indigo,
            ),
          ),
        ),
        const SizedBox(height: 16),
        ...upcomingEvents.map((event) => _buildEventItem(event)),
      ],
    );
  }

  Widget _buildEventItem(Map<String, dynamic> event) {
    Color eventColor;
    IconData eventIcon;

    switch (event['type']) {
      case 'exam':
        eventColor = Colors.red;
        eventIcon = Icons.quiz;
        break;
      case 'assignment':
        eventColor = Colors.orange;
        eventIcon = Icons.assignment;
        break;
      case 'event':
        eventColor = Colors.green;
        eventIcon = Icons.event;
        break;
      default:
        eventColor = Colors.blue;
        eventIcon = Icons.circle;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: eventColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(eventIcon, color: eventColor),
        ),
        title: Text(
          event['title'],
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${event['date']} - ${event['time']}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            Text(
              event['course'],
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ],
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),
        onTap: () => _showEventDetails(event),
      ),
    );
  }

  Widget _buildCustomBottomNavigationBar() {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home, 'الرئيسية', 0),
          _buildNavItem(Icons.quiz, 'الاختبارات', 1),
          _buildNavItem(Icons.notifications, 'الإشعارات', 2),
          _buildNavItem(Icons.settings, 'الإعدادات', 3),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isSelected = _currentIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _currentIndex = index;
          });
          _handleNavigation(index);
        },
        child: Container(
          color: Colors.transparent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.indigo : Colors.grey[500],
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected ? Colors.indigo : Colors.grey[500],
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // دوال مساعدة
  Color _getNewsColor(String type) {
    switch (type) {
      case 'achievement':
        return Colors.green;
      case 'announcement':
        return Colors.blue;
      case 'development':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getNewsIcon(String type) {
    switch (type) {
      case 'achievement':
        return Icons.emoji_events;
      case 'announcement':
        return Icons.campaign;
      case 'development':
        return Icons.construction;
      default:
        return Icons.info;
    }
  }

  String _getHijriDate(DateTime date) {
    return '١٤٤٥/٣/٢٠';
  }

  // دوال التنقل
  void _handleNavigation(int index) {
    switch (index) {
      case 0: // الرئيسية
        break;
      case 1: // الاختبارات
        _navigateToExams();
        break;
      case 2: // الإشعارات
        _navigateToNotifications();
        break;
      case 3: // الإعدادات
        _navigateToSettings();
        break;
    }
  }

  void _navigateToPage(String page) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('قريباً'),
        content: Text('صفحة $page ستكون متاحة قريباً'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('موافق'),
          ),
        ],
      ),
    );
  }

  void _navigateToExams() => _navigateToPage('الاختبارات');
  void _navigateToNotifications() => _navigateToPage('الإشعارات');
  void _navigateToSettings() => _navigateToPage('الإعدادات');

  void _showNewsDetails(Map<String, dynamic> news) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(news['title']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(news['content']),
            const SizedBox(height: 10),
            Text(news['date'], style: TextStyle(color: Colors.grey)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  void _showEventDetails(Map<String, dynamic> event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(event['title']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('المادة: ${event['course']}'),
            Text('التاريخ: ${event['date']}'),
            Text('الوقت: ${event['time']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }
}

class TopClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 60);
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height - 60,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
