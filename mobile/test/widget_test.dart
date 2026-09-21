import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/main.dart';

void main() {
  testWidgets('E-Commerce app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: EcommerceApp()));

    expect(find.byType(EcommerceApp), findsOneWidget);
  });
}