import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PerfilView extends StatefulWidget {
  final String userId;

  const PerfilView({super.key, required this.userId});

  @override
  State<PerfilView> createState() => _PerfilViewState();
}

class _PerfilViewState extends State<PerfilView> {
  Map<String, dynamic>? _perfil;
  final _client = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _cargarPerfil();
  }

  void _cargarPerfil() async {
    final data = await _client
        .from('profiles')
        .select()
        .eq('id', widget.userId)
        .maybeSingle();

    setState(() {
      _perfil = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_perfil == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFe0f7fa),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFe0f7fa),
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        backgroundColor: const Color(0xFF00796B),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.teal, width: 2),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.teal.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.teal[100],
                  child: Text(
                    _perfil!['nombre'][0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 40,
                      color: Colors.teal,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildProfileField('Nombre', _perfil!['nombre']),
            _buildProfileField('Edad', '${_perfil!['edad']} años'),
            _buildProfileField(
              'Fecha Nac.',
              _perfil!['fecha_nacimiento'].toString().split("T")[0],
            ),
            _buildProfileField('Peso', '${_perfil!['peso']} kg'),
            _buildProfileField('Estatura', '${_perfil!['estatura']} cm'),
            _buildProfileField('Género', _perfil!['genero']),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(Icons.person, color: Colors.teal[700], size: 20),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
