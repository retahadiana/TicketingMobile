import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ticketing_helpdesk/main.dart';

void main() {
  testWidgets('App shows splash title', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));

    expect(find.text('E-Ticketing Helpdesk'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1300));
    await tester.pumpAndSettle();

    expect(find.text('Login E-Ticketing'), findsOneWidget);
  });
}
