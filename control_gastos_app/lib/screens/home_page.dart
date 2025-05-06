import 'package:flutter/material.dart';
import '../models/gasto.dart';
import '../database/db_helper.dart';
import 'add_gasto_page.dart';
import 'edit_gasto_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DBHelper _dbHelper = DBHelper();
  List<Gasto> _gastos = [];

  @override
  void initState() {
    super.initState();
    _cargarGastos();
  }

  Future<void> _cargarGastos() async {
    final gastos = await _dbHelper.obtenerGastos();
    setState(() {
      _gastos = gastos;
    });
  }

  double _calcularTotal() {
    return _gastos.fold(0, (suma, g) => suma + g.monto);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Control de Gastos")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Total: \$${_calcularTotal().toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 20),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _gastos.length,
              itemBuilder: (context, index) {
                final gasto = _gastos[index];
                return ListTile(
                  title: Text(gasto.titulo),
                  subtitle: Text("${gasto.categoria} • ${gasto.fecha}"),
                  trailing: Text("\$${gasto.monto.toStringAsFixed(2)}"),
                  onTap: () async {
                    final resultado = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditGastoPage(gasto: gasto),
                      ),
                    );
                    if (resultado == true) {
                      _cargarGastos();
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final resultado = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddGastoPage()),
          );
          if (resultado == true) {
            _cargarGastos();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
