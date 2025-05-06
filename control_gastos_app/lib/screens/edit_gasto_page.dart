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
      appBar: AppBar(title: const Text("Editar Gasto")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                onPressed: _guardarEdicion,
                child: const Text("Guardar cambios"),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: _confirmarEliminacion,
                child: const Text("Eliminar Gasto"),
              ),
            ],
          ),
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
      Navigator.pop(context, true); // Volver al HomePage
    }
  }

  void _confirmarEliminacion() async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("¿Eliminar este gasto?"),
            content: const Text("Esta acción no se puede deshacer."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancelar"),
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
      Navigator.pop(context, true); // Regresar a HomePage
    }
  }
}
