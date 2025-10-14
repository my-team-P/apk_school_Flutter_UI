import 'package:flutter/material.dart';
import 'package:admin/models/my_files.dart';
import '../../../constants.dart';
import 'file_info_card.dart';

class MyFiles extends StatelessWidget {
  const MyFiles({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          // children: [
          //   Text(
          //     "معرض الصور المدرسية",
          //     style: Theme.of(context).textTheme.titleMedium?.copyWith(
          //           fontSize: 17,
          //           fontWeight: FontWeight.bold,
          //           color: Color(0xFF5D4037), // بني غامق
          //           fontFamily: 'Tajawal',
          //         ),
          //   ),
          //   ElevatedButton.icon(
          //     style: TextButton.styleFrom(
          //       backgroundColor: Color(0xFF8B7355), // بني متوسط
          //       padding: EdgeInsets.symmetric(
          //         horizontal: defaultPadding * 1.5,
          //         vertical:
          //             defaultPadding / (Responsive.isMobile(context) ? 2 : 1),
          //       ),
          //       shape: RoundedRectangleBorder(
          //         borderRadius: BorderRadius.circular(8),
          //       ),
          //     ),
          //     onPressed: () {},
          //     icon: const Icon(Icons.add_photo_alternate, color: Colors.white),
          //     label: const Text("إضافة صورة جديدة",
          //         style: TextStyle(color: Colors.white, fontFamily: 'Tajawal')),
          //   ),
          // ],
        ),
        const SizedBox(height: defaultPadding),

        // معرض الصور الأفقية
        HorizontalImageGallery(),

        const SizedBox(height: defaultPadding * 2),

        // النص التوضيحي
      ],
    );
  }
  
}

// معرض الصور الأفقية
class HorizontalImageGallery extends StatelessWidget {
  final List<String> imagePaths = [
    'assets/images/17570498857827.png',
    'assets/images/17570498857827.png',
    'assets/images/17570498857827.png',
    'assets/images/17570498857827.png',
    'assets/images/17570498857827.png',
    'assets/images/17570498857827.png',
    'assets/images/17570498857827.png',
    'assets/images/17570498857827.png',
  ];

  final List<String> imageTitles = [
    'دورة الحاسوب',
    'مسابقة القراءة',
    'الورشة الفنية',
    'اليوم الرياضي',
    'حفل التخرج',
    'رحلة علمية',
    'معرض الإبداع',
    'أنشطة تطوعية',
  ];

  HorizontalImageGallery({super.key});



  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: imagePaths.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              // يمكن إضافة نافذة منبثقة أو تكبير الصورة عند الضغط
            },
            child: Container(
              width: 160,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [Colors.orange.shade100, Colors.yellow.shade100],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 6,
                    offset: const Offset(2, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      imagePaths[index],
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child:
                                Icon(Icons.error, color: Colors.red, size: 40),
                          ),
                        );
                      },
                    ),
                  ),
                  // تراكب نص على الصورة
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 6, horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                      ),
                      child: Text(
                        imageTitles[index],
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class FileInfoCardGridView extends StatelessWidget {
  const FileInfoCardGridView({
    super.key,
    this.crossAxisCount = 4,
    this.childAspectRatio = 1,
  });

  final int crossAxisCount;
  final double childAspectRatio;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: demoMyFiles.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: defaultPadding,
        mainAxisSpacing: defaultPadding,
        childAspectRatio: childAspectRatio,
      ),
      itemBuilder: (context, index) => FileInfoCard(info: demoMyFiles[index]),
    );
    
  }
  
}

