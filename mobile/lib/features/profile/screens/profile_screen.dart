import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/routes/app_routes.dart';
import '../../../providers/store_providers.dart';
import '../widgets/profile_ui_components.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authUserProvider);

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('حساب کاربری')),
        body: ProfileLoginRequired(
          onLogin: () => Navigator.pushNamed(context, AppRoutes.auth),
        ),
      );
    }

    final avatarText = user.name != null && user.name!.isNotEmpty
        ? user.name![0]
        : user.phone.isNotEmpty
            ? user.phone[0]
            : '?';

    return Scaffold(
      appBar: AppBar(title: const Text('حساب کاربری')),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          ProfileHeaderCard(
            avatarText: avatarText,
            name: user.name != null && user.name!.isNotEmpty
                ? user.name!
                : 'کاربر فروشگاه',
            phone: user.phone,
          ),
          const SizedBox(height: 10),
          ProfileMenuCard(
            onOrders: () => Navigator.pushNamed(context, AppRoutes.orders),
            onAddresses: () =>
                Navigator.pushNamed(context, AppRoutes.addresses),
            onFavorites: () =>
                Navigator.pushNamed(context, AppRoutes.favorites),
          ),
          const SizedBox(height: 18),
          ProfileLogoutButton(
            onLogout: () async {
              try {
                await ref.read(storeRepositoryProvider).logout();
                ref.read(authUserProvider.notifier).setUser(null);
                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.home,
                    (route) => false,
                  );
                }
              } catch (error) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(error.toString())),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
