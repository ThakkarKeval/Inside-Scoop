import 'package:flutter_test/flutter_test.dart';
import 'package:inside_scoop_example/main.dart';

void main() {
  testWidgets('Verify Inside Scoop App renders dashboard', (WidgetTester tester) async {
    await tester.pumpWidget(const InsideScoopCyberdeckApp());
    expect(find.text('INSIDE SCOOP // CYBERDECK'), findsOneWidget);
  });
}
