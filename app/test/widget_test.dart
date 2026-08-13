import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tree4all/theme/app_theme.dart';

void main() {
  testWidgets('App theme builds without error', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(theme: AppTheme.theme, home: const Scaffold(body: Text('Tree4All'))));
    expect(find.text('Tree4All'), findsOneWidget);
  });
}
