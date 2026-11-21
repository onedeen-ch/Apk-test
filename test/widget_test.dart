import 'package:flutter_test/flutter_test.dart';
import 'package:battle_tap/main.dart';

void main() {
  testWidgets('Two game modes appear on the home screen', (tester) async {
    await tester.pumpWidget(const BattleTapApp());
    expect(find.text('TAP BATTLE'), findsOneWidget);
    expect(find.text('RANDOM HUNT'), findsOneWidget);
  });
}
