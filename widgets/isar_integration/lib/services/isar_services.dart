import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../model/task_model.dart';

class IsarService {
  late Future<Isar> db;

  IsarService() {
    db = openDB();
  }

  Future<Isar> openDB() async {
    if (Isar.instanceNames.isEmpty) {
      final dir = await getApplicationDocumentsDirectory();
      final isar = await Isar.open([TaskSchema], directory: dir.path);
      return isar;
    }

    return Future.value(Isar.getInstance()!);
  }

  Future<void> addTask(Task task) async {
    final isar = await db;
    await isar.writeTxn(() => isar.tasks.put(task));
  }

  Future<void> deleteTask(Task task) async {
    final isar = await db;
    await isar.writeTxn(() => isar.tasks.delete(task.id));
  }

  Future<List<Task>> getTasks() async {
    final isar = await db;
    return isar.tasks.where().findAll();
  }

  Future<void> toggleComplete(Task task) async {
    final isar = await db;
    await isar.writeTxn(() {
      task.completed = !task.completed;
      return isar.tasks.put(task);
    });
  }
}
