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

  Future<void> _eliminarGasto(int id) async {
    await _dbHelper.eliminarGasto(id);
    _cargarGastos();
  }

  Future<void> _editarGasto(Gasto gasto) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditGastoPage(gasto: gasto)),
    );
    _cargarGastos();
  }

  double _calcularGastos() {
    return _gastos.fold(0, (suma, g) => suma + g.monto);
  }

  Map<String, double> _resumenPorCategoria() {
    final Map<String, double> resumen = {};
    for (final gasto in _gastos) {
      if (resumen.containsKey(gasto.categoria)) {
        resumen[gasto.categoria] = resumen[gasto.categoria]! + gasto.monto;
      } else {
        resumen[gasto.categoria] = gasto.monto;
      }
    }
    final sortedEntries =
        resumen.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(sortedEntries);
  }

  Widget _buildSaldoSection() {
    final totalGastos = _calcularGastos();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2A2A2A), Color(0xFF121212)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(
                  'https://randomuser.me/api/portraits/men/41.jpg',
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "ESIT",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.deepPurpleAccent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.deepPurpleAccent),
                ),
                child: const Text(
                  "Mayo",
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Total Gastos",
                style: TextStyle(fontSize: 14, color: Colors.white54),
              ),
              const SizedBox(height: 4),
              Text(
                "R\$${totalGastos.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResumenItem(String title, double amount, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          Text(
            "R\$${amount.toStringAsFixed(2)}",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListSection(
    String title,
    double amount,
    List<Gasto> items,
    Color accentColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                ),
              ),
              Text(
                "R\$${amount.toStringAsFixed(2)}",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(height: 1, color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 12),
          ...items
              .take(3)
              .map(
                (gasto) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              color: accentColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                gasto.titulo,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white70,
                                ),
                              ),
                              Text(
                                gasto.categoria,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.5),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            "R\$${gasto.monto.toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          PopupMenuButton<String>(
                            icon: const Icon(
                              Icons.more_vert,
                              color: Colors.white,
                              size: 20,
                            ),
                            onSelected: (String value) {
                              if (value == 'Editar') {
                                _editarGasto(gasto);
                              } else if (value == 'Eliminar') {
                                _eliminarGasto(gasto.id!);
                              }
                            },
                            itemBuilder:
                                (BuildContext context) => [
                                  const PopupMenuItem(
                                    value: 'Editar',
                                    child: Text('Editar'),
                                  ),
                                  const PopupMenuItem(
                                    value: 'Eliminar',
                                    child: Text('Eliminar'),
                                  ),
                                ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          if (items.length > 3)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                "+ ${items.length - 3} más...",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildResumenSection() {
    final resumen = _resumenPorCategoria();
    final colores = [
      Colors.blueAccent,
      Colors.pinkAccent,
      Colors.amberAccent,
      Colors.greenAccent,
      Colors.orangeAccent,
      Colors.purpleAccent,
      Colors.tealAccent,
    ];

    final categorias = resumen.keys.toList();
    final valores = resumen.values.toList();

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Resumen por Categoría",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Container(height: 1, color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 12),
          for (int i = 0; i < categorias.length && i < 5; i++)
            _buildResumenItem(
              categorias[i],
              valores[i],
              colores[i % colores.length],
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final resumen = _resumenPorCategoria();

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Control de Gastos'),
        backgroundColor: Colors.deepPurple,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddGastoPage()),
          );
          _cargarGastos();
        },
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSaldoSection(),
            for (var entry in resumen.entries)
              _buildListSection(
                entry.key,
                entry.value,
                _gastos.where((g) => g.categoria == entry.key).toList(),
                Colors.deepPurpleAccent,
              ),
            _buildResumenSection(),
          ],
        ),
      ),
    );
  }
}
