import 'dart:convert';

class ToDo {
  String? id;
  String? todoText;
  bool isDone;
  DateTime? createTime;

  ToDo({
    required this.id,
    required this.todoText,
    this.isDone = false,
    this.createTime,
  });

  factory ToDo.fromJson(String todoJson) {
    final Map<String, dynamic> json = jsonDecode(todoJson);
    return ToDo(
      id: json['id'],
      todoText: json['todoText'],
      isDone: json['isDone'] ?? false,
      createTime: json['createTime'] != null
        ? DateTime.parse(json['createTime'])
        : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'todoText': todoText,
      'isDone': isDone,
      'createTime': createTime?.toIso8601String(),
    };
  }

  static List<ToDo> todoList() {
    return [
      ToDo(id: '01', todoText: "Start Typing your first task"),
    ];
  }
}
