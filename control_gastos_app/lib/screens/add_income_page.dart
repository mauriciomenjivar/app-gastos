import 'package:flutter/material.dart';
import '../models/gasto.dart';
import '../database/db_helper.dart';

class AddIncomePage extends StatefulWidget {
  const AddIncomePage({super.key});

  @override
  State<AddIncomePage> createState() => _AddIncomePageState();
}

class _AddIncomePageState extends State<AddIncomePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _sourceController = TextEditingController();
  String? _selectedCategory;
  DateTime? _selectedDate;

  final List<String> _incomeCategories = [
    "Salario",
    "Freelance",
    "Inversiones",
    "Regalo",
    "Ventas",
    "Reembolso",
    "Otros",
  ];

  final DBHelper _dbHelper = DBHelper();

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text(
          "Agregar Ingreso",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green[800],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Campo de título/descripción
              _buildInputField(
                controller: _titleController,
                label: "Descripción",
                hint: "Ej: Pago por proyecto X",
                icon: Icons.description,
                validator:
                    (value) => value!.isEmpty ? "Campo obligatorio" : null,
              ),

              const SizedBox(height: 16),

              // Campo de monto
              _buildInputField(
                controller: _amountController,
                label: "Monto",
                hint: "0.00",
                icon: Icons.attach_money,
                keyboardType: TextInputType.number,
                prefix: "\$ ",
                validator: (value) {
                  if (value!.isEmpty) return "Campo obligatorio";
                  if (double.tryParse(value) == null)
                    return "Ingrese un número válido";
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Campo de fuente (nuevo)
              _buildInputField(
                controller: _sourceController,
                label: "Fuente",
                hint: "Ej: Empresa XYZ, Cliente A",
                icon: Icons.source,
                validator:
                    (value) => value!.isEmpty ? "Campo obligatorio" : null,
              ),

              const SizedBox(height: 16),

              // Selector de categoría
              _buildDropdown(
                label: "Categoría",
                value: _selectedCategory,
                items: _incomeCategories,
                onChanged: (value) => setState(() => _selectedCategory = value),
                validator:
                    (value) =>
                        value == null ? "Seleccione una categoría" : null,
              ),

              const SizedBox(height: 16),

              // Selector de fecha
              _buildDatePicker(),

              const SizedBox(height: 32),

              // Botón de guardar
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    String? hint,
    IconData? icon,
    String? prefix,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey),
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey),
          prefixIcon: icon != null ? Icon(icon, color: Colors.grey) : null,
          prefix:
              prefix != null
                  ? Text(prefix, style: const TextStyle(color: Colors.white))
                  : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
    required String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        dropdownColor: const Color(0xFF2D2D2D),
        style: const TextStyle(color: Colors.white),
        icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
        items:
            items.map((category) {
              return DropdownMenuItem(value: category, child: Text(category));
            }).toList(),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        onChanged: onChanged,
        validator: validator,
      ),
    );
  }

  Widget _buildDatePicker() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: const Icon(Icons.calendar_today, color: Colors.grey),
        title: Text(
          _selectedDate != null
              ? "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}"
              : "Seleccionar fecha",
          style: const TextStyle(color: Colors.white),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),
        onTap: () => _selectDate(context),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _saveIncome,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green[700],
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text(
          "GUARDAR INGRESO",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.green,
              onPrimary: Colors.white,
              surface: Color(0xFF1E1E1E),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: const Color(0xFF121212),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  void _saveIncome() async {
    if (_formKey.currentState!.validate()) {
      final newIncome = Gasto(
        titulo: _titleController.text,
        monto: double.parse(_amountController.text),
        categoria: _selectedCategory!,
        fecha: _selectedDate!.toIso8601String().split("T").first,
        // Agregar campo adicional para fuente si lo necesitas
        // fuente: _sourceController.text,
      );

      await _dbHelper.insertarGasto(newIncome);
      Navigator.pop(context, true);
      
    }
  }
}
