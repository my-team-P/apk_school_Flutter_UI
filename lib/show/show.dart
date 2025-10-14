import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:admin/screens/main/main_screen.dart';

class PeoplePage extends StatefulWidget {
  final String role;

  const PeoplePage({super.key, required this.role});

  @override
  PeoplePageState createState() => PeoplePageState();
}

class PeoplePageState extends State<PeoplePage> {
  List people = [];
  bool isLoading = true;
  String selectedType = 'teachers'; // القيمة الافتراضية

  @override
  void initState() {
    super.initState();
    fetchPeople();
  }

  Future<void> fetchPeople() async {
    setState(() {
      isLoading = true;
    });

    String apiUrl = selectedType == 'teachers'
        ? 'http://192.168.1.102:8000/api/teachers'
        : 'http://192.168.1.102:8000/api/students';

    try {
      final url = Uri.parse(apiUrl);
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        if (decoded is Map && decoded.containsKey('data')) {
          people = decoded['data'];
        } else if (decoded is Map && decoded.containsKey('teachers')) {
          people = decoded['teachers'];
        } else if (decoded is Map && decoded.containsKey('students')) {
          people = decoded['students'];
        } else if (decoded is List) {
          people = decoded;
        } else {
          people = [decoded];
        }

        setState(() {
          isLoading = false;
        });
      } else {
        print('Failed to load $selectedType: ${response.statusCode}');
        print('Response body: ${response.body}');
        setState(() {
          isLoading = false;
          people = [];
        });
      }
    } catch (e) {
      print('Error fetching $selectedType: $e');
      setState(() {
        isLoading = false;
        people = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المعلمين والطلاب'),
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
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButton<String>(
              value: selectedType,
              items: const [
                DropdownMenuItem(
                    value: 'teachers',
                    child: Text('المعلمين',
                        style: TextStyle(color: Colors.white))),
                DropdownMenuItem(
                    value: 'students',
                    child:
                        Text('الطلاب', style: TextStyle(color: Colors.white))),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedType = value;
                  });
                  fetchPeople();
                }
              },
              underline: const SizedBox(),
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
              dropdownColor: Colors.blue,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : people.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  itemCount: people.length,
                  itemBuilder: (context, index) {
                    final person = people[index];
                    return selectedType == 'teachers'
                        ? _buildTeacherCard(person)
                        : _buildStudentCard(person);
                  },
                ),
    );
  }

  // واجهة فارغة عند عدم وجود بيانات
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('لا توجد بيانات',
              style: TextStyle(fontSize: 18, color: Colors.grey[600])),
          const SizedBox(height: 8),
          Text(
            selectedType == 'teachers'
                ? 'لا توجد بيانات للمعلمين'
                : 'لا توجد بيانات للطلاب',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  // بطاقة المعلم
  Widget _buildTeacherCard(Map<String, dynamic> teacher) {
    return Card(
      margin: const EdgeInsets.all(8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue[700],
          child: Text(
            (teacher['full_name'] ?? '??')
                .toString()
                .split(' ')
                .map((e) => e.isNotEmpty ? e[0] : '')
                .take(2)
                .join(),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          teacher['full_name'] ?? 'غير معروف',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            _buildInfoRow('التخصص', teacher['specialization']),
            _buildInfoRow('الهاتف', teacher['phone']),
            _buildInfoRow('الإيميل', teacher['email']),
            _buildInfoRow('تاريخ التوظيف', teacher['hire_date']),
            _buildInfoRow('الراتب', teacher['salary']?.toString()),
            _buildInfoRow('المؤهل', teacher['qualification']),
          ],
        ),
        trailing: Icon(Icons.school, color: Colors.blue[700]),
      ),
    );
  }

  // بطاقة الطالب
  Widget _buildStudentCard(Map<String, dynamic> student) {
    return Card(
      margin: const EdgeInsets.all(8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green[700],
          child: Text(
            (student['name'] ?? '??')
                .toString()
                .split(' ')
                .map((e) => e.isNotEmpty ? e[0] : '')
                .take(2)
                .join(),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          student['name'] ?? 'غير معروف',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            _buildInfoRow('الإيميل', student['email']),
            _buildInfoRow('الصف', student['grade'] ?? student['class_name']),
            _buildInfoRow('الهاتف', student['phone']),
            _buildInfoRow('العنوان', student['address']),
          ],
        ),
        trailing: Icon(Icons.person, color: Colors.green[700]),
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: RichText(
        text: TextSpan(
          style: TextStyle(color: Colors.grey[700], fontSize: 12),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}
