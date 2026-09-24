import 'package:flutter_test/flutter_test.dart';
import 'package:smart_billboard_app/main.dart';

void main() {
  testWidgets('App initializes successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const SmartBillboardApp());
    expect(find.byType(SmartBillboardApp), findsOneWidget);
  });
}
