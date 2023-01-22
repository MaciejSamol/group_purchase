import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

import 'package:flutter/material.dart';

import 'gui/home_page.dart';

import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  await Firebase.initializeApp();
  AndroidDeviceInfo info = await deviceInfo.androidInfo;
  String? deviceId = info.androidId;
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((value) => runApp(MyApp(
            devId: deviceId.toString(),
          )));
}

Future initializattion(BuildContext? context) async {
  await Future.delayed(Duration(seconds: 5));
}
// funkcja zatrzymująca splash screen na 5 sekund

class MyApp extends StatelessWidget {
  final String devId;
  const MyApp({required this.devId});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainPage(
        deviceId: devId,
      ),
    );
  }
}
