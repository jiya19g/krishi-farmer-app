import 'package:flutter/material.dart';

class CategoryAccordion extends StatefulWidget {
  final String title;
  final List<String> items;
  final ValueChanged<String> onItemSelected;
  final bool initiallyExpanded;

  const CategoryAccordion({
    Key? key,
    required this.title,
    required this.items,
    required this.onItemSelected,
    this.initiallyExpanded = false,
  }) : super(key: key);

  @override
  _CategoryAccordionState createState() => _CategoryAccordionState();
}

class _CategoryAccordionState extends State<CategoryAccordion> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        children: [
          ListTile(
            title: Text(
              '${widget.title} (${widget.items.length})',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            trailing: Icon(
              _isExpanded ? Icons.expand_less : Icons.expand_more,
            ),
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
          ),
          if (_isExpanded)
            Padding(
              padding: EdgeInsets.only(left: 16, right: 16, bottom: 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.items.map((item) {
                  return FilterChip(
                    label: Text(item),
                    selected: false,
                    onSelected: (selected) {
                      widget.onItemSelected(item);
                    },
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}