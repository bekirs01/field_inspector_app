import 'package:flutter_test/flutter_test.dart';

import 'package:field_inspector_app/app/app.dart';

void main() {
  testWidgets('Login screen shows access title', (WidgetTester tester) async {
    await tester.pumpWidget(const FieldInspectorApp());

    expect(find.text('Мобильный обходчик'), findsOneWidget);
    expect(find.text('Войти'), findsOneWidget);
  });
}
