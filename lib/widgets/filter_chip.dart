// widgets/filter_chip.dart
import 'package:flutter/material.dart';

class CustomFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  const CustomFilterChip({
    Key? key,
    required this.label,
    required this.selected,
    required this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: onSelected,
        selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
        labelStyle: TextStyle(
          color: selected ? Theme.of(context).primaryColor : Colors.black,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: selected 
                ? Theme.of(context).primaryColor 
                : Colors.grey.shade300,
          ),
        ),
      ),
    );
  }
}