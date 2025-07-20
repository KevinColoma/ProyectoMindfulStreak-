import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditarPerfilView extends StatefulWidget {
  final String userId;
  final Map<String, dynamic> perfilActual;

  const EditarPerfilView({
    super.key,
    required this.userId,
    required this.perfilActual,
  });

  @override
  State<EditarPerfilView> createState() => _EditarPerfilViewState();
}

class _EditarPerfilViewState extends State<EditarPerfilView> {
  final _formKey = GlobalKey<FormState>();
  final _client = Supabase.instance.client;
  final _imagePicker = ImagePicker();
  
  late TextEditingController _nombreController;
  late TextEditingController _edadController;
  late TextEditingController _pesoController;
  late TextEditingController _estaturaController;
  late TextEditingController _generoController;
  
  DateTime? _fechaNacimiento;
  File? _imagenSeleccionada;
  String? _urlImagenActual;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _inicializarControladores();
  }

  void _inicializarControladores() {
    _nombreController = TextEditingController(text: widget.perfilActual['nombre'] ?? '');
    _edadController = TextEditingController(text: widget.perfilActual['edad']?.toString() ?? '');
    _pesoController = TextEditingController(text: widget.perfilActual['peso']?.toString() ?? '');
    _estaturaController = TextEditingController(text: widget.perfilActual['estatura']?.toString() ?? '');
    _generoController = TextEditingController(text: widget.perfilActual['genero'] ?? '');
    
    if (widget.perfilActual['fecha_nacimiento'] != null) {
      _fechaNacimiento = DateTime.parse(widget.perfilActual['fecha_nacimiento']);
    }
    
    _urlImagenActual = widget.perfilActual['avatar_url'];
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _edadController.dispose();
    _pesoController.dispose();
    _estaturaController.dispose();
    _generoController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarImagen() async {
    try {
      final XFile? imagen = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );
      
      if (imagen != null) {
        setState(() {
          _imagenSeleccionada = File(imagen.path);
        });
      }
    } catch (e) {
      _mostrarMensaje('Error al seleccionar imagen: $e');
    }
  }

  Future<void> _tomarFoto() async {
    try {
      final XFile? imagen = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );
      
      if (imagen != null) {
        setState(() {
          _imagenSeleccionada = File(imagen.path);
        });
      }
    } catch (e) {
      _mostrarMensaje('Error al tomar foto: $e');
    }
  }

  Future<String?> _subirImagen() async {
    if (_imagenSeleccionada == null) return _urlImagenActual;
    
    try {
      final fileName = '${widget.userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final response = await _client.storage
          .from('avatars')
          .upload(fileName, _imagenSeleccionada!);
      
      if (response.isNotEmpty) {
        final url = _client.storage
            .from('avatars')
            .getPublicUrl(fileName);
        return url;
      }
    } catch (e) {
      _mostrarMensaje('Error al subir imagen: $e');
    }
    return _urlImagenActual;
  }

  Future<void> _guardarPerfil() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      // Subir imagen si se seleccionó una nueva
      final urlImagen = await _subirImagen();
      
      // Actualizar perfil en la base de datos
      await _client.from('profiles').update({
        'nombre': _nombreController.text,
        'edad': int.tryParse(_edadController.text) ?? 0,
        'fecha_nacimiento': _fechaNacimiento?.toIso8601String(),
        'peso': double.tryParse(_pesoController.text) ?? 0.0,
        'estatura': double.tryParse(_estaturaController.text) ?? 0.0,
        'genero': _generoController.text,
        'avatar_url': urlImagen,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', widget.userId);

      _mostrarMensaje('Perfil actualizado exitosamente', esError: false);
      
      // Regresar a la vista anterior
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      _mostrarMensaje('Error al actualizar perfil: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _mostrarMensaje(String mensaje, {bool esError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: esError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _seleccionarFecha() async {
    final DateTime? fechaSeleccionada = await showDatePicker(
      context: context,
      initialDate: _fechaNacimiento ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    
    if (fechaSeleccionada != null) {
      setState(() {
        _fechaNacimiento = fechaSeleccionada;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFe0f7fa),
      appBar: AppBar(
        title: const Text('Editar Perfil'),
        backgroundColor: const Color(0xFF00796B),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Sección de foto de perfil
              _buildFotoPerfil(),
              const SizedBox(height: 32),
              
              // Campos del formulario
              _buildCampoTexto(
                controller: _nombreController,
                label: 'Nombre',
                icon: Icons.person,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa tu nombre';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              _buildCampoTexto(
                controller: _edadController,
                label: 'Edad',
                icon: Icons.cake,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa tu edad';
                  }
                  final edad = int.tryParse(value);
                  if (edad == null || edad < 1 || edad > 120) {
                    return 'Edad inválida';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              _buildCampoFecha(),
              
              const SizedBox(height: 16),
              
              _buildCampoTexto(
                controller: _pesoController,
                label: 'Peso (kg)',
                icon: Icons.monitor_weight,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa tu peso';
                  }
                  final peso = double.tryParse(value);
                  if (peso == null || peso < 20 || peso > 300) {
                    return 'Peso inválido';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              _buildCampoTexto(
                controller: _estaturaController,
                label: 'Estatura (cm)',
                icon: Icons.height,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa tu estatura';
                  }
                  final estatura = double.tryParse(value);
                  if (estatura == null || estatura < 100 || estatura > 250) {
                    return 'Estatura inválida';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              _buildCampoTexto(
                controller: _generoController,
                label: 'Género',
                icon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa tu género';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 32),
              
              // Botón guardar
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _guardarPerfil,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00796B),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Guardar Cambios',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFotoPerfil() {
    return Column(
      children: [
        GestureDetector(
          onTap: _mostrarOpcionesImagen,
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
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.teal[100],
                  backgroundImage: _imagenSeleccionada != null
                      ? FileImage(_imagenSeleccionada!)
                      : (_urlImagenActual != null
                          ? NetworkImage(_urlImagenActual!) as ImageProvider
                          : null),
                  child: _imagenSeleccionada == null && _urlImagenActual == null
                      ? Text(
                          _nombreController.text.isNotEmpty
                              ? _nombreController.text[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            fontSize: 40,
                            color: Colors.teal,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.teal,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Toca para cambiar foto',
          style: TextStyle(
            color: Colors.teal[700],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  void _mostrarOpcionesImagen() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Seleccionar de galería'),
              onTap: () {
                Navigator.pop(context);
                _seleccionarImagen();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Tomar foto'),
              onTap: () {
                Navigator.pop(context);
                _tomarFoto();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCampoTexto({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.teal[700]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.teal[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.teal[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.teal[700]!, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red[300]!),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildCampoFecha() {
    return InkWell(
      onTap: _seleccionarFecha,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.teal[300]!),
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: Colors.teal[700]),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _fechaNacimiento != null
                    ? '${_fechaNacimiento!.day}/${_fechaNacimiento!.month}/${_fechaNacimiento!.year}'
                    : 'Seleccionar fecha de nacimiento',
                style: TextStyle(
                  color: _fechaNacimiento != null ? Colors.black : Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 