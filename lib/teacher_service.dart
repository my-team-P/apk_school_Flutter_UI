// lib/teacher_service.dart
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TeacherService {
  // روابط الـ API - اختر المناسب حسب جهازك
  static const String baseUrl =
      'http://192.168.1.107:8000/api/teachers'; // لـ Android Emulator
  // static const String baseUrl = 'http://localhost:8000/api'; // لـ iOS Simulator
  // static const String baseUrl = 'http://192.168.1.107:8000/api'; // لـ جهاز حقيقي - استبدل 192.168.1.100 بـ IP خادمك

  Future<bool> addTeacher(Map<String, dynamic> teacherData, File? image) async {
    try {
      print('📤 جاري إرسال بيانات المعلم إلى السيرفر...');
      print('📊 البيانات: $teacherData');

      // إنشاء طلب multipart لإرسال النص والصور
      var request = http.MultipartRequest('POST', Uri.parse(baseUrl));

      // إضافة رؤوس الطلب (اختياري)
      request.headers['Accept'] = 'application/json';
      request.headers['User-Agent'] = 'Flutter-App';

      // إضافة البيانات النصية
      teacherData.forEach((key, value) {
        if (value != null && value.toString().isNotEmpty) {
          request.fields[key] = value.toString();
          print('✅ إضافة حقل: $key = $value');
        }
      });

      // إضافة الصورة إذا كانت موجودة
      if (image != null && await image.exists()) {
        print('🖼️ جاري إضافة الصورة: ${image.path}');
        try {
          var multipartFile = await http.MultipartFile.fromPath(
            'photo_url', // يجب أن يتطابق مع اسم الحقل في Laravel
            image.path,
            filename: 'teacher_${DateTime.now().millisecondsSinceEpoch}.jpg',
          );
          request.files.add(multipartFile);
          print('✅ تم إضافة الصورة بنجاح');
        } catch (e) {
          print('❌ خطأ في إضافة الصورة: $e');
        }
      } else {
        print('ℹ️ لا توجد صورة مرفوعة');
      }

      print('🔄 جاري إرسال الطلب إلى: $baseUrl');

      // إرسال الطلب وانتظار الرد
      var response = await request.send();
      var responseString = await response.stream.bytesToString();

      print('📥 حالة الاستجابة: ${response.statusCode}');
      print('📄 محتوى الاستجابة: $responseString');

      // تحليل الرد
      if (response.statusCode == 201 || response.statusCode == 200) {
        print('✅ تم إضافة المعلم بنجاح في قاعدة البيانات');
        return true;
      } else if (response.statusCode == 422) {
        // خطأ في التحقق من البيانات
        print('❌ خطأ في التحقق من البيانات (422)');
        var errorResponse = json.decode(responseString);
        print('🔍 تفاصيل الخطأ: $errorResponse');
        return false;
      } else if (response.statusCode == 500) {
        // خطأ في السيرفر
        print('❌ خطأ داخلي في السيرفر (500)');
        return false;
      } else {
        print('❌ خطأ غير متوقع: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ استثناء في TeacherService: $e');
      print('🔍 نوع الخطأ: ${e.runtimeType}');

      // معالجة أنواع الأخطاء المختلفة
      if (e is SocketException) {
        print('🌐 خطأ في الاتصال بالشبكة - تأكد من تشغيل خادم Laravel');
      } else if (e is HttpException) {
        print('🌐 خطأ في طلب HTTP');
      } else if (e is FormatException) {
        print('📝 خطأ في تنسيق البيانات');
      }

      return false;
    }
  }

  // دالة مساعدة لاختبار الاتصال بالسيرفر
  Future<bool> testConnection() async {
    try {
      var response = await http.get(Uri.parse('$baseUrl/test'));
      return response.statusCode == 200;
    } catch (e) {
      print('❌ فشل اختبار الاتصال: $e');
      return false;
    }
  }

  // دالة لجلب قائمة المعلمين (للتوسع المستقبلي)
  Future<List<dynamic>> getTeachers() async {
    try {
      var response = await http.get(Uri.parse('$baseUrl/teachers'));

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        return data['teachers'] ?? [];
      } else {
        print('❌ خطأ في جلب البيانات: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ استثناء في جلب المعلمين: $e');
      return [];
    }
  }

  // دالة تسجيل دخول المعلم
  Future<bool> loginTeacher(
      String fullName, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'full_name': fullName,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      } else {
        print('❌ خطأ في تسجيل الدخول: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ استثناء أثناء تسجيل الدخول: $e');
      return false;
    }
  }
}
