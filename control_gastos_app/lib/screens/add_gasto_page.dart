import 'package:flutter/material.dart';
import '../models/gasto.dart';
import '../database/db_helper.dart';

class AddGastoPage extends StatefulWidget {
  const AddGastoPage({super.key});

  @override
  State<AddGastoPage> createState() => _AddGastoPageState();
}

class _AddGastoPageState extends State<AddGastoPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _montoController = TextEditingController();
  String? _categoriaSeleccionada;

  late List<String> _categorias;
  final DBHelper _dbHelper = DBHelper();

  @override
  void initState() {
    super.initState();
    _categorias = ["Comida", "Transporte", "Ocio", "Otros"];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text(
          "Añadir Gasto",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1E1E1E),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Campo de título
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextFormField(
                  controller: _tituloController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: "Descripción",
                    labelStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? "Campo obligatorio"
                              : null,
                ),
              ),

              const SizedBox(height: 16),

              // Campo de monto
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextFormField(
                  controller: _montoController,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Monto",
                    labelStyle: TextStyle(color: Colors.grey),
                    prefix: Text('\$ ', style: TextStyle(color: Colors.white)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Campo obligatorio";
                    }
                    if (double.tryParse(value) == null) {
                      return "Ingresa un número válido";
                    }
                    return null;
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Selector de categoría
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonFormField<String>(
                  value: _categoriaSeleccionada,
                  dropdownColor: const Color(0xFF2D2D2D),
                  style: const TextStyle(color: Colors.white),
                  icon: const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey,
                  ),
                  items:
                      _categorias
                          .map(
                            (cat) =>
                                DropdownMenuItem(value: cat, child: Text(cat)),
                          )
                          .toList(),
                  decoration: const InputDecoration(
                    labelText: "Categoría",
                    labelStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  ),
                  onChanged:
                      (value) => setState(() => _categoriaSeleccionada = value),
                  validator:
                      (value) =>
                          value == null ? "Selecciona una categoría" : null,
                ),
              ),

              const SizedBox(height: 24),

              // Botón de guardar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _guardarGasto,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFBB86FC),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "GUARDAR",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _guardarGasto() async {
    if (_formKey.currentState!.validate()) {
      final nuevoGasto = Gasto(
        titulo: _tituloController.text,
        monto: double.parse(_montoController.text),
        categoria: _categoriaSeleccionada!,
        fecha: DateTime.now().toIso8601String().split("T").first,
      );

      await _dbHelper.insertarGasto(nuevoGasto);
      Navigator.pop(context, true);
    }
  }
}
