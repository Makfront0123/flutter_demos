import 'package:flutter/material.dart';
import 'package:isar_integration/model/task_model.dart';
import 'package:isar_integration/services/isar_services.dart';

class TaskPage extends StatefulWidget {
  final IsarService isarService;

  const TaskPage({super.key, required this.isarService});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  final _controller = TextEditingController();
  List<Task> tasks = [];

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  Future<void> loadTasks() async {
    final loaded = await widget.isarService.getTasks();
    setState(() => tasks = loaded);
  }

  Future<void> addTask(String title) async {
    if (title.isEmpty) return;
    await widget.isarService.addTask(Task()..title = title);
    _controller.clear();
    loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tareas offline con Isar")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: "Nueva tarea",
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => addTask(_controller.text),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (_, i) {
                final t = tasks[i];
                return ListTile(
                  title: Text(
                    t.title,
                    style: TextStyle(
                      decoration: t.completed
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  leading: Checkbox(
                    value: t.completed,
                    onChanged: (_) async {
                      await widget.isarService.toggleComplete(t);
                      loadTasks();
                    },
                  ),
                  trailing: IconButton(
                    onPressed: () async {
                      await widget.isarService.deleteTask(t);
                      loadTasks();
                    },
                    icon: Icon(Icons.delete),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
