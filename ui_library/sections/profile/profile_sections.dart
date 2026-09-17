import 'package:flutter/material.dart';

import '../../components/address/address.dart';

/// Reusable Profile sections. Account state and navigation remain in the page.
class ProfileSections {
  const ProfileSections._();

  static Widget profileHeader({required Widget content}) => _Section(child: content);

  static Widget accountActions({required Widget content}) => _Section(child: content);

  static Widget addresses({
    required List<AddressItem> addresses,
    String? selectedAddressId,
    ValueChanged<AddressItem>? onSelect,
    ValueChanged<AddressItem>? onEdit,
    ValueChanged<AddressItem>? onDelete,
    VoidCallback? onAddAddress,
  }) {
    return AddressComponent(
      addresses: addresses,
      selectedAddressId: selectedAddressId,
      onSelect: onSelect,
      onEdit: onEdit,
      onDelete: onDelete,
      onAddAddress: onAddAddress,
    );
  }

  static Widget auxiliary({required Widget content}) => _Section(child: content);
}

class _Section extends StatelessWidget {
  final Widget child;

  const _Section({required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: child,
    );
  }
}
