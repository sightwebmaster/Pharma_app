import 'package:flutter/material.dart';
import 'package:pharma_app/core/themes/app_colors.dart';
import 'package:pharma_app/core/themes/app_text_styles.dart';

/// AppTextField - Champ de saisie standard
class AppTextField extends StatefulWidget {
  final String label;
  final String hintText;
  final TextEditingController? controller;
  final IconData? trailingIcon;
  final VoidCallback? onTraillingIconTap;
  final int maxLines;
  final TextInputType keyboardType;
  final bool readOnly;
  final VoidCallback? onTap;

  const AppTextField({
    Key? key,
    required this.label,
    this.hintText = '',
    this.controller,
    this.trailingIcon,
    this.onTraillingIconTap,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.readOnly = false,
    this.onTap,
  }) : super(key: key);

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.label, style: AppTextStyles.fieldLabel),
          const SizedBox(height: 8),
          Container(
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: const BorderRadius.all(Radius.circular(14)),
              border: Border.all(
                color: _isFocused ? AppColors.primary : AppColors.border,
                width: _isFocused ? 2 : 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: widget.controller,
                      focusNode: _focusNode,
                      maxLines: widget.maxLines,
                      keyboardType: widget.keyboardType,
                      readOnly: widget.readOnly,
                      onTap: widget.onTap,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: widget.hintText,
                        hintStyle: AppTextStyles.fieldLabel,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                      ),
                      style: AppTextStyles.fieldValue,
                    ),
                  ),
                  if (widget.trailingIcon != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: GestureDetector(
                        onTap: widget.onTraillingIconTap,
                        child: Icon(
                          widget.trailingIcon,
                          color: AppColors.textLabel,
                          size: 22,
                        ),
                      ),
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
