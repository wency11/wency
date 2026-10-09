import 'package:flutter_test/flutter_test.dart';

import 'package:pagsanjan_farmer_dashboard/main.dart';

void main() {
  testWidgets('PAGRI app builds without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const PagriApp());

    // The app bar shows the PAGRI name and Tagalog tagline by default.
    expect(find.text('PAGRI'), findsOneWidget);
    expect(find.text('Sektor ng Agrikultura ng Pagsanjan'), findsOneWidget);
  });
}
