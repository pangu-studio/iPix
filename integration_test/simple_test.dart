import 'package:flutter_test/flutter_test.dart';
import 'package:ipix/main.dart';
import 'package:ipix/src/rust/frb_generated.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async => await RustLib.init());
  testWidgets('Can call rust function', (WidgetTester tester) async {
    await tester.pumpWidget(const HomePage());
    expect(find.textContaining('Result: `Hello, Tom!`'), findsOneWidget);
  });
}
