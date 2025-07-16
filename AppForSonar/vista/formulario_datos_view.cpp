import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'perfil_view.dart';

class FormularioDatosView extends StatefulWidget {
  final String userId;

  const FormularioDatosView({super.key, required this.userId});

  @override
  State<FormularioDatosView> createState() => _FormularioDatosViewState();
}

class _FormularioDatosViewState extends State<FormularioDatosView> {
  final _nombreController = TextEditingController();
  final _pesoController = TextEditingController();
  final _estaturaController = TextEditingController();
  DateTime? _fechaNacimiento;
  String _genero = 'Masculino';

  void _guardarDatos() async {
    if (_fechaNacimiento == null) return;

    final edad = DateTime.now().year - _fechaNacimiento!.year;

    await Supabase.instance.client.from('profiles').insert({
      'id': widget.userId,
      'nombre': _nombreController.text.trim(),
      'fecha_nacimiento': _fechaNacimiento!.toIso8601String(),
      'edad': edad,
      'peso': double.tryParse(_pesoController.text),
      'estatura': double.tryParse(_estaturaController.text),
      'genero': _genero,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Perfil guardado exitosamente'), backgroundColor: Colors.teal),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => PerfilView(userId: widget.userId)),
    );
  }

  Future<void> _seleccionarFecha(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _fechaNacimiento = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFe0f7fa),
      appBar: AppBar(
        title: const Text('Completa tu Perfil'),
        backgroundColor: const Color(0xFF00796B),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _nombreController,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _fechaNacimiento == null
                        ? 'Selecciona tu fecha de nacimiento'
                        : 'Fecha: ${_fechaNacimiento!.toLocal().toString().split(' ')[0]}',
                  ),
                ),
                IconButton(
                  onPressed: () => _seleccionarFecha(context),
                  icon: const Icon(Icons.calendar_today),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _pesoController,
              decoration: const InputDecoration(labelText: 'Peso (kg)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _estaturaController,
              decoration: const InputDecoration(labelText: 'Estatura (cm)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _genero,
              decoration: const InputDecoration(labelText: 'Género'),
              items: const [
                DropdownMenuItem(value: 'Masculino', child: Text('Masculino')),
                DropdownMenuItem(value: 'Femenino', child: Text('Femenino')),
                DropdownMenuItem(value: 'Otro', child: Text('Otro')),
              ],
              onChanged: (value) {
                setState(() {
                  _genero = value!;
                });
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _guardarDatos,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00796B),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Guardar', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
