// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:bakiru/app.dart';
import 'package:bakiru/features/trash/provider/trash_repository_provider.dart';
import 'package:bakiru/features/trash/repository/fake_trash_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ごみ箱の項目から遺言入力を経て叩き割る画面へ進める', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          trashRepositoryProvider.overrideWithValue(FakeTrashRepository()),
        ],
        child: const BakiruApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('バキる'), findsOneWidget);
    expect(find.bySemanticsLabel('写真'), findsOneWidget);
    expect(find.bySemanticsLabel('メール'), findsOneWidget);
    expect(find.bySemanticsLabel('ゴミ箱'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('ゴミ箱'));
    await tester.pumpAndSettle();

    expect(find.text('思い出の写真'), findsOneWidget);

    await tester.tap(find.text('思い出の写真'));
    await tester.pumpAndSettle();

    expect(find.text('遺言を残す'), findsOneWidget);

    await tester.tap(find.text('言葉を残さず進む'));
    await tester.pumpAndSettle();

    expect(find.text('叩き割る'), findsOneWidget);
  });
}
