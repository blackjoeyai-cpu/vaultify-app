import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/services/secure_clipboard_service.dart';
import '../../../settings/application/providers/settings_provider.dart';
import '../../application/providers/password_generator_provider.dart';

class PasswordGeneratorSheet extends ConsumerWidget {
  final Function(String) onPasswordSelected;

  const PasswordGeneratorSheet({super.key, required this.onPasswordSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final generatorState = ref.watch(passwordGeneratorProvider);
    final generator = ref.read(passwordGeneratorProvider.notifier);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Text(
                'Password Generator',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.backgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    generatorState.password,
                    style: const TextStyle(
                      fontSize: 18,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () async {
                    final settings = ref.read(settingsProvider);
                    await SecureClipboardService.copyWithAutoClearSetting(
                      generatorState.password,
                      settings.clipboardAutoClearEnabled,
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            settings.clipboardAutoClearEnabled
                                ? 'Password copied (auto-clears in 30s)'
                                : 'Password copied',
                          ),
                        ),
                      );
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: generator.generatePassword,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildStrengthIndicator(generatorState.strength),
          const SizedBox(height: 24),
          Text(
            'Length: ${generatorState.length}',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Slider(
            value: generatorState.length.toDouble(),
            min: 8,
            max: 32,
            divisions: 24,
            onChanged: (value) => generator.setLength(value.toInt()),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildToggleChip(
                label: 'ABC',
                isSelected: generatorState.includeUppercase,
                onTap: generator.toggleUppercase,
                enabled:
                    !(generatorState.includeUppercase &&
                        _isOnlyOptionEnabled(generatorState)),
              ),
              _buildToggleChip(
                label: 'abc',
                isSelected: generatorState.includeLowercase,
                onTap: generator.toggleLowercase,
                enabled:
                    !(generatorState.includeLowercase &&
                        _isOnlyOptionEnabled(generatorState)),
              ),
              _buildToggleChip(
                label: '123',
                isSelected: generatorState.includeNumbers,
                onTap: generator.toggleNumbers,
                enabled:
                    !(generatorState.includeNumbers &&
                        _isOnlyOptionEnabled(generatorState)),
              ),
              _buildToggleChip(
                label: '#\$%',
                isSelected: generatorState.includeSymbols,
                onTap: generator.toggleSymbols,
                enabled:
                    !(generatorState.includeSymbols &&
                        _isOnlyOptionEnabled(generatorState)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              onPasswordSelected(generatorState.password);
              Navigator.of(context).pop();
            },
            child: const Text('Use Password'),
          ),
        ],
      ),
    );
  }

  bool _isOnlyOptionEnabled(PasswordGeneratorState state) {
    int count = 0;
    if (state.includeUppercase) count++;
    if (state.includeLowercase) count++;
    if (state.includeNumbers) count++;
    if (state.includeSymbols) count++;
    return count <= 1;
  }

  Widget _buildStrengthIndicator(int strength) {
    final colors = [
      AppTheme.errorColor,
      Colors.orange,
      Colors.yellow.shade700,
      Colors.lightGreen,
      AppTheme.successColor,
    ];
    final labels = ['Very Weak', 'Weak', 'Fair', 'Strong', 'Very Strong'];

    final effectiveStrength = strength.clamp(0, 5);
    final colorIndex = (effectiveStrength - 1).clamp(0, 4);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(5, (index) {
            return Expanded(
              child: Container(
                height: 4,
                margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(
                  color: index < strength
                      ? colors[colorIndex]
                      : AppTheme.textHint.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Text(
          labels[colorIndex],
          style: TextStyle(
            color: colors[colorIndex],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildToggleChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    bool enabled = true,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: !enabled
              ? AppTheme.textHint.withValues(alpha: 0.3)
              : isSelected
              ? AppTheme.primaryColor
              : AppTheme.backgroundColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: !enabled
                ? AppTheme.textHint
                : isSelected
                ? Colors.white
                : AppTheme.textSecondary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
