import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:admin/provider/assignments_provider.dart';
import 'package:admin/models/assignment.dart';

class ConfirmAssignmentPage extends ConsumerStatefulWidget {
  final Assignment assignment;
  const ConfirmAssignmentPage({super.key, required this.assignment});

  @override
  ConsumerState<ConfirmAssignmentPage> createState() =>
      _ConfirmAssignmentPageState();
}

class _ConfirmAssignmentPageState extends ConsumerState<ConfirmAssignmentPage> {
  File? selectedFile;
  String? fileName;
  final TextEditingController _descController = TextEditingController();
  bool isSending = false;

  // التحقق من إمكانية التسليم
  bool get canSubmit {
    return _descController.text.trim().isNotEmpty || selectedFile != null;
  }

  // اختيار الملف
  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'png', 'zip'],
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        fileName = result.files.single.name;
        selectedFile = File(result.files.single.path!);
      });
    }
  }

  void _removeFile() {
    setState(() {
      selectedFile = null;
      fileName = null;
    });
  }

  // رفع التكليف
  Future<void> submitAssignment() async {
    if (!canSubmit) return;

    setState(() => isSending = true);
    final notifier = ref.read(assignmentsProvider.notifier);

    try {
      await notifier.submitAssignment(
        widget.assignment.id,
        notes: _descController.text.trim(),
        submissionFile: selectedFile,
      );

      setState(() => isSending = false);
      _showSuccessDialog();
    } catch (e) {
      setState(() => isSending = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('حدث خطأ أثناء التسليم: $e')));
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: MediaQuery.of(context).size.width * 0.15,
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              Text(
                'تم التسليم بنجاح',
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width * 0.045,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.015),
              Text(
                'تم تسليم التكليف وسيتم مراجعته من قبل المعلم',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width * 0.035,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.025),
              SizedBox(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.06,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'حسناً',
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width * 0.04,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _descController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final assignment = widget.assignment;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 600;

    // حسابات متجاوبة
    final basePadding = screenWidth * 0.04;
    final smallPadding = screenWidth * 0.02;
    final largePadding = screenWidth * 0.06;
    final fontExtraSmall = screenWidth * 0.03;
    final fontSmall = screenWidth * 0.035;
    final fontMedium = screenWidth * 0.04;
    final fontLarge = screenWidth * 0.05;
    final fontExtraLarge = screenWidth * 0.055;
    final buttonHeight = screenHeight * 0.065;
    final iconSize = screenWidth * 0.06;
    final cardRadius = screenWidth * 0.04;

    return Directionality(
      textDirection: TextDirection.rtl, // 👈 من اليمين إلى اليسار
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: Text(
            'تسليم التكليف',
            style: TextStyle(fontSize: fontLarge, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(cardRadius),
            ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.all(basePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // بطاقة معلومات التكليف
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(largePadding),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue[50]!, Colors.lightBlue[50]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(cardRadius),
                    border: Border.all(color: Colors.blue[100]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(screenWidth * 0.03),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.assignment,
                              color: Colors.white,
                              size: iconSize,
                            ),
                          ),
                          SizedBox(width: basePadding),
                          Expanded(
                            child: Text(
                              assignment.title,
                              style: TextStyle(
                                fontSize: fontLarge,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[900],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      _buildInfoRow(
                        Icons.person,
                        'المعلم',
                        assignment.teacherName,
                        screenWidth,
                        fontMedium,
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      _buildInfoRow(
                        Icons.menu_book,
                        'المادة',
                        assignment.subject,
                        screenWidth,
                        fontMedium,
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      _buildInfoRow(
                        Icons.school,
                        'الصف',
                        '${assignment.className} - ${assignment.section}',
                        screenWidth,
                        fontMedium,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: screenHeight * 0.03),

                // قسم الملاحظات
                Container(
                  padding: EdgeInsets.all(largePadding),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(cardRadius),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.description,
                            color: Colors.blue,
                            size: iconSize,
                          ),
                          SizedBox(width: smallPadding),
                          Text(
                            'ملاحظات الطالب',
                            style: TextStyle(
                              fontSize: fontLarge,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[900],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.015),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(cardRadius * 0.8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: TextField(
                          controller: _descController,
                          maxLines: 4,
                          style: TextStyle(fontSize: fontMedium),
                          decoration: InputDecoration(
                            hintText: 'اكتب ملاحظاتك حول التكليف هنا...',
                            hintStyle: TextStyle(
                              fontSize: fontMedium,
                              color: Colors.grey[500],
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(basePadding),
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      Text(
                        'يجب كتابة الملاحظات أو رفع ملف لتتمكن من التسليم',
                        style: TextStyle(
                          fontSize: fontSmall,
                          color: Colors.orange[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: screenHeight * 0.03),

                // قسم رفع الملف
                Container(
                  padding: EdgeInsets.all(largePadding),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(cardRadius),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.attach_file,
                            color: Colors.blue,
                            size: iconSize,
                          ),
                          SizedBox(width: smallPadding),
                          Text(
                            'رفع ملف (اختياري)',
                            style: TextStyle(
                              fontSize: fontLarge,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[900],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.015),
                      if (fileName != null)
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(basePadding),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(
                              cardRadius * 0.8,
                            ),
                            border: Border.all(color: Colors.green),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: iconSize,
                              ),
                              SizedBox(width: basePadding),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      fileName!,
                                      style: TextStyle(
                                        fontSize: fontMedium,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green[800],
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: screenHeight * 0.005),
                                    Text(
                                      'تم اختيار الملف بنجاح',
                                      style: TextStyle(
                                        fontSize: fontSmall,
                                        color: Colors.green[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                  size: iconSize,
                                ),
                                onPressed: _removeFile,
                              ),
                            ],
                          ),
                        )
                      else
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(largePadding),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(
                              cardRadius * 0.8,
                            ),
                            border: Border.all(
                              color: Colors.grey[400]!,
                              // style: BorderStyle.dashed,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.cloud_upload,
                                color: Colors.grey[500],
                                size: iconSize * 1.5,
                              ),
                              SizedBox(height: screenHeight * 0.01),
                              Text(
                                'انقر لاختيار ملف',
                                style: TextStyle(
                                  fontSize: fontMedium,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      SizedBox(height: screenHeight * 0.015),
                      SizedBox(
                        width: double.infinity,
                        height: buttonHeight * 0.8,
                        child: OutlinedButton.icon(
                          onPressed: pickFile,
                          icon: Icon(Icons.upload_file, size: iconSize),
                          label: Text(
                            fileName == null ? 'اختيار ملف' : 'تغيير الملف',
                            style: TextStyle(fontSize: fontMedium),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.blue,
                            side: BorderSide(color: Colors.blue),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                cardRadius * 0.8,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      Text(
                        'الملفات المسموحة: PDF, DOC, JPG, PNG, ZIP',
                        style: TextStyle(
                          fontSize: fontSmall,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: screenHeight * 0.04),

                // زر التسليم
                Container(
                  width: double.infinity,
                  height: buttonHeight,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(cardRadius),
                    boxShadow: [
                      if (canSubmit && !isSending)
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed:
                        canSubmit && !isSending ? submitAssignment : null,
                    icon: isSending
                        ? SizedBox(
                            width: iconSize * 0.8,
                            height: iconSize * 0.8,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          )
                        : Icon(Icons.send, size: iconSize),
                    label: Text(
                      isSending ? 'جاري التسليم...' : 'تسليم التكليف',
                      style: TextStyle(
                        fontSize: fontLarge,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          canSubmit ? Colors.blue : Colors.grey[400],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(cardRadius),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: screenHeight * 0.02),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value,
    double screenWidth,
    double fontSize,
  ) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue[700], size: screenWidth * 0.05),
        SizedBox(width: screenWidth * 0.02),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.blue[800],
          ),
        ),
        Text(
          value,
          style: TextStyle(fontSize: fontSize, color: Colors.grey[700]),
        ),
      ],
    );
  }
}
