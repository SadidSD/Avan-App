import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:avan_app/main.dart';

void main() {
  testWidgets('AVAN app loads', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(const AvanApp());
    expect(find.byType(AvanApp), findsOneWidget);
  });
}
