class Assignment {
  final int id;
  final String title;
  final String teacherName;
  final String className;
  final String section;
  final String subject;
  final String description;
  final String? fileName;
  final String priority;
  final String createdAt;
  final bool isCompleted;

  Assignment({
    required this.id,
    required this.title,
    required this.teacherName,
    required this.className,
    required this.section,
    required this.subject,
    required this.description,
    this.fileName,
    required this.priority,
    required this.createdAt,
    required this.isCompleted,
  });

  factory Assignment.fromMap(Map<String, dynamic> map) {
    return Assignment(
      id: map['id'],
      title: map['title'],
      teacherName: map['teacher_name'],
      className: map['class_name'],
      section: map['section'],
      subject: map['subject'],
      description: map['description'] ?? '',
      fileName: map['assignment_file_path'],
      priority: map['priority'] ?? 'متوسط',
      createdAt: map['created_at'],
      isCompleted: map['completed'] == 1 || map['completed'] == true,
    );
  }

  Assignment copyWith({bool? isCompleted}) {
    return Assignment(
      id: id,
      title: title,
      teacherName: teacherName,
      className: className,
      section: section,
      subject: subject,
      description: description,
      fileName: fileName,
      priority: priority,
      createdAt: createdAt,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
