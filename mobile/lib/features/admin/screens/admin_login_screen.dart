import 'package:flutter/material.dart';

// قسمت قابل تغییر توسط کاربر
class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  // State مربوط به Flutter
  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

// قسمت وضعیت و رفتار لاگین
class _AdminLoginScreenState extends State<AdminLoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Login'),
      ),

      // ایجاد فاصله دور محتوا
      body: Padding(
        padding: const EdgeInsets.all(24),

        // مدیریت ورودی‌های فرم
        child: Form(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // فیلد ورودی شماره تلفن
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              // فیلد رمز عبور
              TextFormField(
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: () {},
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}