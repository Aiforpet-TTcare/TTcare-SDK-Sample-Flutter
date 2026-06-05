import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fluttersdksample/main.dart';

void main() {
  const channel = MethodChannel('com.aiforpet.sdk/channel');

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'launchSdk') {
        return '{"ok":true}';
      }
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  testWidgets('renders default options and pet/part cards', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('enableQuestionnaire'), findsOneWidget);
    expect(find.text('enableResultView'), findsOneWidget);
    expect(find.text('enablePdfShare'), findsOneWidget);
    expect(find.text('DOG'), findsOneWidget);
    expect(find.text('EYE'), findsAtLeastNWidgets(1));
    expect(find.text('TEETH'), findsAtLeastNWidgets(1));
    expect(find.text('EAR'), findsOneWidget);
    expect(find.text('BODY'), findsOneWidget);
    expect(find.text('FOOT'), findsOneWidget);
  });

  testWidgets('toggling enableQuestionnaire flips the checkbox', (tester) async {
    await tester.pumpWidget(const MyApp());

    final checkbox = tester.widget<Checkbox>(find.byType(Checkbox).first);
    expect(checkbox.value, true);

    await tester.tap(find.byType(Checkbox).first);
    await tester.pump();

    final updated = tester.widget<Checkbox>(find.byType(Checkbox).first);
    expect(updated.value, false);
  });

  testWidgets('tapping a card invokes the SDK and shows the result overlay',
      (tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('EAR'));
    await tester.pumpAndSettle();

    expect(find.text('Close'), findsOneWidget);
    expect(find.textContaining('"ok"'), findsOneWidget);

    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    expect(find.text('Close'), findsNothing);
  });
}
