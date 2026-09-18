import 'package:flutter/material.dart';

/// Presentation model for a checkout summary.
class CheckoutSummary {
  final String subtotalLabel;
  final String shippingLabel;
  final String discountLabel;
  final String totalLabel;
  final String? couponLabel;

  const CheckoutSummary({
    required this.subtotalLabel,
    required this.shippingLabel,
    required this.discountLabel,
    required this.totalLabel,
    this.couponLabel,
  });
}

/// Reusable checkout UI. Pricing, coupon validation, payment and order rules
/// remain outside the component.
class CheckoutComponent extends StatelessWidget {
  final CheckoutSummary summary;
  final Widget? addressSection;
  final Widget? shippingSection;
  final Widget? paymentSection;
  final VoidCallback? onConfirm;
  final String confirmLabel;
  final bool isLoading;
  final bool enabled;
  final String title;

  const CheckoutComponent({
    super.key,
    required this.summary,
    this.addressSection,
    this.shippingSection,
    this.paymentSection,
    this.onConfirm,
    this.confirmLabel = 'ثبت و پرداخت سفارش',
    this.isLoading = false,
    this.enabled = true,
    this.title = 'تسویه‌حساب',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 16),
          if (addressSection != null) ...[
            addressSection!,
            const SizedBox(height: 12),
          ],
          if (shippingSection != null) ...[
            shippingSection!,
            const SizedBox(height: 12),
          ],
          if (paymentSection != null) ...[
            paymentSection!,
            const SizedBox(height: 12),
          ],
          _SummaryCard(summary: summary),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: enabled && !isLoading ? onConfirm : null,
              icon: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.payment_outlined),
              label: Text(confirmLabel),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final CheckoutSummary summary;

  const _SummaryCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _SummaryRow(label: 'مبلغ کالاها', value: summary.subtotalLabel),
            const SizedBox(height: 10),
            _SummaryRow(label: 'هزینه ارسال', value: summary.shippingLabel),
            const SizedBox(height: 10),
            _SummaryRow(label: 'تخفیف', value: summary.discountLabel),
            if (summary.couponLabel != null) ...[
              const SizedBox(height: 8),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  summary.couponLabel!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1),
            ),
            _SummaryRow(
              label: 'مبلغ نهایی',
              value: summary.totalLabel,
              emphasize: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool emphasize;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium?.copyWith(
      fontWeight: emphasize ? FontWeight.w900 : FontWeight.w500,
    );

    return Row(
      children: [
        Expanded(child: Text(label, style: style)),
        const SizedBox(width: 12),
        Text(value, style: style),
      ],
    );
  }
}
