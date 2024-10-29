// import 'package:flutter_test/flutter_test.dart';
// import 'package:flutter/material.dart';
// import 'package:maisound/ui/input_number.dart';

// void main() {a
//   testWidgets('Testa o InputNumber widget', (WidgetTester tester) async {
//     // Monta o widget no ambiente de teste.
//     int testValue = 3;

//     await tester.pumpWidget(
//       MaterialApp(
//         home: Scaffold(
//           body: InputNumber(
//             label: 'Texto esperado',
//             onChanged: (value) {
//               testValue = value;
//             },
//             value: testValue,
//             min: 0,
//             max: 10,
//           ),
//         ),
//       ),
//     );

//     // Verifica se o label está presente no widget.
//     expect(find.text('Texto esperado'), findsOneWidget);

//     // Verifica o valor inicial.
//     expect(find.text('3'), findsOneWidget);

//     // Simula uma interação: altera o valor.
//     await tester.enterText(find.byType(TextField), '5');
//     await tester.pump();

//     // Valida se o novo valor foi atualizado no callback.
//     expect(testValue, equals(5));
//   });
// }
