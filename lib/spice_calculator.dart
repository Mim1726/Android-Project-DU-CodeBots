import 'package:flutter/material.dart';

class SpiceCalculatorPage extends StatefulWidget {
  final List<String> ingredients;
  final List<String> amounts;
  final Function(List<String>) onCalculated;

  const SpiceCalculatorPage({
    super.key,
    required this.ingredients,
    required this.amounts,
    required this.onCalculated,
  });

  @override
  State<SpiceCalculatorPage> createState() => _SpiceCalculatorPageState();
}

class _SpiceCalculatorPageState extends State<SpiceCalculatorPage> {
  final TextEditingController _baseAmountController = TextEditingController();

  String? selectedIngredient;
  Map<String, String> scaledResults = {};

  static const Color deepOrange = Color(0xFFFF5722);

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

      results[widget.ingredients[i]] = unit.isNotEmpty ? '$scaled $unit' : scaled;
    }

    setState(() => scaledResults = results);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Scaled ingredient amounts calculated!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUnit = selectedIngredient != null
        ? _extractUnit(widget.amounts[widget.ingredients.indexOf(selectedIngredient!)]).trim()
        : '';

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/screen_images/screen2.jpg',
            fit: BoxFit.cover,
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: ListView(
                children: [
                  Container(
                    width: double.infinity,
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: deepOrange),
                          onPressed: () => Navigator.pop(context),
                          splashRadius: 20,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Spice Calculator',
                          style: TextStyle(
                            color: deepOrange,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('Select Base Ingredient:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: selectedIngredient,
                    dropdownColor: Colors.white, // white dropdown popup
                    items: widget.ingredients.map((ingredient) {
                      return DropdownMenuItem(
                        value: ingredient,
                        child: Text(ingredient),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedIngredient = value;
                        _baseAmountController.clear();
                        scaledResults = {};
                      });
                    },
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Colors.white, // white input field
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
                            filled: true,
                            fillColor: Colors.white, // white background
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
                          color: Colors.white, // white fixed background
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
                        child: Text('${entry.key} = ${entry.value}', style: const TextStyle(fontSize: 16)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        final newAmounts = widget.ingredients
                            .map((ingredient) => scaledResults[ingredient] ?? 'N/A')
                            .toList();
                        widget.onCalculated(newAmounts);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: deepOrange),
                      child: const Text(
                        'See instructions with your calculated ingredients',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
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
          ),
        ],
      ),
    );
  }
}
