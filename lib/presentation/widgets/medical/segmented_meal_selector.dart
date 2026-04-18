import 'package:flutter/material.dart';
import 'package:pharma_app/core/themes/app_colors.dart';
import 'package:pharma_app/core/themes/app_text_styles.dart';

/// SegmentedMealSelector - Sélecteur repas (Before / After / With)
class SegmentedMealSelector extends StatefulWidget {
  final String initialValue;
  final Function(String) onChanged;

  const SegmentedMealSelector({
    Key? key,
    this.initialValue = 'Before Meals',
    required this.onChanged,
  }) : super(key: key);

  @override
  State<SegmentedMealSelector> createState() => _SegmentedMealSelectorState();
}

class _SegmentedMealSelectorState extends State<SegmentedMealSelector> {
  late String _selectedValue;

  final List<String> _options = ['Before Meals', 'After Meals', 'With Meals'];

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Before/After Meals', style: AppTextStyles.fieldLabel),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: const BorderRadius.all(Radius.circular(12)),
            ),
            child: Row(
              children: _options.map((option) {
                final isSelected = _selectedValue == option;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedValue = option;
                      });
                      widget.onChanged(option);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : Colors.transparent,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(10),
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : [],
                      ),
                      child: Center(
                        child: Text(
                          option,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
