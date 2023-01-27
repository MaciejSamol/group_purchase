/*                      Aplikacja Group Purchase
Aplikacja do tworzenia i przechowywania grupowych list zakupowych
Autorami są Maciej Samol oraz Patryk Orzechowski, studenci Wyższej Szkoły Bankowej w Poznaniu.
Projekt ten jest projektem zaliczeniowym kierunku "Tworzenie aplikacji internetowych" */

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'gui/home_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';

//Funkcja inicjująca działanie aplikacji
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //Funkcja pobierająca informacje o urządzeniu
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  // Funkcja odpowiedzialna za połączenie z bazą danych
  await Firebase.initializeApp();
  AndroidDeviceInfo info = await deviceInfo.androidInfo;
  String? deviceId = info.androidId;
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((value) => runApp(MyApp(
            devId: deviceId.toString(),
          )));
}

// funkcja zatrzymująca splash screen na 5 sekund
Future initializattion(BuildContext? context) async {
  await Future.delayed(const Duration(seconds: 5));
}

//Główna klasa aplikacji
class MyApp extends StatelessWidget {
  final String devId;
  const MyApp({super.key, required this.devId});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      //wywołanie home_page.dart jako strony domowej
      home: MainPage(
        deviceId: devId,
      ),
    );
  }
}
