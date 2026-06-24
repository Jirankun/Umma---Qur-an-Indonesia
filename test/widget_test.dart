import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:umma/app.dart';
import 'package:umma/providers/theme_provider.dart';

void main() {
  testWidgets('App smoke test - Umma loads correctly', (
    WidgetTester tester,
  ) async {
    // Wrap with providers needed by UmmaApp
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ],
        child: const UmmaApp(),
      ),
    );

    // Tunggu frame pertama
    await tester.pump();

    // Verify that CupertinoApp renders (not the loading spinner)
    expect(find.byType(CupertinoApp), findsOneWidget);
  });
}
