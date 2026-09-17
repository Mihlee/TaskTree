import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

void main() {
  runApp(const TaskTreeApp());
}

class TaskTreeApp extends StatefulWidget {
  const TaskTreeApp({super.key});

  @override
  State<TaskTreeApp> createState() => _TaskTreeAppState();
}

class _TaskTreeAppState extends State<TaskTreeApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    const primarySeed = Color(0xFF10B981); // Emerald Green

    return MaterialApp(
      title: 'TaskTree Board',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primarySeed,
          brightness: Brightness.light,
          surface: const Color(0xFFF8FAFC),
        ),
        scaffoldBackgroundColor: const Color(0xFFF1F5F9),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primarySeed,
          brightness: Brightness.dark,
          surface: const Color(0xFF1E293B),
        ),
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFF334155)),
          ),
        ),
      ),
      home: MainNavigationScreen(
        onToggleTheme: _toggleTheme,
        isDarkMode: _themeMode == ThemeMode.dark,
      ),
    );
  }
}

class Task {
  String id;
  String title;
  String description;
  bool isCompleted;
  DateTime date;
  String category;
  String priority;

  Task({
    required this.id,
    required this.title,
    this.description = '',
    this.isCompleted = false,
    required this.date,
    this.category = 'Personal',
    this.priority = 'Medium',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'isCompleted': isCompleted,
        'date': date.toIso8601String(),
        'category': category,
        'priority': priority,
      };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: json['title'],
        description: json['description'] ?? '',
        isCompleted: json['isCompleted'],
        date: DateTime.parse(json['date']),
        category: json['category'] ?? 'Personal',
        priority: json['priority'] ?? 'Medium',
      );
}

class MainNavigationScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isDarkMode;

  const MainNavigationScreen({
    super.key,
    required this.onToggleTheme,
    required this.isDarkMode,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;
  final Map<String, List<Task>> _tasksByDate = {};
  List<String> _categories = ['Personal', 'Work', 'Study', 'Health'];

  @override
  void initState() {
    super.initState();
    _loadTasks();
    _loadCategories();
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

  Future<void> _loadCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? cats = prefs.getStringList('tasktree_categories');
    if (cats != null && cats.isNotEmpty) {
      setState(() {
        _categories = cats;
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

  Future<void> _addCategory(String newCat) async {
    if (newCat.trim().isEmpty || _categories.contains(newCat.trim())) return;
    setState(() {
      _categories.add(newCat.trim());
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('tasktree_categories', _categories);
  }

  void _showBackupDialog() {
    final importController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Data Backup & Restore'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.copy, color: Color(0xFF10B981)),
                title: const Text('Export Backup JSON'),
                subtitle: const Text('Copy all tasks to your clipboard'),
                onTap: () {
                  final Map<String, dynamic> printableMap = {};
                  _tasksByDate.forEach((key, value) {
                    printableMap[key] = value.map((task) => task.toJson()).toList();
                  });
                  final jsonStr = jsonEncode(printableMap);
                  Clipboard.setData(ClipboardData(text: jsonStr));
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Backup copied to clipboard!'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              const Divider(),
              const SizedBox(height: 8),
              TextField(
                controller: importController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Restore JSON Data',
                  hintText: 'Paste raw JSON backup here...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final raw = importController.text.trim();
                if (raw.isNotEmpty) {
                  try {
                    final Map<String, dynamic> decoded = jsonDecode(raw);
                    setState(() {
                      _tasksByDate.clear();
                      decoded.forEach((key, value) {
                        final List<dynamic> list = value;
                        _tasksByDate[key] =
                            list.map((item) => Task.fromJson(item)).toList();
                      });
                    });
                    _saveTasks();
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Tasks restored successfully!'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Invalid JSON backup string.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Restore Data'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      TaskWorkspaceView(
        tasksByDate: _tasksByDate,
        categories: _categories,
        dateKey: _dateKey,
        saveTasks: _saveTasks,
        addCategory: _addCategory,
        onToggleTheme: widget.onToggleTheme,
        isDarkMode: widget.isDarkMode,
      ),
      ForestAnalyticsView(
        tasksByDate: _tasksByDate,
        onToggleTheme: widget.onToggleTheme,
        isDarkMode: widget.isDarkMode,
        onOpenBackup: _showBackupDialog,
      ),
    ];

    return Scaffold(
      body: screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Workspace',
          ),
          NavigationDestination(
            icon: Icon(Icons.park_outlined),
            selectedIcon: Icon(Icons.park),
            label: 'Forest & Stats',
          ),
        ],
      ),
    );
  }
}

class TaskWorkspaceView extends StatefulWidget {
  final Map<String, List<Task>> tasksByDate;
  final List<String> categories;
  final String Function(DateTime) dateKey;
  final Future<void> Function() saveTasks;
  final Future<void> Function(String) addCategory;
  final VoidCallback onToggleTheme;
  final bool isDarkMode;

  const TaskWorkspaceView({
    super.key,
    required this.tasksByDate,
    required this.categories,
    required this.dateKey,
    required this.saveTasks,
    required this.addCategory,
    required this.onToggleTheme,
    required this.isDarkMode,
  });

  @override
  State<TaskWorkspaceView> createState() => _TaskWorkspaceViewState();
}

class _TaskWorkspaceViewState extends State<TaskWorkspaceView> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  String _selectedCategoryFilter = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  List<Task> _getTasksForDay(DateTime day) {
    return widget.tasksByDate[widget.dateKey(day)] ?? [];
  }

  double _calculateProgress(List<Task> dailyTasks) {
    if (dailyTasks.isEmpty) return 0.0;
    int completed = dailyTasks.where((task) => task.isCompleted).length;
    return completed / dailyTasks.length;
  }

  int _calculateStreak() {
    int streak = 0;
    DateTime checkDate = DateTime.now();

    while (true) {
      final key = widget.dateKey(checkDate);
      final tasks = widget.tasksByDate[key] ?? [];

      if (tasks.isNotEmpty && tasks.every((t) => t.isCompleted)) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        if (streak == 0 && isSameDay(checkDate, DateTime.now())) {
          checkDate = checkDate.subtract(const Duration(days: 1));
          continue;
        }
        break;
      }
    }
    return streak;
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Work':
        return const Color(0xFF3B82F6);
      case 'Study':
        return const Color(0xFFF59E0B);
      case 'Health':
        return const Color(0xFFEF4444);
      case 'Personal':
        return const Color(0xFF8B5CF6);
      default:
        return const Color(0xFF10B981);
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'High':
        return const Color(0xFFEF4444);
      case 'Medium':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF10B981);
    }
  }

  void _triggerCelebration() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.park, size: 72, color: Color(0xFF10B981)),
              const SizedBox(height: 16),
              const Text(
                'Tree Fully Grown! 🎉',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'You have completed all tasks for today! Your new tree has been planted in your forest.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Awesome!'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddCategoryDialog() {
    final catController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Category'),
        content: TextField(
          controller: catController,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Category Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (catController.text.trim().isNotEmpty) {
                widget.addCategory(catController.text.trim());
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showTaskDialog({Task? existingTask}) {
    final titleController = TextEditingController(text: existingTask?.title ?? '');
    final descController = TextEditingController(text: existingTask?.description ?? '');
    String category = existingTask?.category ?? widget.categories.first;
    String priority = existingTask?.priority ?? 'Medium';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(existingTask == null ? 'Create New Task' : 'Edit Task'),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: 400,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: titleController,
                        autofocus: true,
                        decoration: const InputDecoration(
                          labelText: 'Task Title',
                          hintText: 'What needs to be done?',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: descController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Notes / Description',
                          hintText: 'Add extra details...',
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: widget.categories.contains(category)
                                  ? category
                                  : widget.categories.first,
                              decoration: const InputDecoration(labelText: 'Category'),
                              items: widget.categories
                                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                                  .toList(),
                              onChanged: (val) {
                                if (val != null) setDialogState(() => category = val);
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: priority,
                              decoration: const InputDecoration(labelText: 'Priority'),
                              items: ['Low', 'Medium', 'High']
                                  .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                                  .toList(),
                              onChanged: (val) {
                                if (val != null) setDialogState(() => priority = val);
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    if (titleController.text.trim().isNotEmpty) {
                      final key = widget.dateKey(_selectedDay);
                      setState(() {
                        if (existingTask == null) {
                          final newTask = Task(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            title: titleController.text.trim(),
                            description: descController.text.trim(),
                            date: DateTime(
                              _selectedDay.year,
                              _selectedDay.month,
                              _selectedDay.day,
                            ),
                            category: category,
                            priority: priority,
                          );
                          widget.tasksByDate.putIfAbsent(key, () => []).add(newTask);
                        } else {
                          existingTask.title = titleController.text.trim();
                          existingTask.description = descController.text.trim();
                          existingTask.category = category;
                          existingTask.priority = priority;
                        }
                      });
                      widget.saveTasks();
                      Navigator.pop(context);
                    }
                  },
                  child: Text(existingTask == null ? 'Create' : 'Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final dailyTasks = _getTasksForDay(_selectedDay);
    
    final filteredTasks = dailyTasks.where((t) {
      final matchesCategory =
          _selectedCategoryFilter == 'All' || t.category == _selectedCategoryFilter;
      final matchesSearch = _searchQuery.isEmpty ||
          t.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          t.description.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

    final progress = _calculateProgress(dailyTasks);
    final streak = _calculateStreak();

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.park, color: Color(0xFF10B981)),
            SizedBox(width: 8),
            Text(
              'TaskTree Workspace',
              style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: -0.5),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.local_fire_department,
                  color: Colors.amber,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  '$streak Day Streak',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.onToggleTheme,
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWideScreen = constraints.maxWidth >= 850;

          Widget calendarWidget = Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                startingDayOfWeek: StartingDayOfWeek.monday,
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
                    setState(() => _calendarFormat = format);
                  }
                },
                onPageChanged: (focusedDay) => _focusedDay = focusedDay,
                headerStyle: const HeaderStyle(
                  titleCentered: true,
                  formatButtonVisible: false,
                  titleTextStyle: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  outsideDaysVisible: false,
                ),
              ),
            ),
          );

          Widget taskBoardWidget = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color ??
                      Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 400),
                          child: Icon(
                            progress == 1.0
                                ? Icons.park
                                : progress > 0
                                    ? Icons.nature
                                    : Icons.eco_outlined,
                            key: ValueKey(progress),
                            color: Theme.of(context).colorScheme.primary,
                            size: 36,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                progress == 1.0
                                    ? 'Tree Fully Grown!'
                                    : progress > 0
                                        ? 'Growth in Progress'
                                        : 'Seed Planted',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                '${_selectedDay.day}/${_selectedDay.month}/${_selectedDay.year} • ${(progress * 100).toInt()}% completed',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 10,
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.15),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search tasks...',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (val) {
                        setState(() => _searchQuery = val.trim());
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ...['All', ...widget.categories].map((cat) {
                      final isSelected = _selectedCategoryFilter == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(cat),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _selectedCategoryFilter = cat);
                            }
                          },
                          showCheckmark: false,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      );
                    }),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline, size: 20),
                      onPressed: _showAddCategoryDialog,
                      tooltip: 'Add Category',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              Expanded(
                child: filteredTasks.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.assignment_outlined,
                              size: 48,
                              color: Theme.of(context).hintColor.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No tasks found.',
                              style: TextStyle(color: Theme.of(context).hintColor),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredTasks.length,
                        itemBuilder: (context, index) {
                          final task = filteredTasks[index];
                          final catColor = _getCategoryColor(task.category);
                          final priorityColor = _getPriorityColor(task.priority);

                          return Dismissible(
                            key: Key(task.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.red.shade400,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                            onDismissed: (_) {
                              setState(() => dailyTasks.remove(task));
                              widget.saveTasks();
                            },
                            child: Card(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              child: ListTile(
                                onTap: () => _showTaskDialog(existingTask: task),
                                leading: Checkbox(
                                  value: task.isCompleted,
                                  shape: const CircleBorder(),
                                  onChanged: (val) {
                                    final double prevProgress = progress;
                                    setState(
                                      () => task.isCompleted = val ?? false,
                                    );
                                    widget.saveTasks();

                                    final double newProgress =
                                        _calculateProgress(dailyTasks);
                                    if (prevProgress < 1.0 && newProgress == 1.0) {
                                      _triggerCelebration();
                                    }
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
                                subtitle: task.description.isNotEmpty
                                    ? Text(
                                        task.description,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Theme.of(context).hintColor,
                                        ),
                                      )
                                    : null,
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: priorityColor,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: catColor.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        task.category,
                                        style: TextStyle(
                                          color: catColor,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );

          if (isWideScreen) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 5,
                    child: SingleChildScrollView(child: calendarWidget),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 7,
                    child: taskBoardWidget,
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                calendarWidget,
                const SizedBox(height: 12),
                Expanded(child: taskBoardWidget),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showTaskDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
      ),
    );
  }
}

class ForestAnalyticsView extends StatelessWidget {
  final Map<String, List<Task>> tasksByDate;
  final VoidCallback onToggleTheme;
  final VoidCallback onOpenBackup;
  final bool isDarkMode;

  const ForestAnalyticsView({
    super.key,
    required this.tasksByDate,
    required this.onToggleTheme,
    required this.onOpenBackup,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    int totalTasks = 0;
    int completedTasks = 0;
    List<String> grownTreeDates = [];

    tasksByDate.forEach((dateKey, tasks) {
      if (tasks.isNotEmpty) {
        totalTasks += tasks.length;
        final completedInDay = tasks.where((t) => t.isCompleted).length;
        completedTasks += completedInDay;

        if (completedInDay == tasks.length) {
          grownTreeDates.add(dateKey);
        }
      }
    });

    final double completionRate =
        totalTasks > 0 ? (completedTasks / totalTasks) * 100 : 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Forest Overview & Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_backup_restore),
            tooltip: 'Backup & Restore',
            onPressed: onOpenBackup,
          ),
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: onToggleTheme,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildStatCard(
                  context,
                  title: 'Grown Trees',
                  value: '${grownTreeDates.length}',
                  icon: Icons.park,
                  color: const Color(0xFF10B981),
                ),
                const SizedBox(width: 12),
                _buildStatCard(
                  context,
                  title: 'Tasks Done',
                  value: '$completedTasks / $totalTasks',
                  icon: Icons.check_circle_outline,
                  color: const Color(0xFF3B82F6),
                ),
                const SizedBox(width: 12),
                _buildStatCard(
                  context,
                  title: 'Success Rate',
                  value: '${completionRate.toStringAsFixed(0)}%',
                  icon: Icons.insights,
                  color: const Color(0xFFF59E0B),
                ),
              ],
            ),

            const SizedBox(height: 24),

            Text(
              'Your Forest History',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Each tree represents a 100% completed day!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).hintColor,
                  ),
            ),

            const SizedBox(height: 16),

            grownTreeDates.isEmpty
                ? Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardTheme.color,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.nature_people_outlined,
                          size: 56,
                          color: Theme.of(context).hintColor.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'No fully grown trees yet.\nComplete all tasks in a day to plant your first tree!',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 140,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.9,
                    ),
                    itemCount: grownTreeDates.length,
                    itemBuilder: (context, index) {
                      final dateStr = grownTreeDates[index];
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.park,
                                size: 42,
                                color: Color(0xFF10B981),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                dateStr,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 12),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}