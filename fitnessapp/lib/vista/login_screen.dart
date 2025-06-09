import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'formulario_datos_view.dart';
import 'perfil_view.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final supabase = Supabase.instance.client;

  void _iniciarSesion() async {
    try {
      final authResponse = await supabase.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      final userId = authResponse.user?.id;

      if (userId != null) {
        final perfil = await supabase
            .from('profiles')
            .select()
            .eq('id', userId)
            .maybeSingle();

        if (perfil == null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => FormularioDatosView(userId: userId)),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Bienvenido de nuevo, ${perfil['nombre']}')),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => PerfilView(userId: userId)),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al iniciar sesión: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFe0f7fa),
      appBar: AppBar(
        title: const Text('Iniciar Sesión'),
        backgroundColor: const Color(0xFF00796B),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Correo electrónico'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Contraseña'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _iniciarSesion,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00796B),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Ingresar', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
