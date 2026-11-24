import 'package:flutter_test/flutter_test.dart';
import 'package:battle_tap/main.dart';

void main() {
  testWidgets('Retro arcade home presents its main menu', (tester) async {
    await tester.pumpWidget(const BattleTapApp());
    expect(find.text('PLAY'), findsOneWidget);
    expect(find.text('SHOP'), findsOneWidget);
    expect(find.text('RANKS'), findsOneWidget);
    expect(find.text('FRIENDS'), findsOneWidget);
    expect(find.text('PROFILE'), findsOneWidget);
  });

  testWidgets('Mode selection contains both Battle Tap modes', (tester) async {
    await tester.pumpWidget(const BattleTapApp());
    await tester.tap(find.text('PLAY'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('TAP BATTLE'), findsOneWidget);
    expect(find.text('RANDOM HUNT'), findsOneWidget);
    expect(find.textContaining('44% WIDTH'), findsOneWidget);
  });
}
