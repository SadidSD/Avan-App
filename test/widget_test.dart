import 'package:flutter_test/flutter_test.dart';
import 'package:avan_app/main.dart';

void main() {
  testWidgets('AVAN app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const AvanApp());
    expect(find.byType(AvanApp), findsOneWidget);
  });
}
