import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

void main() {
  runApp(const TaskTreeApp());
}

class TaskTreeApp extends StatelessWidget {
  const TaskTreeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TaskTree',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const TaskListScreen(),
    );
  }
}

class Task {
  String title;
  bool isCompleted;
  DateTime date;

  Task({required this.title, this.isCompleted = false, required this.date});

  Map<String, dynamic> toJson() => {
    'title': title,
    'isCompleted': isCompleted,
    'date': date.toIso8601String(),
  };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
    title: json['title'],
    isCompleted: json['isCompleted'],
    date: DateTime.parse(json['date']),
  );
}

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  final Map<String, List<Task>> _tasksByDate = {};
  final TextEditingController _taskController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  String _dateKey(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? tasksJson = prefs.getString('tasktree_tasks');
    if (tasksJson != null) {
      final Map<String, dynamic> decoded = jsonDecode(tasksJson);
      setState(() {
        _tasksByDate.clear();
        decoded.forEach((key, value) {
          final List<dynamic> list = value;
          _tasksByDate[key] = list.map((item) => Task.fromJson(item)).toList();
        });
      });
    }
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, dynamic> printableMap = {};
    _tasksByDate.forEach((key, value) {
      printableMap[key] = value.map((task) => task.toJson()).toList();
    });
    await prefs.setString('tasktree_tasks', jsonEncode(printableMap));
  }

  List<Task> _getTasksForDay(DateTime day) {
    return _tasksByDate[_dateKey(day)] ?? [];
  }

  // --- NEW MATH FUNCTION ---
  double _calculateProgress(List<Task> dailyTasks) {
    if (dailyTasks.isEmpty) return 0.0;
    int completed = dailyTasks.where((task) => task.isCompleted).length;
    return completed / dailyTasks.length;
  }

  // --- NEW VISUALIZER WIDGET ---
  Widget _buildTreeVisualizer(List<Task> dailyTasks) {
    final progress = _calculateProgress(dailyTasks);

    IconData treeIcon;
    Color treeColor;
    String statusText;

    if (dailyTasks.isEmpty) {
      treeIcon = Icons.eco_outlined;
      treeColor = Colors.grey;
      statusText = "Plant a task to start growing!";
    } else if (progress == 0) {
      treeIcon = Icons.yard_outlined;
      treeColor = Colors.brown.shade400;
      statusText = "Seeds planted. Get to work!";
    } else if (progress < 1.0) {
      treeIcon = Icons.nature;
      treeColor = Colors.lightGreen;
      statusText = "Your tree is growing! ${(progress * 100).toInt()}%";
    } else {
      treeIcon = Icons.park;
      treeColor = Colors.green;
      statusText = "Magnificent! All tasks completed.";
    }

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: treeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: treeColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(treeIcon, size: 48, color: treeColor),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              statusText,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _addTask(String title) {
    if (title.trim().isEmpty) return;

    final key = _dateKey(_selectedDay);
    final newTask = Task(
      title: title,
      date: DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day),
    );

    setState(() {
      if (_tasksByDate[key] != null) {
        _tasksByDate[key]!.add(newTask);
      } else {
        _tasksByDate[key] = [newTask];
      }
    });

    _saveTasks();
    _taskController.clear();
    Navigator.pop(context);
  }

  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Add Task for ${_selectedDay.day}/${_selectedDay.month}/${_selectedDay.year}',
        ),
        content: TextField(
          controller: _taskController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter task description...',
          ),
          onSubmitted: (value) => _addTask(value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _addTask(_taskController.text),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentTasks = _getTasksForDay(_selectedDay);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'TaskTree',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            children: [
              TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                eventLoader: (day) => _getTasksForDay(day),
                onDaySelected: (selectedDay, focusedDay) {
                  if (!isSameDay(_selectedDay, selectedDay)) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  }
                },
                onFormatChanged: (format) {
                  if (_calendarFormat != format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  }
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
                calendarStyle: const CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Colors.greenAccent,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: BoxDecoration(
                    color: Colors.darkGreen,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const Divider(),

              // --- VISUALIZER ADDED HERE ---
              _buildTreeVisualizer(currentTasks),

              Expanded(
                child: currentTasks.isEmpty
                    ? const Center(
                        child: Text('No tasks scheduled for this day!'),
                      )
                    : ListView.builder(
                        itemCount: currentTasks.length,
                        itemBuilder: (context, index) {
                          final task = currentTasks[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            child: ListTile(
                              leading: Checkbox(
                                value: task.isCompleted,
                                onChanged: (value) {
                                  setState(() {
                                    task.isCompleted = value ?? false;
                                  });
                                  _saveTasks();
                                },
                              ),
                              title: Text(
                                task.title,
                                style: TextStyle(
                                  decoration: task.isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  setState(() {
                                    currentTasks.removeAt(index);
                                  });
                                  _saveTasks();
                                },
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
