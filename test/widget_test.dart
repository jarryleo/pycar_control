// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pycar_control/main.dart';
import 'package:udp/udp.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });

  test("udp", () async{
    // MULTICAST
    var multicastEndpoint =
    Endpoint.multicast(InternetAddress("239.2.5.6"), port: const Port(27890));
    var udp = await UDP.bind(multicastEndpoint);
    udp.asStream().listen((datagram) {
      if (datagram != null) {
        var str = String.fromCharCodes(datagram.data);
        print(str);
      }
    });
    await udp.send("Foo".codeUnits, multicastEndpoint);
    await Future.delayed(const Duration(seconds:5));
    udp.close();
  });
}
