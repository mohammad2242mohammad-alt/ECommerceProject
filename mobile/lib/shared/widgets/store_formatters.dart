String money(num value) {
  final raw = value == value.roundToDouble()
      ? value.toInt().toString()
      : value.toStringAsFixed(2);
  final chars = raw.split('').reversed.toList();
  final out = <String>[];
  for (var i = 0; i < chars.length; i++) {
    if (i > 0 && i % 3 == 0) out.add(',');
    out.add(chars[i]);
  }
  return out.reversed.join();
}

String orderStatusLabel(String status) =>
    const {
      'pending': 'در انتظار پرداخت',
      'confirmed': 'تأیید شده',
      'processing': 'در حال آماده‌سازی',
      'shipped': 'ارسال شده',
      'delivered': 'تحویل شده',
      'cancelled': 'لغو شده',
    }[status] ??
    status;

String paymentStatusLabel(String status) =>
    const {
      'unpaid': 'پرداخت نشده',
      'paid': 'پرداخت موفق',
      'failed': 'پرداخت ناموفق',
      'refunded': 'مرجوع شده',
    }[status] ??
    status;
