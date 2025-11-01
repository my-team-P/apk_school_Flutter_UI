import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:admin/models/assignment.dart';

class AssignmentsNotifier extends StateNotifier<List<Assignment>> {
  
  AssignmentsNotifier() : super([]) {
    loadAssignments();
  }

  final String baseUrl = 'http://192.168.1.101:8000/api'; // رابط الـ API

  Future<void> loadAssignments() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/assignments'));
      if (response.statusCode == 200) {
        final List decoded = jsonDecode(response.body);
        state = decoded.map((e) => Assignment.fromMap(e)).toList();
      } else {
        state = [];
      }
    } catch (e) {
      state = [];
      print('Error loading assignments: $e');
    }
  }

  Future<void> submitAssignment(
    int id, {
    String? notes,
    File? submissionFile,
  }) async {
    try {
      var uri = Uri.parse('$baseUrl/assignments/$id/submit');
      var request = http.MultipartRequest('POST', uri);
      if (notes != null) request.fields['student_notes'] = notes;
      if (submissionFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'submission_file',
            submissionFile.path,
          ),
        );
      }

      final response = await request.send();

      if (response.statusCode == 200) {
        state = [
          for (final a in state)
            if (a.id == id) a.copyWith(isCompleted: true) else a,
        ];
      } else {
        print('Failed to submit assignment: ${response.statusCode}');
      }
    } catch (e) {
      print('Error submitting assignment: $e');
    }
  }
}

final assignmentsProvider =
    StateNotifierProvider<AssignmentsNotifier, List<Assignment>>(
      (ref) => AssignmentsNotifier(),
    );
