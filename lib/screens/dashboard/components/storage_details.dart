import 'package:flutter/material.dart';
import '../../../constants.dart';

class SchoolNews extends StatelessWidget {
  const SchoolNews({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.fromARGB(255, 255, 255, 255), // لون الشعار الأساسي
            Color(0xFFF8F0E5), // فاتح قليلاً
            Color(0xFFF6E6CC), // لون الشعار الأساسي
          ],
        ),
        borderRadius: BorderRadius.all(Radius.circular(15)),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF8B7355).withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Color(0xFFD4C0A1).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Color(0xFF8B7355).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Color(0xFF8B7355).withOpacity(0.3)),
                ),
                child:
                    Icon(Icons.newspaper, color: Color(0xFF5D4037), size: 24),
              ),
              SizedBox(width: 12),
              Text(
                "الأخبار المدرسية",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5D4037),
                  fontFamily: 'Tajawal',
                ),
              ),
            ],
          ),
          const SizedBox(height: defaultPadding),

          // خبر دورة قيادة الحاسوب
          NewsCard(
            icon: Icons.computer,
            title: "دورة قيادة الحاسوب",
            teacher: "المعلم: أحمد محمد",
            price: "50 ريال",
            description:
                "دورة متخصصة لتعليم الطلاب أساسيات استخدام الحاسوب، تشمل:\n• التعامل مع نظام التشغيل\n• برامج الأوفيس الأساسية\n• البحث الآمن على الإنترنت\n• أساسيات البرمجة للمبتدئين",
            date: "تبدأ من 15 مارس 2024",
            cardColor: LinearGradient(
              colors: [
                Color(0xFFE8D5B5), // بيج فاتح
                Color(0xFFD4C0A1), // بيج متوسط
              ],
            ),
            iconColor: Color(0xFF4A6572), // أزرق رمادي
            textColor: Color(0xFF5D4037), // بني غامق
          ),

          const SizedBox(height: defaultPadding),

          // خبر ورشة الإبداع الفني
          NewsCard(
            icon: Icons.brush,
            title: "ورشة الإبداع الفني",
            teacher: "المعلمة: فاطمة عبدالله",
            price: "30 ريال",
            description:
                "ورشة فنية لتنمية مواهب الطلاب في:\n• الرسم والتلوين\n• الأعمال اليدوية\n• التصميم الإبداعي\n• استخدام التقنية في الفن",
            date: "كل يوم ثلاثاء",
            cardColor: LinearGradient(
              colors: [
                Color(0xFFD4C0A1), // بيج متوسط
                Color(0xFFB8A189), // بيج غامق قليلاً
              ],
            ),
            iconColor: Color(0xFF7B1FA2), // بنفسجي
            textColor: Color(0xFF5D4037),
          ),

          const SizedBox(height: defaultPadding),

          // خبر مسابقة القراءة
          NewsCard(
            icon: Icons.menu_book,
            title: "مسابقة القراءة المدرسية",
            teacher: "المشرف: خالد إبراهيم",
            price: "مجانية",
            description:
                "مسابقة لتعزيز حب القراءة لدى الطلاب:\n• قراءة 10 كتب خلال الفصل\n• مناقشة الكتب مع الزملاء\n• جوائز قيمة للفائزين\n• شهادات مشاركة للجميع",
            date: "طوال الفصل الدراسي",
            cardColor: LinearGradient(
              colors: [
                Color(0xFFF8F0E5), // بيج فاتح جداً
                Color(0xFFE8D5B5), // بيج فاتح
              ],
            ),
            iconColor: Color(0xFF2E7D32), // أخضر
            textColor: Color(0xFF5D4037),
          ),
        ],
      ),
    );
  }
}

class NewsCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String teacher;
  final String price;
  final String description;
  final String date;
  final Gradient cardColor;
  final Color iconColor;
  final Color textColor;

  const NewsCard({
    super.key,
    required this.icon,
    required this.title,
    required this.teacher,
    required this.price,
    required this.description,
    required this.date,
    required this.cardColor,
    required this.iconColor,
    required this.textColor,
  });

  @override
  State<NewsCard> createState() => _NewsCardState();
}

class _NewsCardState extends State<NewsCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: widget.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF8B7355).withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Color(0xFFD4C0A1).withOpacity(0.4),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // الصف العلوي (العنوان، التاريخ، الأيقونة)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // الأيقونة
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: widget.iconColor.withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
                child: Icon(widget.icon, color: widget.iconColor, size: 28),
              ),

              const SizedBox(width: 12),

              // العنوان والتاريخ
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: widget.textColor,
                        fontFamily: 'Tajawal',
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: Color(0xFFD4C0A1).withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.calendar_today,
                              size: 14,
                              color: widget.textColor.withOpacity(0.7)),
                          const SizedBox(width: 4),
                          Text(
                            widget.date,
                            style: TextStyle(
                              fontSize: 12,
                              color: widget.textColor.withOpacity(0.8),
                              fontFamily: 'Tajawal',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // أيقونة التوسيع/الطي
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: widget.textColor.withOpacity(0.2),
                    ),
                  ),
                  child: AnimatedRotation(
                    duration: Duration(milliseconds: 300),
                    turns: _isExpanded ? 0.5 : 0,
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: widget.textColor.withOpacity(0.7),
                      size: 22,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // التفاصيل (تظهر عند النقر على الأيقونة)
          if (_isExpanded) ...[
            const SizedBox(height: 16),
            Divider(
                color: Color(0xFFD4C0A1).withOpacity(0.3),
                height: 1,
                thickness: 1),
            const SizedBox(height: 16),

            // معلومات الأساسية
            Row(
              children: [
                _buildInfoText(
                  widget.teacher,
                  Icons.person,
                  Color(0xFF4A6572), // أزرق رمادي
                  widget.textColor,
                ),
                const SizedBox(width: 20),
                _buildInfoText(
                  widget.price,
                  Icons.attach_money,
                  Color(0xFF2E7D32), // أخضر
                  widget.textColor,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // الوصف
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Color(0xFFD4C0A1).withOpacity(0.3),
                ),
              ),
              child: Text(
                widget.description,
                style: TextStyle(
                  fontSize: 14,
                  color: widget.textColor.withOpacity(0.9),
                  height: 1.5,
                  fontFamily: 'Tajawal',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoText(
      String text, IconData icon, Color iconColor, Color textColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Color(0xFFD4C0A1).withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: textColor.withOpacity(0.9),
              fontWeight: FontWeight.w500,
              fontFamily: 'Tajawal',
            ),
          ),
        ],
      ),
    );
  }
}
