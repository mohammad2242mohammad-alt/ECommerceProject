import 'package:flutter/material.dart';

class ProfileLoginRequired extends StatelessWidget {
  const ProfileLoginRequired({super.key, required this.onLogin});
  final VoidCallback onLogin;
  @override
  Widget build(BuildContext context) {
    return Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.person_outline, size: 72, color: Colors.grey), const SizedBox(height: 12), const Text('برای استفاده از امکانات حساب وارد شوید'), const SizedBox(height: 14), FilledButton.icon(onPressed: onLogin, icon: const Icon(Icons.login), label: const Text('ورود / ثبت‌نام'))])));
  }
}

class ProfileHeaderCard extends StatelessWidget {
  const ProfileHeaderCard({super.key, required this.avatarText, required this.name, required this.phone});
  final String avatarText;
  final String name;
  final String phone;
  @override
  Widget build(BuildContext context) {
    return Card(child: ListTile(leading: CircleAvatar(child: Text(avatarText)), title: Text(name), subtitle: Text(phone)));
  }
}

class ProfileMenuCard extends StatelessWidget {
  const ProfileMenuCard({super.key, required this.onOrders, required this.onAddresses, required this.onFavorites});
  final VoidCallback onOrders;
  final VoidCallback onAddresses;
  final VoidCallback onFavorites;
  @override
  Widget build(BuildContext context) {
    return Card(child: Column(children: [
      _Item(icon: Icons.receipt_long_outlined, title: 'سفارش‌های من', onTap: onOrders),
      _Item(icon: Icons.location_on_outlined, title: 'آدرس‌ها', onTap: onAddresses),
      _Item(icon: Icons.favorite_border, title: 'علاقه‌مندی‌ها', onTap: onFavorites),
    ]));
  }
}

class ProfileLogoutButton extends StatelessWidget {
  const ProfileLogoutButton({super.key, required this.onLogout});
  final VoidCallback onLogout;
  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(onPressed: onLogout, icon: const Icon(Icons.logout), label: const Text('خروج از حساب'));
  }
}

class _Item extends StatelessWidget {
  const _Item({required this.icon, required this.title, required this.onTap});
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => ListTile(leading: Icon(icon), title: Text(title), trailing: const Icon(Icons.chevron_left), onTap: onTap);
}
