import 'package:flutter_test/flutter_test.dart';
import 'package:isl_translator/main.dart';

void main() {
  testWidgets('App renders', (WidgetTester tester) async {
    await tester.pumpWidget(const ISLTranslatorApp());
    expect(find.text('ISL\nTranslator'), findsOneWidget);
  });
}
