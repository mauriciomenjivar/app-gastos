import 'package:flutter/material.dart';
import '../models/gasto.dart';
import '../database/db_helper.dart';

class EditGastoPage extends StatefulWidget {
  final Gasto gasto;

  const EditGastoPage({super.key, required this.gasto});

  @override
  State<EditGastoPage> createState() => _EditGastoPageState();
}

class _EditGastoPageState extends State<EditGastoPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _montoController = TextEditingController();
  String? _categoriaSeleccionada;

  final List<String> _categorias = ["Comida", "Transporte", "Ocio", "Otros"];
  final DBHelper _dbHelper = DBHelper();

  @override
  void initState() {
    super.initState();
    _tituloController.text = widget.gasto.titulo;
    _montoController.text = widget.gasto.monto.toString();
    _categoriaSeleccionada = widget.gasto.categoria;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "Editar Gasto",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black, Color(0xFF121212)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildInputField(
                    controller: _tituloController,
                    label: "Título",
                    icon: Icons.title,
                    validator:
                        (value) =>
                            value == null || value.isEmpty
                                ? "Campo obligatorio"
                                : null,
                  ),
                  const SizedBox(height: 20),
                  _buildInputField(
                    controller: _montoController,
                    label: "Monto",
                    icon: Icons.attach_money,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return "Campo obligatorio";
                      if (double.tryParse(value) == null)
                        return "Ingresa un número válido";
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildCategoryDropdown(),
                  const SizedBox(height: 30),
                  _buildActionButton(
                    text: "Guardar cambios",
                    color: Colors.deepPurpleAccent,
                    onPressed: _guardarEdicion,
                  ),
                  const SizedBox(height: 15),
                  _buildActionButton(
                    text: "Eliminar Gasto",
                    color: Colors.red,
                    onPressed: _confirmarEliminacion,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white24),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.deepPurpleAccent),
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
      ),
      validator: validator,
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      value: _categoriaSeleccionada,
      dropdownColor: const Color(0xFF1E1E1E),
      icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: "Categoría",
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: const Icon(Icons.category, color: Colors.white70),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white24),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.deepPurpleAccent),
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
      ),
      items:
          _categorias.map((cat) {
            return DropdownMenuItem(
              value: cat,
              child: Text(cat, style: const TextStyle(color: Colors.white)),
            );
          }).toList(),
      onChanged: (value) {
        setState(() {
          _categoriaSeleccionada = value;
        });
      },
      validator: (value) => value == null ? "Selecciona una categoría" : null,
    );
  }

  Widget _buildActionButton({
    required String text,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        shadowColor: color.withOpacity(0.3),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  void _guardarEdicion() async {
    if (_formKey.currentState!.validate()) {
      final gastoEditado = Gasto(
        id: widget.gasto.id,
        titulo: _tituloController.text,
        monto: double.parse(_montoController.text),
        categoria: _categoriaSeleccionada!,
        fecha: widget.gasto.fecha,
      );

      await _dbHelper.actualizarGasto(gastoEditado);
      Navigator.pop(context, true);
    }
  }

  void _confirmarEliminacion() async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF1E1E1E),
            title: const Text(
              "¿Eliminar este gasto?",
              style: TextStyle(color: Colors.white),
            ),
            content: const Text(
              "Esta acción no se puede deshacer.",
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text(
                  "Cancelar",
                  style: TextStyle(color: Colors.white70),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  "Eliminar",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirmado == true) {
      await _dbHelper.eliminarGasto(widget.gasto.id!);
      Navigator.pop(context, true);
    }
  }
}
