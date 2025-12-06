// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:foundry_erp/services/data_service.dart';
import 'package:foundry_erp/main.dart';

void main() {
  testWidgets('FundiçãoPro ERP smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    final dataService = DataService();
    await dataService.inicializarDadosExemplo();
    
    await tester.pumpWidget(FundicaoProApp(dataService: dataService));

    // Verify that the app loads with Dashboard
    expect(find.text('Dashboard'), findsWidgets);
  });
}
