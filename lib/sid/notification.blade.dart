import 'package:flutter/material.dart';
import 'package:admin/screens/main/main_screen.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "الإشعارات",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFF667eea),
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
            icon: Icon(Icons.delete_sweep, color: Colors.white),
            onPressed: () {
              _showClearAllDialog(context);
            },
          ),
          IconButton(
            icon: Icon(Icons.mark_email_read, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: DefaultTabController(
        length: 4,
        child: Column(
          children: [
            // Header مع إحصائيات
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF667eea),
                    Color(0xFF764ba2),
                  ],
                ),
              ),
              child: Row(
                children: [
                  _buildStatItem(managerMessages.length.toString(), "رسائل المدير", Icons.email),
                  Spacer(),
                  _buildStatItem(homeworkNotifications.length.toString(), "الواجبات", Icons.assignment),
                  Spacer(),
                  _buildStatItem(activityNotifications.length.toString(), "الأنشطة", Icons.event),
                ],
              ),
            ),
            
            // تبويبات التصنيف
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: TabBar(
                labelColor: Color(0xFF667eea),
                unselectedLabelColor: Colors.grey,
                indicatorColor: Color(0xFF667eea),
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.all_inclusive, size: 16),
                        SizedBox(width: 4),
                        Text("الكل"),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.email, size: 16),
                        SizedBox(width: 4),
                        Text("رسائل المدير"),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.assignment, size: 16),
                        SizedBox(width: 4),
                        Text("الواجبات"),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.event, size: 16),
                        SizedBox(width: 4),
                        Text("الأنشطة"),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // محتوى التبويبات
            Expanded(
              child: TabBarView(
                children: [
                  // تبويب الكل
                  _buildNotificationsList(context, [
                    ...managerMessages,
                    ...homeworkNotifications,
                    ...activityNotifications,
                  ]),
                  
                  // تبويب رسائل المدير
                  _buildManagerMessagesList(context),
                  
                  // تبويب الواجبات
                  _buildHomeworkList(context),
                  
                  // تبويب الأنشطة
                  _buildActivitiesList(context),
                ],
              ),
            ),
          ],
        ),
      ),
      
      // زر الإعدادات في الأسفل
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showNotificationSettings(context);
        },
        backgroundColor: Color(0xFF667eea),
        child: Icon(Icons.settings, color: Colors.white),
      ),
    );
  }

  Widget _buildStatItem(String count, String title, IconData icon) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        SizedBox(height: 5),
        Text(
          count,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationsList(BuildContext context, List<NotificationModel> notifications) {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        return _buildNotificationCard(context, notifications[index]);
      },
    );
  }

  Widget _buildManagerMessagesList(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: managerMessages.length,
      itemBuilder: (context, index) {
        return _buildManagerMessageCard(context, managerMessages[index]);
      },
    );
  }

  Widget _buildHomeworkList(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: homeworkNotifications.length,
      itemBuilder: (context, index) {
        return _buildHomeworkCard(context, homeworkNotifications[index]);
      },
    );
  }

  Widget _buildActivitiesList(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: activityNotifications.length,
      itemBuilder: (context, index) {
        return _buildActivityCard(context, activityNotifications[index]);
      },
    );
  }

  Widget _buildManagerMessageCard(BuildContext context, NotificationModel notification) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            _showMessageDetails(context, notification);
          },
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // أيقونة المدير
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person,
                    color: Colors.red,
                    size: 20,
                  ),
                ),
                
                SizedBox(width: 12),
                
                // محتوى الرسالة
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              "رسالة من المدير",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.red,
                              ),
                            ),
                          ),
                          Icon(Icons.priority_high, color: Colors.red, size: 16),
                        ],
                      ),
                      
                      SizedBox(height: 4),
                      
                      Text(
                        notification.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.black87,
                        ),
                      ),
                      
                      SizedBox(height: 4),
                      
                      Text(
                        notification.message,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      SizedBox(height: 8),
                      
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 12, color: Colors.grey),
                          SizedBox(width: 4),
                          Text(
                            notification.time,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                if (!notification.isRead)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHomeworkCard(BuildContext context, NotificationModel notification) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            _showHomeworkDetails(context, notification);
          },
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // أيقونة الواجب
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.assignment,
                    color: Colors.blue,
                    size: 20,
                  ),
                ),
                
                SizedBox(width: 12),
                
                // محتوى الواجب
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                      
                      SizedBox(height: 4),
                      
                      Text(
                        notification.message,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      
                      SizedBox(height: 8),
                      
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.timer, size: 12, color: Colors.orange),
                            SizedBox(width: 4),
                            Text(
                              "موعد التسليم: ${notification.dueDate ?? 'غير محدد'}",
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      SizedBox(height: 8),
                      
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 12, color: Colors.grey),
                          SizedBox(width: 4),
                          Text(
                            notification.time,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                          Spacer(),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              "واجب",
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActivityCard(BuildContext context, NotificationModel notification) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            _showActivityDetails(context, notification);
          },
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // أيقونة النشاط
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.event,
                    color: Colors.green,
                    size: 20,
                  ),
                ),
                
                SizedBox(width: 12),
                
                // محتوى النشاط
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                      
                      SizedBox(height: 4),
                      
                      Text(
                        notification.message,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      
                      SizedBox(height: 8),
                      
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.purple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today, size: 12, color: Colors.purple),
                            SizedBox(width: 4),
                            Text(
                              "موعد البدء: ${notification.startTime ?? 'غير محدد'}",
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.purple,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      SizedBox(height: 8),
                      
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 12, color: Colors.grey),
                          SizedBox(width: 4),
                          Text(
                            notification.time,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                          Spacer(),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              "نشاط",
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(BuildContext context, NotificationModel notification) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // تفاصيل الإشعار حسب النوع
            switch (notification.type) {
              case NotificationType.manager:
                _showMessageDetails(context, notification);
                break;
              case NotificationType.homework:
                _showHomeworkDetails(context, notification);
                break;
              case NotificationType.activity:
                _showActivityDetails(context, notification);
                break;
            }
          },
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getNotificationColor(notification.type).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getNotificationIcon(notification.type),
                    color: _getNotificationColor(notification.type),
                    size: 20,
                  ),
                ),
                
                SizedBox(width: 12),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          if (notification.isImportant)
                            Icon(Icons.priority_high, color: Colors.red, size: 16),
                        ],
                      ),
                      
                      SizedBox(height: 4),
                      
                      Text(
                        notification.message,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      SizedBox(height: 8),
                      
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 12, color: Colors.grey),
                          SizedBox(width: 4),
                          Text(
                            notification.time,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                          Spacer(),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: _getNotificationColor(notification.type).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              _getTypeText(notification.type),
                              style: TextStyle(
                                fontSize: 10,
                                color: _getNotificationColor(notification.type),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                if (!notification.isRead)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // الدوال المساعدة
  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.manager:
        return Colors.red;
      case NotificationType.homework:
        return Colors.blue;
      case NotificationType.activity:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.manager:
        return Icons.person;
      case NotificationType.homework:
        return Icons.assignment;
      case NotificationType.activity:
        return Icons.event;
      default:
        return Icons.notifications;
    }
  }

  String _getTypeText(NotificationType type) {
    switch (type) {
      case NotificationType.manager:
        return "مدير";
      case NotificationType.homework:
        return "واجب";
      case NotificationType.activity:
        return "نشاط";
      default:
        return "عام";
    }
  }

  void _showMessageDetails(BuildContext context, NotificationModel message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("رسالة من المدير", style: TextStyle(color: Colors.red)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message.title, style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text(message.message),
            SizedBox(height: 10),
            Text("الوقت: ${message.time}", style: TextStyle(color: Colors.grey)),
          ],
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

  void _showHomeworkDetails(BuildContext context, NotificationModel homework) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("تفاصيل الواجب", style: TextStyle(color: Colors.blue)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(homework.title, style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text(homework.message),
            SizedBox(height: 10),
            Text("موعد التسليم: ${homework.dueDate ?? 'غير محدد'}", 
                 style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
            SizedBox(height: 5),
            Text("الوقت: ${homework.time}", style: TextStyle(color: Colors.grey)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("تم التسليم"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("إلغاء"),
          ),
        ],
      ),
    );
  }

  void _showActivityDetails(BuildContext context, NotificationModel activity) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("تفاصيل النشاط", style: TextStyle(color: Colors.green)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(activity.title, style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text(activity.message),
            SizedBox(height: 10),
            Text("موعد البدء: ${activity.startTime ?? 'غير محدد'}", 
                 style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold)),
            SizedBox(height: 5),
            Text("الوقت: ${activity.time}", style: TextStyle(color: Colors.grey)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("سأحضر"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("إلغاء"),
          ),
        ],
      ),
    );
  }

  void _showClearAllDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("مسح الكل"),
        content: Text("هل تريد مسح جميع الإشعارات؟"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("إلغاء"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("مسح الكل", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showNotificationSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
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
              "إعدادات الإشعارات",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 15),
            _buildSettingSwitch("رسائل المدير", true),
            _buildSettingSwitch("الواجبات الدراسية", true),
            _buildSettingSwitch("الأنشطة المدرسية", true),
            _buildSettingSwitch("الإعلانات العامة", false),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text("حفظ الإعدادات"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingSwitch(String title, bool value) {
    return ListTile(
      title: Text(title),
      trailing: Switch(
        value: value,
        onChanged: (val) {},
        activeColor: Color(0xFF667eea),
      ),
    );
  }
}

// نموذج بيانات الإشعارات المحدث
enum NotificationType { manager, homework, activity }

class NotificationModel {
  final String title;
  final String message;
  final String time;
  final NotificationType type;
  final bool isRead;
  final bool isImportant;
  final String? dueDate;
  final String? startTime;

  NotificationModel({
    required this.title,
    required this.message,
    required this.time,
    required this.type,
    this.isRead = false,
    this.isImportant = false,
    this.dueDate,
    this.startTime,
  });
}

// بيانات تجريبية (نفس البيانات السابقة)
List<NotificationModel> managerMessages = [
  NotificationModel(
    title: "ترتيب الفصول الدراسية",
    message: "يتم ترتيب الفصول الدراسية ابتداء من يوم السبت القادم",
    time: "منذ 5 دقائق",
    type: NotificationType.manager,
    isImportant: true,
  ),
  // ... باقي البيانات
];

List<NotificationModel> homeworkNotifications = [
  NotificationModel(
    title: "واجب الرياضيات",
    message: "حل التمارين من الصفحة 45 إلى 50",
    time: "منذ يوم",
    type: NotificationType.homework,
    dueDate: "2024-03-20",
  ),
  // ... باقي البيانات
];

List<NotificationModel> activityNotifications = [
  NotificationModel(
    title: "رحلة إلى المتحف العلمي",
    message: "رحلة لطلاب الصف العاشر إلى المتحف العلمي",
    time: "منذ ساعتين",
    type: NotificationType.activity,
    startTime: "2024-03-18 الساعة 9:00 صباحاً",
  ),
  // ... باقي البيانات
];