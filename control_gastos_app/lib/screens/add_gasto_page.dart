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

  final List<String> _categorias = ["Comida", "Transporte", "Ocio", "Otros"];

  final DBHelper _dbHelper = DBHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nuevo Gasto")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _tituloController,
                decoration: const InputDecoration(labelText: "Título"),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? "Campo obligatorio"
                            : null,
              ),
              TextFormField(
                controller: _montoController,
                decoration: const InputDecoration(labelText: "Monto"),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return "Campo obligatorio";
                  if (double.tryParse(value) == null)
                    return "Ingresa un número válido";
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _categoriaSeleccionada,
                items:
                    _categorias.map((cat) {
                      return DropdownMenuItem(value: cat, child: Text(cat));
                    }).toList(),
                decoration: const InputDecoration(labelText: "Categoría"),
                onChanged: (value) {
                  setState(() {
                    _categoriaSeleccionada = value;
                  });
                },
                validator:
                    (value) =>
                        value == null ? "Selecciona una categoría" : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _guardarGasto,
                child: const Text("Guardar"),
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
      print("Gasto guardado: ${nuevoGasto.toMap()}");
      Navigator.pop(context, true);
    }
  }
}
