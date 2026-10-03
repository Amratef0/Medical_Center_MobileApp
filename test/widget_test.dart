import 'package:flutter_test/flutter_test.dart';
import 'package:mcsos_mobile/main.dart';

void main() {
  testWidgets('التطبيق بيفتح من غير كراش ويظهر شاشة السبلاش', (WidgetTester tester) async {
    await tester.pumpWidget(const McsosApp());

    // شاشة السبلاش المفروض تعرض اسم الابليكيشن
    expect(find.text('MCSOS'), findsOneWidget);
  });
}
