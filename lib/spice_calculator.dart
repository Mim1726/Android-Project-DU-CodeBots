import 'package:flutter/material.dart';

class SpiceCalculatorPage extends StatefulWidget {
  final List<String> ingredients;
  final List<String> amounts;

  const SpiceCalculatorPage({
    super.key,
    required this.ingredients,
    required this.amounts,
  });

  @override
  State<SpiceCalculatorPage> createState() => _SpiceCalculatorPageState();
}

class _SpiceCalculatorPageState extends State<SpiceCalculatorPage> {
  final TextEditingController _baseAmountController = TextEditingController();

  String? selectedIngredient;
  Map<String, String> scaledResults = {};

  double _extractNumber(String input) {
    final regex = RegExp(r'^(\d+(\.\d+)?)');
    final match = regex.firstMatch(input);
    if (match != null) {
      return double.tryParse(match.group(1)!) ?? 1.0;
    }
    return 1.0;
  }

  String _extractUnit(String input) {
    final regex = RegExp(r'^\d+(\.\d+)?\s*(.*)$');
    final match = regex.firstMatch(input);
    if (match != null) {
      final unit = match.group(2)?.trim();
      return (unit == null || unit.isEmpty) ? '' : unit;
    }
    return '';
  }

  void _calculateScaledIngredients() {
    if (selectedIngredient == null || _baseAmountController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Please select a base ingredient and enter its new amount.')),
      );
      return;
    }

    final newAmount = double.tryParse(_baseAmountController.text.trim());
    if (newAmount == null || newAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Please enter a valid numeric amount.')),
      );
      return;
    }

    int baseIndex = widget.ingredients.indexOf(selectedIngredient!);
    if (baseIndex == -1 || baseIndex >= widget.amounts.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Base ingredient not found in recipe.')),
      );
      return;
    }

    final originalBaseAmount = _extractNumber(widget.amounts[baseIndex]);
    final scale = newAmount / originalBaseAmount;

    Map<String, String> results = {};

    for (int i = 0; i < widget.ingredients.length; i++) {
      final originalAmountStr = widget.amounts[i];
      final originalAmount = _extractNumber(originalAmountStr);
      final unit = _extractUnit(originalAmountStr);
      final scaled = (originalAmount * scale).toStringAsFixed(2);

      results[widget.ingredients[i]] = unit.isNotEmpty
          ? '$scaled $unit'
          : scaled;
    }

    setState(() => scaledResults = results);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Scaled ingredient amounts calculated!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    const deepOrange = Color(0xFFFF5722);

    final currentUnit = selectedIngredient != null
        ? _extractUnit(widget.amounts[widget.ingredients.indexOf(selectedIngredient!)])
        : '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Spice Calculator'),
        backgroundColor: deepOrange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            const Text('Select Base Ingredient:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: selectedIngredient,
              items: widget.ingredients.map((ingredient) {
                return DropdownMenuItem(value: ingredient, child: Text(ingredient));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedIngredient = value;
                  _baseAmountController.clear();
                  scaledResults = {};
                });
              },
              decoration: const InputDecoration(
                hintText: 'Choose ingredient',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Enter New Amount for Base Ingredient:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _baseAmountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: 'e.g., 1000',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                    color: Colors.transparent,
                  ),
                  child: Text(
                    currentUnit.isNotEmpty ? currentUnit : 'unit',
                    style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _calculateScaledIngredients,
              style: ElevatedButton.styleFrom(backgroundColor: deepOrange),
              child: const Text('Calculate Ingredient Amounts', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 24),
            if (scaledResults.isNotEmpty) ...[
              const Text('Scaled Ingredients:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              ...scaledResults.entries.map(
                    (entry) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    '${entry.key} = ${entry.value}',
                    style: const TextStyle(fontSize: 16), // default, normal font
                  ),
                ),
              ),
            ] else
              const Text(
                'Select a base ingredient and amount to begin.',
                style: TextStyle(color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }
}
