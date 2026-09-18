import 'package:flutter/material.dart';

import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';

class AuthHeader extends StatelessWidget {
  final bool register;

  const AuthHeader({
    super.key,
    required this.register,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(
          Icons.storefront,
          size: 64,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: 15),
        Text(
          register ? 'حساب کاربری بسازید' : 'به فروشگاه برگردید',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class AuthPhoneField extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;

  const AuthPhoneField({
    super.key,
    required this.controller,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: controller,
      labelText: 'شماره موبایل',
      prefixIcon: Icons.phone_outlined,
      keyboardType: TextInputType.phone,
      validator: validator,
    );
  }
}

class AuthPasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String? Function(String?)? validator;

  const AuthPasswordField({
    super.key,
    required this.controller,
    this.labelText = 'رمز عبور',
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: controller,
      labelText: labelText,
      prefixIcon: Icons.lock_outline,
      obscureText: true,
      validator: validator,
    );
  }
}

class AuthPasswordConfirmationField extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;

  const AuthPasswordConfirmationField({
    super.key,
    required this.controller,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: controller,
      labelText: 'تکرار رمز عبور',
      prefixIcon: Icons.lock_reset_outlined,
      obscureText: true,
      validator: validator,
    );
  }
}

class AuthSubmitButton extends StatelessWidget {
  final bool register;
  final bool isLoading;
  final VoidCallback? onPressed;

  const AuthSubmitButton({
    super.key,
    required this.register,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppButton(
      label: register ? 'ثبت‌نام' : 'ورود',
      icon: register ? Icons.person_add_alt_1 : Icons.login,
      isLoading: isLoading,
      onPressed: onPressed,
    );
  }
}

class AuthModeToggle extends StatelessWidget {
  final bool register;
  final bool enabled;
  final VoidCallback? onPressed;

  const AuthModeToggle({
    super.key,
    required this.register,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: enabled ? onPressed : null,
      child: Text(
        register ? 'قبلاً حساب دارم؛ ورود' : 'حساب ندارم؛ ثبت‌نام',
      ),
    );
  }
}
