// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:chatapp/main.dart';

void main() {
  testWidgets('Post new message smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(FriendlyChatApp());

    // Verify that our input starts at empty.
    expect(find.widgetWithText(TextField().runtimeType, ''), findsOneWidget);

    // Write a message
    await tester.tap(find.byType(TextField));
    await tester.enterText(find.byType(TextField), 'abcd');
    await tester.pump();

    // Tap the '>' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.send));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.widgetWithText(TextField().runtimeType, ''), findsOneWidget);
    expect(find.byType(ChatMessage, skipOffstage: false), findsOneWidget);
  });
}
