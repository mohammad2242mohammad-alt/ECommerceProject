import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/store_providers.dart';
import '../widgets/auth_ui_components.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirmation = TextEditingController();

  bool _register = false;
  bool _busy = false;

  @override
  void dispose() {
    _phone.dispose();
    _password.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _busy = true;
    });

    try {
      final repo = ref.read(storeRepositoryProvider);

      final session = _register
          ? await repo.register(
              _phone.text.trim(),
              _password.text,
              _confirmation.text,
            )
          : await repo.login(
              _phone.text.trim(),
              _password.text,
            );

      ref.read(authUserProvider.notifier).setUser(session.user);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _register
                  ? 'ثبت‌نام با موفقیت انجام شد'
                  : 'ورود موفق بود',
            ),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString())),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_register ? 'ثبت‌نام' : 'ورود به حساب'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  AuthHeader(register: _register),
                  const SizedBox(height: 28),
                  AuthPhoneField(
                    controller: _phone,
                    validator: (value) {
                      if (value == null || value.trim().length < 10) {
                        return 'شماره موبایل را درست وارد کنید';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  AuthPasswordField(
                    controller: _password,
                    validator: (value) {
                      if (value == null || value.length < 6) {
                        return 'رمز عبور حداقل ۶ حرف باشد';
                      }
                      return null;
                    },
                  ),
                  if (_register) ...[
                    const SizedBox(height: 12),
                    AuthPasswordConfirmationField(
                      controller: _confirmation,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'تکرار رمز عبور را وارد کنید';
                        }
                        if (value != _password.text) {
                          return 'تکرار رمز عبور یکسان نیست';
                        }
                        return null;
                      },
                    ),
                  ],
                  const SizedBox(height: 22),
                  AuthSubmitButton(
                    register: _register,
                    isLoading: _busy,
                    onPressed: _submit,
                  ),
                  const SizedBox(height: 10),
                  AuthModeToggle(
                    register: _register,
                    enabled: !_busy,
                    onPressed: () {
                      setState(() {
                        _register = !_register;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
