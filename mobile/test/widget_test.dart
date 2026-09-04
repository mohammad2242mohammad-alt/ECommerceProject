import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/main.dart';

void main() {
  testWidgets('E-Commerce app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const EcommerceApp());

    expect(find.byType(EcommerceApp), findsOneWidget);
  });
}