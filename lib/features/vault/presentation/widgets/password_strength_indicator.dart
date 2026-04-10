import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class PasswordStrengthIndicator extends StatelessWidget {
  final int strength;

  const PasswordStrengthIndicator({super.key, required this.strength});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(6, (index) {
            final isActive = index < strength;
            Color color;
            if (index < 2) {
              color = AppTheme.errorColor;
            } else if (index < 4) {
              color = AppTheme.warningColor;
            } else {
              color = AppTheme.successColor;
            }
            return Expanded(
              child: Container(
                height: 4,
                margin: EdgeInsets.only(right: index < 5 ? 4 : 0),
                decoration: BoxDecoration(
                  color: isActive ? color : AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Text(
          _getStrengthText(),
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: _getStrengthColor()),
        ),
      ],
    );
  }

  String _getStrengthText() {
    if (strength < 2) return 'Weak';
    if (strength < 4) return 'Fair';
    if (strength < 5) return 'Good';
    return 'Strong';
  }

  Color _getStrengthColor() {
    if (strength < 2) return AppTheme.errorColor;
    if (strength < 4) return AppTheme.warningColor;
    if (strength < 5) return AppTheme.primaryColor;
    return AppTheme.successColor;
  }
}
