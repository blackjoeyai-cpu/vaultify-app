import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../application/providers/vault_provider.dart';
import '../../domain/entities/password_entry.dart';
import '../widgets/password_strength_indicator.dart';
import '../../../../core/utils/extensions.dart';

class AddPasswordPage extends ConsumerStatefulWidget {
  const AddPasswordPage({super.key});

  @override
  ConsumerState<AddPasswordPage> createState() => _AddPasswordPageState();
}

class _AddPasswordPageState extends ConsumerState<AddPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _urlController = TextEditingController();
  final _notesController = TextEditingController();
  PasswordCategory _selectedCategory = PasswordCategory.others;
  int _passwordStrength = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_updatePasswordStrength);
  }

  void _updatePasswordStrength() {
    setState(() {
      _passwordStrength = _passwordController.text.passwordStrength;
    });
  }

  @override
  void dispose() {
    _passwordController.removeListener(_updatePasswordStrength);
    _titleController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _urlController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _savePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final now = DateTime.now();
    final entry = PasswordEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text,
      username: _usernameController.text,
      password: _passwordController.text,
      url: _urlController.text.isEmpty ? null : _urlController.text,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
      category: _selectedCategory,
      createdAt: now,
      updatedAt: now,
    );

    await ref.read(vaultProvider.notifier).addPassword(entry);

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(title: const Text('Add Password')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField(
                controller: _titleController,
                label: 'Title',
                hint: 'e.g., Gmail',
                icon: Icons.title,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _usernameController,
                label: 'Username / Email',
                hint: 'e.g., user@gmail.com',
                icon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a username';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _passwordController,
                label: 'Password',
                hint: 'Enter password',
                icon: Icons.lock_outline,
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              PasswordStrengthIndicator(strength: _passwordStrength),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _urlController,
                label: 'Website URL (Optional)',
                hint: 'e.g., https://gmail.com',
                icon: Icons.link,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _notesController,
                label: 'Notes (Optional)',
                hint: 'Add any additional notes',
                icon: Icons.notes,
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              Text(
                'Category',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: PasswordCategory.values.map((category) {
                  final isSelected = _selectedCategory == category;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? category.color
                            : AppTheme.surfaceColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            category.icon,
                            size: 20,
                            color: isSelected ? Colors.white : category.color,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            category.displayName,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _savePassword,
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save Password'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    required IconData icon,
    bool obscureText = false,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(hintText: hint, prefixIcon: Icon(icon)),
        ),
      ],
    );
  }
}
