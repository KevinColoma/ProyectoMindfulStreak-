import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'vista/home_view.dart';

const supabaseUrl = 'https://pwmxphmrpcookhvudvug.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InB3bXhwaG1ycGNvb2todnVkdnVnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDcyMjM5NzYsImV4cCI6MjA2Mjc5OTk3Nn0.TiOZQTIvO46ElR3ZOr2FtWdUcZcEPHm8KqjjqtpgvNU'; // reemplaza aquí con tu clave real completa

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitnessApp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        useMaterial3: true,
      ),
      home: const HomeView(),
    );
  }
}
