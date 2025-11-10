import 'package:flutter/material.dart';
import 'package:isar_integration/pages/task_page.dart';
import 'package:isar_integration/services/isar_services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final isarService = IsarService();

  runApp(MyApp(isarService: isarService));
}

class MyApp extends StatelessWidget {
  final IsarService isarService;

  const MyApp({super.key, required this.isarService});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      home: TaskPage(isarService: isarService),
    );
  }
}
